import 'package:flutter/material.dart';
import '../game/simulation.dart';
import '../game/help_advisor.dart';

const _mint = Color(0xFF177DAA);
const _danger = Color(0xFFF16A74);

/// WPF-szerű állomási kezelőpult, a szimulációs motort vezérli.
class StationControlsPanel extends StatelessWidget {
  const StationControlsPanel({
    super.key,
    required this.simulation,
    required this.station,
    required this.onRejected,
    required this.onAutomatic,
    this.hint,
  });

  final RailwaySimulation simulation;
  final RailwayStation station;
  final void Function(String) onRejected;
  final ValueChanged<bool> onAutomatic;
  final HelpSuggestion? hint;

  bool get _showHint => hint != null && hint!.stationId == station.id;

  @override
  Widget build(BuildContext context) {
    final c = simulation.controls(station.id);
    final related = simulation.sections.where((s) =>
        s.from == station.id || s.to == station.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showHint) Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3C8),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFFFC244), width: 3),
          ),
          child: Row(children: [
            const Icon(Icons.ads_click_rounded,
                color: Color(0xFFD48B00), size: 27),
            const SizedBox(width: 8),
            Expanded(child: Text(hint!.detail,
                style: const TextStyle(color: Color(0xFF714A00),
                    fontSize: 12, fontWeight: FontWeight.w800))),
          ]),
        ),
        Text(station.name, style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800)),
        Text('Peronfoglaltság: ' +
            simulation.reservedPlatforms(station.id).toString() +
            ' / ' + station.platforms.toString(),
          style: const TextStyle(color: Color(0xFFA9C5D2))),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('Automata irányítás'),
          subtitle: const Text('Kézi módban állíts váltókat és jelzőket'),
          value: simulation.automatic,
          onChanged: onAutomatic,
        ),
        const Divider(),
        _side('NYUGATI BIZTOSÍTÁS', RailwaySide.west, c),
        const Divider(),
        _side('KELETI BIZTOSÍTÁS', RailwaySide.east, c),
        const Divider(),
        const Text('ÁLLOMÁSI VÁGÁNYOK',
            style: TextStyle(color: _mint, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (var track = 0; track < station.platforms; track++)
          _trackRow(c, track),
        const Divider(),
        const Text('VONALI VÁGÁNYZÁRAK',
            style: TextStyle(color: _mint, fontWeight: FontWeight.bold)),
        for (final section in related)
          SwitchListTile.adaptive(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(section.id),
            subtitle: Text(section.closed ? 'LEZÁRVA' :
                simulation.occupying(section) != null ? 'FOGLALT' : 'SZABAD'),
            value: section.closed,
            onChanged: (value) {
              if (!simulation.setSectionClosed(section.id, value)) {
                onRejected('Foglalt vonali szakasz nem zárható le.');
              }
            },
          ),
      ],
    );
  }

  Widget _side(String title, RailwaySide side, StationControls c) {
    final current = c.turnout(side);
    final disabled = simulation.automatic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.w700, color: _mint, fontSize: 12)),
        const SizedBox(height: 7),
        Text('Váltó állása: ' + (current + 1).toString() + '. vágány',
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 6, runSpacing: 4,
          children: [
            for (var index = 0; index < station.platforms; index++)
              ChoiceChip(
                backgroundColor: _showHint &&
                    hint!.focus == HintFocus.turnout &&
                    hint!.side == side && hint!.track == index
                    ? const Color(0xFFFFE59A) : null,
                elevation: _showHint && hint!.focus == HintFocus.turnout &&
                    hint!.side == side && hint!.track == index ? 7 : 0,
                shadowColor: const Color(0xFFFFA51B),
                selected: index == current,
                label: Text((index + 1).toString()),
                onSelected: disabled ? null : (_) {
                  if (!simulation.setTurnout(station.id, side, index)) {
                    onRejected('A váltó foglalt vagy lezárt vágányra mutat.');
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 7),
        _signalButton(side, SignalKind.entry,
            'BEJÁRATI JELZŐ', c, disabled),
        const SizedBox(height: 6),
        _signalButton(side, SignalKind.exit,
            'KIJÁRATI JELZŐ', c, disabled),
      ],
    );
  }

  Widget _signalButton(RailwaySide side, SignalKind kind, String title,
      StationControls c, bool disabled) {
    final green = c.signal(side, kind);
    final focus = kind == SignalKind.entry
        ? HintFocus.entrySignal : HintFocus.exitSignal;
    final highlighted = _showHint && hint!.focus == focus &&
        hint!.side == side;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: highlighted ? const Color(0xFFFFE59A) : null,
          side: highlighted
              ? const BorderSide(color: Color(0xFFFFB11B), width: 3)
              : null,
          elevation: highlighted ? 5 : 0,
          shadowColor: const Color(0xFFFFA51B),
        ),
        onPressed: disabled ? null : () {
          if (!simulation.setSignal(station.id, side, kind, !green)) {
            onRejected('Nem állítható szabadra: foglalt vagy lezárt vágányút.');
          }
        },
        icon: Icon(Icons.circle, color: green ? _mint : _danger, size: 13),
        label: Text(title + ': ' + (green ? 'SZABAD' : 'MEGÁLLJ'),
            style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _trackRow(StationControls c, int index) {
    final closed = c.closedTracks.contains(index);
    final occupied = simulation.trackReserved(station.id, index);
    return Row(
      children: [
        Expanded(child: Text(
          (index + 1).toString() + '. vágány  ' +
          (occupied ? '● FOGLALT' : closed ? '✕ ZÁRVA' : '○ SZABAD'),
          style: TextStyle(
              fontSize: 12,
              color: occupied ? _danger : const Color(0xFFA9C5D2)),
        )),
        TextButton(
          onPressed: () {
            if (!simulation.setTrackClosed(station.id, index, !closed)) {
              onRejected('Foglalt vagy váltóval kijelölt vágány nem zárható le.');
            }
          },
          child: Text(closed ? 'Feloldás' : 'Lezárás'),
        ),
      ],
    );
  }
}
