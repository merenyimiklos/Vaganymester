using System.Collections.ObjectModel;
using System.Windows.Media;
using Vaganymester.Models;

namespace Vaganymester.Simulation;

/// <summary>
/// Hálózati áttekintő: a Köröspatak állomás körül elhelyezkedő öt állomást és
/// az állomási motorban ténylegesen közlekedő vagy menetrend szerint közeledő vonatokat mutatja.
/// Az oldalsó állomások első körben hálózati csomópontok, nem teljesen szimulált biztosítóberendezések.
/// </summary>
public sealed class NetworkState : BindableBase
{
    private readonly DispatchEngine _engine;
    public DispatchEngine Engine => _engine;
    public ObservableCollection<NetworkStation> Stations { get; } = new();
    public ObservableCollection<NetworkTrainMarker> Markers { get; } = new();

    private NetworkStation? _selectedStation;
    public NetworkStation? SelectedStation
    {
        get => _selectedStation;
        set
        {
            if (!Set(ref _selectedStation, value)) return;
            RefreshPanel();
        }
    }

    public int MovingCount => _engine.Trains.Count(t => !t.Crashed && t.Speed > 1);
    public int StationCount => Stations.Count;
    public int DelayedCount => _engine.DelayedCount;
    public string ModeLabel => _engine.AutoDispatchEnabled ? "AUTOMATA FORGALOMIRÁNYÍTÁS" : "KÉZI FORGALOMIRÁNYÍTÁS";
    public string SelectedSummary => SelectedStation is null ? "Válassz egy állomást!" :
        SelectedStation.Side == 0
            ? $"Kőröspatak: {_engine.ActiveCount} vonat az állomási térségben. Külön állomási pulton irányítható."
            : SelectedStation.Side > 0
                ? $"Nyugati vonal: {WestWaiting} várakozó érkezés. A szakasz kezelése a nyugati be- és kijáratra hat."
                : $"Keleti vonal: {EastWaiting} várakozó érkezés. A szakasz kezelése a keleti be- és kijáratra hat.";
    public int WestWaiting => _engine.Timetable.Count(p => !p.Spawned &&
        p.DueSecond <= _engine.ElapsedSeconds && p.Direction > 0);
    public int EastWaiting => _engine.Timetable.Count(p => !p.Spawned &&
        p.DueSecond <= _engine.ElapsedSeconds && p.Direction < 0);
    public bool CanControlSelectedLine => SelectedStation is { Side: not 0 };
    public string EntryButtonText
    {
        get
        {
            if (!CanControlSelectedLine) return "Belépés: állomási pult";
            bool open = SelectedStation!.Side > 0 ? _engine.WestEntryOpen : _engine.EastEntryOpen;
            return open ? "BELÉPÉS: ENGEDÉLYEZVE" : "BELÉPÉS: TILTVA";
        }
    }
    public string ExitButtonText
    {
        get
        {
            if (!CanControlSelectedLine) return "Kihaladás: állomási pult";
            bool open = SelectedStation!.Side > 0 ? _engine.WestExitOpen : _engine.EastExitOpen;
            return open ? "KIHALADÁS: ENGEDÉLYEZVE" : "KIHALADÁS: TILTVA";
        }
    }

    public NetworkState(DispatchEngine engine)
    {
        _engine = engine;
        Stations.Add(new NetworkStation("NY", "NYUGATI PÁLYAUDVAR", "Végállomás", 38, 260, 1, 4));
        Stations.Add(new NetworkStation("FL", "FENYVESLIGET", "Csatlakozó állomás", 270, 260, 1, 3));
        Stations.Add(new NetworkStation("KP", "KŐRÖSPATAK", "Kezelhető állomás", 515, 260, 0, 2));
        Stations.Add(new NetworkStation("TV", "TISZAVÁROS", "Csatlakozó állomás", 760, 260, -1, 3));
        Stations.Add(new NetworkStation("KE", "KELETI PÁLYAUDVAR", "Végállomás", 994, 260, -1, 6));
        SelectedStation = Stations[2];
        Refresh();
    }

    public void ToggleEntry()
    {
        if (!CanControlSelectedLine) return;
        if (SelectedStation!.Side > 0) _engine.WestEntryOpen = !_engine.WestEntryOpen;
        else _engine.EastEntryOpen = !_engine.EastEntryOpen;
        RefreshPanel();
    }

    public void ToggleExit()
    {
        if (!CanControlSelectedLine) return;
        if (SelectedStation!.Side > 0) _engine.WestExitOpen = !_engine.WestExitOpen;
        else _engine.EastExitOpen = !_engine.EastExitOpen;
        RefreshPanel();
    }

    public void Refresh()
    {
        var shown = new HashSet<string>();
        foreach (var plan in _engine.Timetable)
        {
            if (plan.Status is "Teljesítve" or "BALESET") continue;
            var active = _engine.Trains.FirstOrDefault(t => t.Number == plan.Number);
            double x;
            double y;
            string status;
            if (active is not null)
            {
                x = 413 + Math.Clamp(active.X / 1270, 0, 1) * 340;
                y = active.Track == 1 ? 194 : 163;
                status = $"{active.SpeedLabel} • {active.Status}";
            }
            else
            {
                double lead = Math.Clamp(1 - (plan.DueSecond - _engine.ElapsedSeconds) / 30.0, 0, 1);
                x = plan.Direction > 0 ? 104 + lead * 294 : 1050 - lead * 294;
                y = plan.Direction > 0 ? 173 : 199;
                status = plan.DueSecond > _engine.ElapsedSeconds
                    ? $"Közeledik • {plan.DueTime}" : plan.Status;
            }
            Upsert(plan.Number, plan.Type, plan.Direction, x, y, status);
            shown.Add(plan.Number);
        }

        foreach (var active in _engine.Trains.Where(t => !_engine.Timetable.Any(p => p.Number == t.Number)))
        {
            Upsert(active.Number, active.Type, active.Direction,
                413 + Math.Clamp(active.X / 1270, 0, 1) * 340,
                active.Track == 1 ? 194 : 163,
                $"{active.SpeedLabel} • {active.Status}");
            shown.Add(active.Number);
        }

        foreach (var marker in Markers.Where(m => !shown.Contains(m.Number)).ToList())
            Markers.Remove(marker);

        foreach (var station in Stations)
        {
            station.Activity = station.Side == 0
                ? $"{_engine.ActiveCount} vonat • {_engine.CollisionCount} baleset"
                : station.Side > 0
                    ? $"{WestWaiting} érkező várakozik"
                    : $"{EastWaiting} érkező várakozik";
        }
        Raise(nameof(MovingCount));
        Raise(nameof(StationCount));
        Raise(nameof(DelayedCount));
        Raise(nameof(ModeLabel));
        RefreshPanel();
    }

    private void Upsert(string number, TrainType type, int direction, double x, double y, string status)
    {
        var marker = Markers.FirstOrDefault(m => m.Number == number);
        if (marker == null)
        {
            marker = new NetworkTrainMarker(number, type, direction);
            Markers.Add(marker);
        }
        marker.Left = x - 37;
        marker.Top = y - 13;
        marker.Status = status;
    }

    private void RefreshPanel()
    {
        Raise(nameof(SelectedSummary));
        Raise(nameof(WestWaiting));
        Raise(nameof(EastWaiting));
        Raise(nameof(CanControlSelectedLine));
        Raise(nameof(EntryButtonText));
        Raise(nameof(ExitButtonText));
    }
}

public sealed class NetworkStation : BindableBase
{
    public string Code { get; }
    public string Name { get; }
    public string Role { get; }
    public double Left { get; }
    public double Top { get; }
    public int Side { get; }
    public int Platforms { get; }
    private string _activity = "";
    public string Activity { get => _activity; set => Set(ref _activity, value); }
    public NetworkStation(string code, string name, string role, double left, double top, int side, int platforms)
    {
        Code = code; Name = name; Role = role; Left = left; Top = top; Side = side; Platforms = platforms;
    }
}

public sealed class NetworkTrainMarker : BindableBase
{
    public string Number { get; }
    public TrainType Type { get; }
    public int Direction { get; }
    public string DirectionText => Direction > 0 ? "→ KELET" : "← NYUGAT";
    public Brush TrainBrush => Type switch
    {
        TrainType.InterCity => new SolidColorBrush(Color.FromRgb(255, 189, 67)),
        TrainType.Teher => new SolidColorBrush(Color.FromRgb(119, 158, 196)),
        _ => new SolidColorBrush(Color.FromRgb(54, 224, 193))
    };
    private double _left;
    public double Left { get => _left; set => Set(ref _left, value); }
    private double _top;
    public double Top { get => _top; set => Set(ref _top, value); }
    private string _status = "";
    public string Status { get => _status; set => Set(ref _status, value); }
    public NetworkTrainMarker(string number, TrainType type, int direction)
    {
        Number = number; Type = type; Direction = direction;
    }
}
