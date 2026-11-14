using Microsoft.Win32;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using Vaganymester.Models;
using Vaganymester.Simulation;

namespace Vaganymester;

public partial class NetworkWindow : Window
{
    private readonly NetworkState _state;
    private readonly Action<Train> _openTrainDetails;

    public NetworkWindow(DispatchEngine engine, Action<Train> openTrainDetails)
    {
        InitializeComponent();
        _state = new NetworkState(engine);
        _openTrainDetails = openTrainDetails;
        DataContext = _state;
    }

    public void Refresh() => _state.Refresh();

    private void Station_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button { Tag: NetworkStation station })
            _state.SelectedStation = station;
    }

    private void Marker_Click(object sender, RoutedEventArgs e)
    {
        if (sender is not Button { Tag: NetworkTrainMarker marker }) return;
        var train = _state.Engine.Trains.FirstOrDefault(t => t.Number == marker.Number);
        if (train is not null) _openTrainDetails(train);
        else MessageBox.Show(this,
            $"{marker.Number} még a nyílt vonalon, az állomás felé közeledik.\n{marker.Status}",
            "Vonat státusza", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void ToggleEntry_Click(object sender, RoutedEventArgs e) => _state.ToggleEntry();
    private void ToggleExit_Click(object sender, RoutedEventArgs e) => _state.ToggleExit();

    private void MainPanel_Click(object sender, RoutedEventArgs e)
    {
        Hide();
        Owner?.Activate();
        Owner?.Focus();
    }

    private void AllStop_Click(object sender, RoutedEventArgs e)
        => _state.Engine.StopAllTraffic();

    private void Resume_Click(object sender, RoutedEventArgs e)
        => _state.Engine.ResumeAllTraffic();

    private void ExportJournal_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new SaveFileDialog
        {
            Title = "Forgalmi napló mentése",
            Filter = "CSV-fájl (*.csv)|*.csv",
            FileName = "Vaganymester_forgalmi_naplo.csv",
            DefaultExt = ".csv"
        };
        if (dialog.ShowDialog(this) != true) return;
        static string Csv(string value) => "\"" + value.Replace("\"", "\"\"") + "\"";
        try
        {
            var lines = new[] { "Időpont;Esemény" }
                .Concat(_state.Engine.Journal.Reverse().Select(e => $"{Csv(e.Time)};{Csv(e.Message)}"));
            File.WriteAllLines(dialog.FileName, lines, new UTF8Encoding(true));
        }
        catch (IOException ex)
        {
            MessageBox.Show(this, ex.Message, "Mentési hiba", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        catch (UnauthorizedAccessException ex)
        {
            MessageBox.Show(this, ex.Message, "Hozzáférési hiba", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}
