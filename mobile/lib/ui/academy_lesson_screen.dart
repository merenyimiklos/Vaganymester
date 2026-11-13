import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/session_store.dart';
import '../game/academy_lesson.dart';
import '../game/railway_game.dart';
import '../game/simulation.dart';
import '../services/audio_service.dart';
import 'game_alert.dart';
import 'help_center_sheet.dart';
import 'station_controls_panel.dart';
import 'tutorial_coach.dart';

/// One lesson = one real, isolated RailwaySimulation with specific actions.
/// The Academy never modifies campaign scores, stars or station unlocks.
class AcademyLessonScreen extends StatefulWidget {
  const AcademyLessonScreen({super.key, required this.lesson,
    required this.store, required this.audio, required this.onBack,
    required this.onComplete});
  final AcademyLesson lesson;
  final SessionStore store;
  final GameAudio audio;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<AcademyLessonScreen> createState() => _AcademyLessonScreenState();
}
class _AcademyLessonScreenState extends State<AcademyLessonScreen> {
  late final RailwaySimulation sim;
  late final RailwayGame game;
  late final AcademyStepProgress progress;
  String selectedStation = 'korospatak';
  SimTrain? selectedTrain;
  bool _completed = false;
  int _lastLegs = 0;
  bool _lastMoving = false;
  String? _message;
  Timer? _messageTimer;

  String t(String hu, String en, String de) =>
    switch (widget.store.language) {
      'en' => en, 'de' => de, _ => hu,
    };

  @override
  void initState() {
    super.initState();
    progress = AcademyStepProgress(widget.lesson);
    sim = RailwaySimulation(level: widget.lesson.simulatorLevel)
      ..incidentsEnabled = widget.lesson.index == 7
      ..setAutomatic(false)
      ..setMultiplier(1);
    if (widget.lesson.index == 0) {
      sim.train('S 2412').readyAt = 0;
      sim.train('S 2412').platformTrack = 1;
    }
    if (widget.lesson.index == 7) {
      sim.elapsedSeconds = 35;
      sim.tick(.2);
    }
    if (widget.lesson.index == 8) {
      unawaited(widget.store.grantAcademyDemoChest());
    }
    sim.addListener(_simulationUpdate);
    game = RailwayGame(
      simulation: sim,
      onStation: _selectStation,
      onTrain: _selectTrain,
    );
    widget.audio.showGame();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    sim.removeListener(_simulationUpdate);
    sim.dispose();
    widget.audio.setMoving(false);
    super.dispose();
  }

  void _simulationUpdate() {
    if (_completed) return;
    final moving = sim.movingCount > 0;
    if (moving != _lastMoving) {
      _lastMoving = moving;
      widget.audio.setMoving(moving);
      if (moving) unawaited(widget.audio.horn());
    }
    if (sim.completedLegs > _lastLegs) {
      _lastLegs = sim.completedLegs;
      if (widget.lesson.index == 0 &&
          sim.train('S 2412').completedLegs > 0) {
        _accept(AcademyAction.trainArrived);
      }
      if (widget.lesson.index == 9) {
        _accept(AcademyAction.automaticArrival);
      }
    }
  }

  void _accept(AcademyAction action) {
    if (_completed || !progress.accept(action)) return;
    widget.audio.haptic(HapticStyle.tap);
    if (progress.done) {
      _completed = true;
      sim.setRunning(false);
      widget.audio.setMoving(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onComplete();
      });
    }
    if (mounted) setState(() {});
  }

  void _warn(String text) {
    _messageTimer?.cancel();
    if (!mounted) return;
    setState(() => _message = text);
    widget.audio.haptic(HapticStyle.warning);
    _messageTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _message = null);
    });
  }

  void _selectStation(String id) {
    if (widget.lesson.index == 2) {
      selectedStation = id;
      if (id == 'korospatak') {
        _accept(AcademyAction.selectStation);
      }
    }
    selectedStation = id;
    setState(() {});
    _showStation();
  }

  void _selectTrain(String number) {
    final candidate = sim.train(number);
    setState(() => selectedTrain = candidate);
    if (candidate.kind == TrainKind.intercity) {
      _accept(AcademyAction.selectIntercity);
    }
    if (candidate.kind == TrainKind.freight) {
      _accept(AcademyAction.selectFreight);
    }
    if (widget.lesson.index == 6) {
      _accept(AcademyAction.selectNightTrain);
    }
  }

  Future<void> _showStation() async {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFFF3FAFF),
      builder: (ctx) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .88,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: StationControlsPanel(
            simulation: sim,
            station: sim.station(selectedStation),
            onRejected: _warn,
            onAutomatic: (_) {},
          ),
        ),
      )),
    );
    if (mounted) setState(() {});
  }

  Future<void> _helpLesson() async {
    if (progress.expected != AcademyAction.openHelp) return;
    _accept(AcademyAction.openHelp);
    final before = widget.store.helpInventory.opened;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFFF3FAFF),
      builder: (_) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .83,
        child: HelpCenterSheet(store: widget.store, onUse: (_) {}),
      )),
    );
    if (!mounted) return;
    if (widget.store.helpInventory.opened > before) {
      _accept(AcademyAction.openChest);
    } else {
      _warn(t('Nyiss ki egy ládát a folytatáshoz!',
        'Open a chest to continue!', 'Öffne eine Kiste zum Fortfahren!'));
    }
  }

  Widget _action(String label, VoidCallback onTap, {
    IconData icon = Icons.ads_click_rounded,
    Color color = const Color(0xFF42D48A),
  }) => TutorialTarget(
    active: true,
    child: Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF174F59), size: 23),
              const SizedBox(width: 7),
              Flexible(child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xFF104459), fontWeight: FontWeight.w900,
                  fontSize: 14))),
            ]),
        ),
      ),
    ),
  );

  Widget _nextAction() {
    final expected = progress.expected;
    if (expected == null) return const CircularProgressIndicator();
    final west = RailwaySide.west, east = RailwaySide.east;
    switch(expected) {
      case AcademyAction.setOriginTurnout:
        return _action(t('Fenyvesliget – keleti váltó → 2.',
          'Pine Grove – east switch → 2', 'Fichtenhain – Ostweiche → 2'),
          () {
            if (sim.setTurnout('fenyvesliget', east, 1)) {
              _accept(expected);
            } else {_warn('A váltó jelenleg nem állítható.');}
          }, icon: Icons.alt_route_rounded);
      case AcademyAction.clearExit:
        return _action(t('Keleti kijárati jelző: SZABAD',
          'East exit signal: CLEAR', 'Ost-Ausfahrsignal: FREI'),
          () {
            if (sim.setSignal('fenyvesliget', east, SignalKind.exit, true)) {
              _accept(expected);
            } else {_warn('A jelző nem állítható szabadra.');}
          }, icon: Icons.traffic_rounded);
      case AcademyAction.setArrivalTurnout:
        final platform = widget.lesson.index == 2 ? 2 : 1;
        return _action(t('Kőröspatak – nyugati váltó → ',
            'Creek Junction – west switch → ',
            'Bachkreuz – Westweiche → ') + (platform + 1).toString(),
          () {
            if (sim.setTurnout('korospatak', west, platform)) {
              _accept(expected);
            } else {_warn('A vágány foglalt vagy lezárt.');}
          }, icon: Icons.alt_route_rounded);
      case AcademyAction.clearEntry:
        return _action(t('Nyugati bejárati jelző: SZABAD',
          'West entry signal: CLEAR', 'West-Einfahrsignal: FREI'),
          () {
            if (sim.setSignal('korospatak', west, SignalKind.entry, true)) {
              _accept(expected);
            } else {_warn('A jelző nem állítható szabadra.');}
          }, icon: Icons.traffic_rounded);
      case AcademyAction.authorize:
        return _action(t('S 2412 – INDÍTÁSI ENGEDÉLY',
          'S 2412 – AUTHORIZE DEPARTURE',
          'S 2412 – ABFAHRT FREIGEBEN'), () {
            if (sim.authorize('S 2412')) {
              sim.setMultiplier(60);
              _accept(expected);
            } else { _warn('Nem adható indulási engedély.'); }
          }, icon: Icons.play_circle_fill_rounded);
      case AcademyAction.trainArrived:
        return _waiting(Icons.train_rounded,
          t('A vonat úton van. Figyeld a megérkezését!',
            'Train is moving. Wait for arrival!',
            'Der Zug ist unterwegs. Warte auf die Ankunft!'));
      case AcademyAction.changeSpeed:
        final target = widget.lesson.index == 6 ? 1 : 10;
        return _action(t('Sebesség beállítása: ',
          'Set speed to ', 'Tempo einstellen: ') + target.toString() + '×',
          () {
            sim.setMultiplier(target);
            _accept(expected);
          }, icon: Icons.speed_rounded);
      case AcademyAction.pause:
        return _action(t('SZÜNET', 'PAUSE', 'PAUSE'),
          () {sim.setRunning(false); _accept(expected);},
          icon: Icons.pause_circle_rounded);
      case AcademyAction.resume:
        return _action(t('FOLYTATÁS', 'RESUME', 'FORTSETZEN'),
          () {sim.setRunning(true); _accept(expected);},
          icon: Icons.play_arrow_rounded);
      case AcademyAction.selectStation:
        return _action(t('Kőröspatak állomás kiválasztása',
          'Select Creek Junction station',
          'Bahnhof Bachkreuz auswählen'),
          () {selectedStation='korospatak'; _accept(expected); _showStation();},
          icon: Icons.holiday_village_rounded);
      case AcademyAction.closeLine:
        return _action(t('FV–KP szakasz LEZÁRÁSA', 'CLOSE FV–KP line',
          'Strecke FV–KP SPERREN'), () {
            if (sim.setSectionClosed('FV-KP',true)) _accept(expected);
            else _warn('A pályaszakasz foglalt.');
          }, icon: Icons.block_rounded);
      case AcademyAction.reopenLine:
        return _action(t('FV–KP szakasz FELOLDÁSA',
          'REOPEN FV–KP line', 'Strecke FV–KP FREIGEBEN'), () {
            if (sim.setSectionClosed('FV-KP',false)) _accept(expected);
          }, icon: Icons.lock_open_rounded);
      case AcademyAction.selectIntercity:
        return _trainChoices(TrainKind.intercity);
      case AcademyAction.selectFreight:
        return _trainChoices(TrainKind.freight);
      case AcademyAction.selectNightTrain:
        return _trainChoices(null);
      case AcademyAction.resolveIncident:
        if (!sim.hasHazard) {
          return _action(t('Vészhelyzet újrajátszása',
            'Retry emergency scenario', 'Gefahrensituation wiederholen'),
            () {
              sim.newShift();
              sim.elapsedSeconds = 35;
              sim.tick(.2);
              setState(() {});
            }, icon: Icons.refresh_rounded);
        }
        return _action(t('VESZÉLY! PÁLYA BIZTOSÍTÁSA',
          'HAZARD! SECURE TRACK', 'GEFAHR! GLEIS SICHERN'), () {
            if (sim.secureHazard()) {
              _accept(expected);
            } else {_warn('Nincs aktív veszélyhelyzet.');}
          }, icon: Icons.health_and_safety_rounded,
            color: const Color(0xFFFFB5A8));
      case AcademyAction.openHelp:
        return _action(t('SEGÍTSÉGEK MEGNYITÁSA',
          'OPEN HINT CENTER', 'HILFE ÖFFNEN'), _helpLesson,
            icon: Icons.lightbulb_rounded);
      case AcademyAction.openChest:
        return _action(t('LÁDA MEGNYITÁSA',
            'OPEN A CHEST', 'KISTE ÖFFNEN'), () async {
          final before = widget.store.helpInventory.opened;
          await showModalBottomSheet<void>(
            context: context, isScrollControlled: true,
            backgroundColor: const Color(0xFFF3FAFF),
            builder: (_) => SafeArea(child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .83,
              child: HelpCenterSheet(store: widget.store, onUse: (_) {}),
            )),
          );
          if (!mounted) return;
          if (widget.store.helpInventory.opened > before) {
            _accept(AcademyAction.openChest);
          } else { _warn('Nyiss ki egy ládát!'); }
        }, icon: Icons.card_giftcard_rounded);
      case AcademyAction.enableAuto:
        return _action(t('AUTOMATA IRÁNYÍTÁS BEKAPCSOLÁSA',
          'ENABLE AUTO DISPATCH', 'AUTOMATIK AKTIVIEREN'), () {
            sim.setMultiplier(60);
            sim.setAutomatic(true);
            _accept(expected);
          }, icon: Icons.smart_toy_rounded);
      case AcademyAction.automaticArrival:
        return _waiting(Icons.tips_and_updates_rounded,
          t('Az automata állítja a váltókat. Várd meg az érkezést!',
            'Auto dispatch is in control. Wait for one arrival!',
            'Die Automatik steuert die Weichen. Warte auf die Ankunft!'));
    }
  }

  Widget _trainChoices(TrainKind? type) {
    final options = sim.trains.where((train) =>
        type == null || train.kind == type).toList();
    return Column(children: [
      for (final train in options.take(3))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _action(
            train.number + ' • ' + train.typeLabel +
                ' • ' + train.speedKmH.round().toString() + ' km/h',
            () => _selectTrain(train.number),
            icon: Icons.train_rounded)),
    ]);
  }

  Widget _waiting(IconData icon, String message) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: const Color(0xFFE1F4FF),
      borderRadius: BorderRadius.circular(15)),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF247CB7)),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: const TextStyle(
        color: Color(0xFF255F83), fontSize: 12,
        fontWeight: FontWeight.w800))),
      const SizedBox(width: 8),
      const SizedBox(width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 2)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      backgroundColor: const Color(0xFFBFEFFF),
      body: SafeArea(child: LayoutBuilder(builder: (context, limits) {
        final panelWidth = (limits.maxWidth * .43).clamp(275.0, 415.0).toDouble();
        return Row(children: [
          SizedBox(width: panelWidth,
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: LinearGradient(
                colors: [Color(0xFFEAFBFF), Color(0xFFC9E9F9)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 7),
                  color: const Color(0xFF16699C),
                  child: Row(children: [
                    IconButton(onPressed: widget.onBack,
                      tooltip: t('Vissza', 'Back', 'Zurück'),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 21)),
                    Expanded(child: Text(
                      t('AKADÉMIA', 'ACADEMY', 'AKADEMIE') +
                        ' ' + (lesson.index + 1).toString() + '/10',
                      style: const TextStyle(color: Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w900))),
                    const Icon(Icons.stars_rounded,
                      color: Color(0xFFFFD568)),
                  ]),
                ),
                Expanded(child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Text(lesson.icon + ' ' + lesson.name(widget.store.language),
                      style: const TextStyle(
                        color: Color(0xFF163C5B), fontSize: 20,
                        fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(lesson.detail(widget.store.language),
                      style: const TextStyle(color: Color(0xFF396A84),
                        fontSize: 13, height: 1.35)),
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(11),
                      child: LinearProgressIndicator(
                        value: progress.step / progress.count,
                        minHeight: 9,
                        color: const Color(0xFF39C98C),
                        backgroundColor: Colors.white)),
                    const SizedBox(height: 8),
                    Text(t('FELADAT', 'YOUR TASK', 'DEINE AUFGABE') + ' ' +
                        (progress.step + 1).toString() + '/' +
                        progress.count.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1B699A),
                        fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(height: 16),
                    _nextAction(),
                    const SizedBox(height: 15),
                    if (_message != null)
                      GameAlertCard(message: _message!,
                        style: GameAlertStyle.warning,
                        onClose: () => setState(() => _message = null)),
                    const SizedBox(height: 10),
                    Text(t('A gombok a valódi szimulációt irányítják. '
                      'A térképen csippentve nagyíthatsz.',
                      'These controls operate the actual simulator. '
                      'Pinch the map to zoom.',
                      'Diese Tasten steuern die echte Simulation. '
                      'Zoome mit zwei Fingern.'),
                      style: const TextStyle(color: Color(0xFF688B9E),
                        fontSize: 11)),
                  ]),
                ),
              ]),
            ),
          ),
          Expanded(child: Stack(children: [
            Positioned.fill(child: GameWidget(game: game)),
            Positioned(top: 9, right: 10,
              child: AnimatedBuilder(animation: sim,
                builder: (_, __) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xF5F6FBFF),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white, width: 2)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB92A)),
                    Text(sim.score.toString() + '   ' +
                        sim.clock + '   ' +
                        sim.timeMultiplier.toString() + '×',
                      style: const TextStyle(color: Color(0xFF164E75),
                        fontSize: 12, fontWeight: FontWeight.w900)),
                  ]),
                )),
            ),
            if (selectedTrain != null)
              Positioned(left: 10, bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xF5F7FDFF),
                    borderRadius: BorderRadius.circular(13)),
                  child: Text(selectedTrain!.number + '  •  ' +
                    selectedTrain!.speedKmH.round().toString() + ' km/h',
                    style: const TextStyle(color: Color(0xFF164A70),
                      fontWeight: FontWeight.w900, fontSize: 12)))),
            Positioned(right: 10, bottom: 12,
              child: Material(
                color: const Color(0xFFEAFBFF),
                borderRadius: BorderRadius.circular(16),
                child: IconButton(onPressed: game.recenter,
                  tooltip: t('Térkép középre', 'Center map',
                    'Karte zentrieren'),
                  icon: const Icon(Icons.center_focus_strong_rounded,
                    color: Color(0xFF1C6088)))),
            ),
            if (sim.hasHazard)
              Positioned(top: 66, left: 10, right: 10,
                child: AnimatedBuilder(animation: sim, builder: (_, __) =>
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE1E1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFE24A57), width: 2)),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFB7323F), size: 25),
                      const SizedBox(width: 9),
                      Expanded(child: Text(
                        t('Gyalogos a síneken!', 'Pedestrian on the track!',
                            'Person auf den Gleisen!'),
                        style: const TextStyle(color: Color(0xFF862B37),
                          fontWeight: FontWeight.w900))),
                      Text(sim.activeHazard!.secondsToRespond
                          .ceil().toString() + ' s',
                        style: const TextStyle(color: Color(0xFF862B37),
                          fontWeight: FontWeight.w900)),
                    ]),
                  ))),
          ])),
        ]);
      })),
    );
  }
}
