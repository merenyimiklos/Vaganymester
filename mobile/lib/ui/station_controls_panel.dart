import 'package:flutter/material.dart';
import '../game/simulation.dart';
import '../game/help_advisor.dart';
import '../game/tutorial_guide.dart';
import '../l10n/game_l10n.dart';
import 'tutorial_coach.dart';

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
    this.tutorial,
    this.onTutorialAction,
  });

  final RailwaySimulation simulation;
  final RailwayStation station;
  final void Function(String) onRejected;
  final ValueChanged<bool> onAutomatic;
  final HelpSuggestion? hint;
  final TutorialGuide? tutorial;
  final ValueChanged<TutorialAction>? onTutorialAction;

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
        Text(GameL10n.tr('Peronfoglaltság') + ': ' +
            simulation.reservedPlatforms(station.id).toString() +
            ' / ' + station.platforms.toString(),
          style: const TextStyle(color: Color(0xFFA9C5D2))),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(GameL10n.tr('Automata irányítás')),
          subtitle: Text(GameL10n.tr('Kézi módban állíts váltókat és jelzőket')),
          value: simulation.automatic,
          onChanged: tutorial?.active == true ? null : onAutomatic,
        ),
        const Divider(),
        _side(GameL10n.tr('NYUGATI BIZTOSÍTÁS'), RailwaySide.west, c),
        const Divider(),
        _side(GameL10n.tr('KELETI BIZTOSÍTÁS'), RailwaySide.east, c),
        const Divider(),
        Text(GameL10n.tr('ÁLLOMÁSI VÁGÁNYOK'),
            style: TextStyle(color: _mint, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (var track = 0; track < station.platforms; track++)
          _trackRow(c, track),
        const Divider(),
        Text(GameL10n.tr('VONALI VÁGÁNYZÁRAK'),
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
        Text(GameL10n.tr('Váltó állása') + ': ' + (current + 1).toString() + '.',
            style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 5),
        Wrap(
          spacing: 6, runSpacing: 4,
          children: [
            for (var index = 0; index < station.platforms; index++)
              TutorialTarget(
                active: _highlightSwitch(side, index),
                child: ChoiceChip(
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
                  } else if (_highlightSwitch(side, index)) {
                    onTutorialAction?.call(station.id == 'fenyvesliget'
                        ? TutorialAction.changedOriginSwitch
                        : TutorialAction.changedDestinationSwitch);
                  }
                },
              ),
              ),
          ],
        ),
        const SizedBox(height: 7),
        _signalButton(side, SignalKind.entry,
            GameL10n.tr('BEJÁRATI JELZŐ'), c, disabled),
        const SizedBox(height: 6),
        _signalButton(side, SignalKind.exit,
            GameL10n.tr('KIJÁRATI JELZŐ'), c, disabled),
      ],
    );
  }

  bool _highlightSwitch(RailwaySide side, int index) {
    final step = tutorial?.step;
    return index == 1 &&
        ((step == TutorialStep.originSwitch &&
              station.id == 'fenyvesliget' && side == RailwaySide.east) ||
         (step == TutorialStep.destinationSwitch &&
              station.id == 'korospatak' && side == RailwaySide.west));
  }

  Widget _signalButton(RailwaySide side, SignalKind kind, String title,
      StationControls c, bool disabled) {
    final green = c.signal(side, kind);
    final focus = kind == SignalKind.entry
        ? HintFocus.entrySignal : HintFocus.exitSignal;
    final highlighted = _showHint && hint!.focus == focus &&
        hint!.side == side;
    final tutorialHighlighted =
        (tutorial?.step == TutorialStep.exitSignal &&
          station.id == 'fenyvesliget' &&
          side == RailwaySide.east && kind == SignalKind.exit) ||
        (tutorial?.step == TutorialStep.entrySignal &&
          station.id == 'korospatak' &&
          side == RailwaySide.west && kind == SignalKind.entry);
    return TutorialTarget(
      active: tutorialHighlighted,
      child: SizedBox(
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
          } else if (!green && tutorialHighlighted) {
            onTutorialAction?.call(kind == SignalKind.exit
                ? TutorialAction.clearedExitSignal
                : TutorialAction.clearedEntrySignal);
          }
        },
        icon: Icon(Icons.circle, color: green ? _mint : _danger, size: 13),
        label: Text(title + ': ' +
              GameL10n.tr(green ? 'SZABAD' : 'MEGÁLLJ'),
            style: const TextStyle(fontSize: 11)),
      ),
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
