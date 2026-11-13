import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/railway_game.dart';
import '../game/simulation.dart';
import '../game/level_catalog.dart';
import '../game/help_inventory.dart';
import '../game/help_advisor.dart';
import '../game/tutorial_guide.dart';
import '../game/level_briefing.dart';
import '../l10n/game_l10n.dart';
import '../l10n/level_l10n.dart';
import 'tutorial_coach.dart';
import '../data/session_store.dart';
import 'main_menu.dart';
import 'station_controls_panel.dart';
import 'help_center_sheet.dart';

const _surface = Color(0xFFF6FCFF);
const _muted = Color(0xFF49738D);
const _accent = Color(0xFF167DB0);

class DispatchScreen extends StatefulWidget {
  const DispatchScreen({
    super.key,
    required this.store,
    required this.onExit,
    required this.onNext,
    required this.level,
  });
  final SessionStore store;
  final VoidCallback onExit;
  final ValueChanged<GameLevel> onNext;
  final GameLevel level;

  @override
  State<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends State<DispatchScreen> {
  late final RailwaySimulation simulation;
  late final RailwayGame game;
  String selectedStationId = 'korospatak';
  String? selectedTrainId;
  bool _scoreRecorded = false;
  bool _missionsExpanded = false;
  HelpSuggestion? _activeHint;
  String? _notice;
  Timer? _noticeTimer;
  TutorialGuide? _tutorial;
  bool _tutorialFinishedNotice = false;
  bool _hazardSeen = false;
  bool _hazardShowing = false;

  @override
  void initState() {
    super.initState();
    if (widget.level.id == 'hu-1') _tutorial = TutorialGuide();
    simulation = RailwaySimulation(level: widget.level)
      ..setAutomatic(_tutorial == null ? widget.store.autoDispatch : false)
      ..setRiskMode(widget.store.riskMode)
      ..setMultiplier(widget.store.speed);
    if (_tutorial != null) simulation.setRunning(false);
    simulation.addListener(_onSimulationUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tutorial == null &&
          !widget.store.introducedLevels.contains(widget.level.id)) {
        _showFeatureBriefing();
      }
    });
    game = RailwayGame(
      simulation: simulation,
      onStation: _selectStation,
      onTrain: _selectTrain,
    );
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    simulation.removeListener(_onSimulationUpdate);
    simulation.dispose();
    _tutorial?.dispose();
    super.dispose();
  }

  void _onSimulationUpdate() {
    if (_tutorial?.step == TutorialStep.waitForArrival &&
        simulation.train('S 2412').completedLegs >= 1) {
      _advanceTutorial(TutorialAction.firstArrival);
    }
    if (simulation.hasHazard && !_hazardSeen) {
      _hazardSeen = true;
      _warn(GameL10n.tr('Gyalogos a síneken!'));
    }
    if (_hazardShowing != simulation.hasHazard) {
      _hazardShowing = simulation.hasHazard;
      if (mounted) setState(() {});
    }
    _checkGameOver();
  }

  void _advanceTutorial(TutorialAction action) {
    final guide = _tutorial;
    if (guide == null || !guide.accept(action)) return;
    if (guide.step == TutorialStep.completed &&
        !_tutorialFinishedNotice) {
      _tutorialFinishedNotice = true;
      widget.store.markIntroduced(widget.level);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _warn(GameL10n.tr('Oktatás befejezve!'));
      });
    }
    if (mounted) setState(() {});
  }

  Future<void> _showFeatureBriefing() async {
    if (!mounted) return;
    simulation.setRunning(false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF5FCFF),
        title: Row(children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Color(0xFFE9AB27), size: 29),
          const SizedBox(width: 9),
          Expanded(child: Text(
            LevelBriefing.title(widget.level, widget.store.language),
            style: const TextStyle(color: Color(0xFF174A70),
                fontSize: 19, fontWeight: FontWeight.w900))),
        ]),
        content: SizedBox(
          width: 440,
          child: Text(LevelBriefing.explanation(
              widget.level, widget.store.language),
            style: const TextStyle(color: Color(0xFF2A5873),
                fontSize: 15, height: 1.4)),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(GameL10n.tr('ÉRTEM')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    await widget.store.markIntroduced(widget.level);
    if (mounted && !simulation.gameOver) simulation.setRunning(true);
  }

  void _checkGameOver() {
    if (_scoreRecorded) return;
    if (simulation.levelComplete) {
      _scoreRecorded = true;
      widget.store.finishLevel(
        widget.level, simulation.earnedStars, simulation.score,
      ).then((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showLevelComplete();
        });
      });
      return;
    }
    if (!simulation.gameOver) return;
    _scoreRecorded = true;
    widget.store.recordScore(simulation.score);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showGameOver();
    });
  }

  Future<void> _showLevelComplete() async {
    final stars = simulation.earnedStars;
    final next = LevelCatalog.next(widget.level);
    final unlocked = next != null && widget.store.campaign.isUnlocked(next);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF2FBFF),
        title: Text(widget.level.country.flag + '  ' + GameL10n.tr('PÁLYA TELJESÍTVE!'),
          style: const TextStyle(color: Color(0xFF174A70),
              fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(List.filled(stars, '⭐').join() +
                List.filled(3 - stars, '☆').join(),
              style: const TextStyle(fontSize: 39)),
            const SizedBox(height: 9),
            Text(widget.level.localizedTitle,
              style: const TextStyle(color: Color(0xFF174A70),
                  fontSize: 18, fontWeight: FontWeight.w800)),
            Text(simulation.score.toString() + ' pont • ' +
                  simulation.completedLegs.toString() + ' sikeres menet',
              style: const TextStyle(color: Color(0xFF416D84))),
            const SizedBox(height: 7),
            Text(unlocked ? GameL10n.tr('Új pálya feloldva!') : GameL10n.tr('A kampány végére értél!'),
              style: const TextStyle(color: Color(0xFF2A8E62),
                  fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onExit();
            },
            child: Text(GameL10n.tr('PÁLYAVÁLASZTÓ')),
          ),
          if (unlocked)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onNext(next);
              },
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(GameL10n.tr('KÖVETKEZŐ PÁLYA')),
            ),
        ],
      ),
    );
  }

  Future<void> _showGameOver() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(GameL10n.tr('VÉGE A SZOLGÁLATNAK')),
        content: Text('Elfogytak az életeid. Pontszám: ' +
            simulation.score.toString() +
            '\nAz eredmény bekerült a helyi ranglistába.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _finishShift(save: false);
            },
            child: Text(GameL10n.tr('FŐMENÜ')),
          ),
          FilledButton(
            onPressed: () {
              simulation.newShift();
              _scoreRecorded = false;
              setState(() => selectedTrainId = null);
              Navigator.pop(dialogContext);
            },
            child: Text(GameL10n.tr('ÚJRA')),
          ),
        ],
      ),
    );
  }

  Future<void> _finishShift({bool save = true}) async {
    simulation.setRunning(false);
    if (save && !_scoreRecorded && simulation.score > 0) {
      _scoreRecorded = true;
      await widget.store.recordScore(simulation.score);
    }
    if (mounted) widget.onExit();
  }

  Future<void> _openSettings() async {
    final wasRunning = simulation.running;
    simulation.setRunning(false);
    await showSettings(context, widget.store);
    if (!mounted) return;
    simulation.setAutomatic(_tutorial?.active == true
        ? false : widget.store.autoDispatch);
    simulation.setRiskMode(widget.store.riskMode);
    simulation.setMultiplier(widget.store.speed);
    simulation.setRunning(wasRunning);
    setState(() {});
  }

  void _warn(String message) {
    _noticeTimer?.cancel();
    if (!mounted) return;
    setState(() => _notice = message);
    _noticeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _notice = null);
    });
  }

  void _openHelpCenter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .88,
          child: HelpCenterSheet(
            store: widget.store,
            onUse: _useHelp,
          ),
        ),
      ),
    );
  }

  Future<void> _useHelp(HelpType type) async {
    final hint = const RailwayHelpAdvisor().suggest(
      simulation, type, preferredTrain: selectedTrainId,
    );
    if (hint == null) {
      _warn(simulation.automatic
          ? 'Kézi irányításnál használhatsz segítséget. Kapcsold ki az automatát!'
          : 'Most nincs szabad indulási helyzet. Várd meg, míg felszabadul a pálya!');
      return;
    }
    if (!await widget.store.spendHelp(type)) {
      if (mounted) _warn('Ebből a segítségből most nincs készleted.');
      return;
    }
    if (!mounted) return;
    setState(() {
      selectedTrainId = hint.trainNumber;
      selectedStationId = hint.stationId;
      _activeHint = hint;
    });
    game.highlightTrain(hint.trainNumber);
  }

  void _clearHint() {
    game.highlightTrain(null);
    setState(() => _activeHint = null);
  }

  void _openHintTarget() {
    final hint = _activeHint;
    if (hint == null) return;
    setState(() {
      selectedStationId = hint.stationId;
      selectedTrainId = hint.focus == HintFocus.departure
          ? hint.trainNumber : null;
    });
    _showInfoSheet();
  }

  Widget _hintBanner(bool compact) {
    final hint = _activeHint!;
    return Material(
      color: const Color(0xFFFFF5C9),
      elevation: 8,
      shadowColor: const Color(0xFFFFB833),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFFFBD35), width: 3),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.ads_click_rounded,
            color: Color(0xFFDA8811), size: 25),
          const SizedBox(width: 6),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hint.title, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF68470F),
                  fontWeight: FontWeight.w900, fontSize: 12)),
              Text(hint.detail, maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF735926),
                  fontSize: 10)),
            ],
          )),
          const SizedBox(width: 5),
          TextButton(
            onPressed: _openHintTarget,
            child: const Text('MUTASD',
              style: TextStyle(color: Color(0xFF985B04),
                  fontWeight: FontWeight.w900, fontSize: 10)),
          ),
          IconButton(
            onPressed: _clearHint,
            tooltip: 'Segítség bezárása',
            icon: const Icon(Icons.close_rounded,
              color: Color(0xFF936B30), size: 19),
          ),
        ]),
      ),
    );
  }

  Widget _hazardBanner() {
    final alert = simulation.activeHazard;
    if (alert == null) return const SizedBox.shrink();
    return TutorialTarget(
      active: true,
      child: Material(
        color: const Color(0xFFFFE2E2),
        elevation: 12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDD4354), width: 3),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFC92840), size: 27),
            const SizedBox(width: 7),
            Expanded(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(GameL10n.tr('Gyalogos a síneken!'),
                  style: const TextStyle(color: Color(0xFF9B2339),
                    fontWeight: FontWeight.w900, fontSize: 14)),
                Text(GameL10n.tr(
                  'A vonatok megálltak. Biztosítsd a pályát a folytatáshoz.'),
                  maxLines: 2,
                  style: const TextStyle(color: Color(0xFF763442),
                    fontSize: 10)),
                Text(alert.secondsToRespond.ceil().toString() + ' s',
                  style: const TextStyle(color: Color(0xFFB32B43),
                    fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            )),
            const SizedBox(width: 5),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC82F47)),
              onPressed: () {
                if (simulation.secureHazard()) {
                  _warn(GameL10n.tr('Sikeres beavatkozás: +80 pont'));
                }
              },
              child: Text(GameL10n.tr('BIZTOSÍTOM A PÁLYÁT'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _noticeBanner() {
    return Material(
      elevation: 7,
      color: const Color(0xFF1C5379),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFFFCF65), size: 19),
          const SizedBox(width: 8),
          Flexible(child: Text(_notice!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white,
                fontSize: 12, fontWeight: FontWeight.w700))),
        ]),
      ),
    );
  }


  Future<void> _unsafe(String number) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('KOCKÁZATOS UTASÍTÁS'),
        content: const Text('A foglalt szakaszra történő indítás ütközést '
            'okoz, egy életet és 250 pontot veszíthetsz. Folytatod?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('MÉGSE')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('VESZÉLYES INDÍTÁS')),
        ],
      ),
    );
    if (confirm == true && mounted && !simulation.unsafeDispatch(number)) {
      _warn('Veszélyes indítás csak foglalt szakaszon, kész vonattal lehetséges.');
    }
  }

  void _selectStation(String id) {
    if (_tutorial?.step == TutorialStep.openStationMenu) {
      id = 'fenyvesliget';
      _advanceTutorial(TutorialAction.openedStation);
    }
    setState(() {
      selectedStationId = id;
      selectedTrainId = null;
    });
    _showInfoSheet();
  }

  void _selectTrain(String id) {
    if (_tutorial?.step == TutorialStep.selectTrain && id == 'S 2412') {
      setState(() => selectedTrainId = id);
      _advanceTutorial(TutorialAction.selectedTrain);
      return;
    }
    setState(() => selectedTrainId = id);
    if (MediaQuery.sizeOf(context).width < 1030) _showInfoSheet();
  }

  Future<void> _showInfoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      isScrollControlled: true,
      builder: (context) => Theme(
        data: ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1C8FBA),
            brightness: Brightness.light,
          ),
        ),
        child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.83,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              simulation, if (_tutorial != null) _tutorial!,
            ]),
            builder: (context, _) => _details(),
          ),
        ),
        ),
      ),
    );
    if (mounted && _tutorial?.step == TutorialStep.closeStationMenu) {
      _advanceTutorial(TutorialAction.closedStation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1050 || constraints.maxHeight < 540;
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(child: GameWidget(game: game)),
                ),
                Positioned(
                  left: 8, right: 8, top: 7,
                  child: AnimatedBuilder(
                    animation: simulation,
                    builder: (_, __) => _gameHud(compact),
                  ),
                ),
                Positioned(
                  top: 78, left: 10,
                  child: AnimatedBuilder(
                    animation: simulation,
                    builder: (_, __) => _missions(compact),
                  ),
                ),
                Positioned(
                  right: 10, top: 78,
                  child: AnimatedBuilder(
                    animation: simulation,
                    builder: (_, __) => _tools(compact),
                  ),
                ),
                Positioned(
                  bottom: 76, left: 10,
                  child: AnimatedBuilder(
                    animation: simulation,
                    builder: (_, __) => _selectedCard(compact),
                  ),
                ),
                Positioned(
                  right: 12, bottom: 77,
                  child: _dispatchButton(compact),
                ),
                Positioned(
                  left: 6, bottom: 9,
                  child: _squareAction(
                    icon: Icons.center_focus_strong,
                    tooltip: GameL10n.tr('Térkép középre'),
                    onTap: game.recenter,
                  ),
                ),
                Positioned(
                  left: compact ? 80 : 125,
                  right: compact ? 80 : 125,
                  bottom: 9,
                  child: _navigation(compact),
                ),
                if (_tutorial != null && _tutorial!.active)
                  Positioned(
                    top: compact ? 151 : 84,
                    left: compact ? 204 : 302,
                    right: compact ? 198 : 360,
                    child: TutorialCoach(
                      guide: _tutorial!, compact: compact,
                      onBegin: () {
                        _advanceTutorial(TutorialAction.begin);
                        simulation.setRunning(true);
                      },
                    ),
                  ),
                if (simulation.hasHazard)
                  Positioned(
                    top: compact ? 204 : 205,
                    left: compact ? 200 : 340,
                    right: compact ? 126 : 340,
                    child: AnimatedBuilder(
                      animation: simulation,
                      builder: (_, __) => _hazardBanner(),
                    ),
                  ),
                if (_activeHint != null)
                  Positioned(
                    top: compact ? 139 : 85,
                    left: compact ? 9 : 255,
                    right: compact ? 9 : 420,
                    child: _hintBanner(compact),
                  ),
                if (_notice != null)
                  Positioned(
                    top: _activeHint == null ? 128 : 219,
                    left: compact ? 80 : 305,
                    right: compact ? 80 : 305,
                    child: _noticeBanner(),
                  ),
                if (widget.store.showHints && !compact)
                  Positioned(
                    right: 205, bottom: 92,
                    child: _softTag('↔  ' + GameL10n.tr('Két ujjal nagyítható és mozgatható')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _gameHud(bool compact) {
    return SizedBox(
      height: 59,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _logo(compact),
          const SizedBox(width: 7),
          _statCard(Icons.stars_rounded, GameL10n.tr('PONT'),
              simulation.score.toString(), const Color(0xFFFFCB55)),
          const SizedBox(width: 7),
          _statCard(Icons.favorite_rounded, GameL10n.tr('ÉLET'),
              simulation.lives.toString() + '/3',
              const Color(0xFFFF677A)),
          const SizedBox(width: 7),
          _statCard(Icons.timer_rounded, GameL10n.tr('MŰSZAK'),
              simulation.clock, const Color(0xFF53DCD3)),
          const SizedBox(width: 7),
          _levelCard(),
        ],
      ),
    );
  }

  Widget _logo(bool compact) {
    return _playfulCard(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFFFCF56),
          child: Icon(Icons.train_rounded, color: Color(0xFF174D77), size: 25),
        ),
        const SizedBox(width: 7),
        Text(compact ? 'VÁGÁNY\nMESTER' : 'VÁGÁNYMESTER',
          style: const TextStyle(color: Color(0xFF173F65),
            fontSize: 14, height: 1.05, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _playfulCard({required Widget child, EdgeInsets? padding,
      Color color = const Color(0xFFF7FCFF)}) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          color,
          Color.lerp(color, const Color(0xFF90CAED), .22)!,
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withAlpha(240), width: 2),
        boxShadow: const [BoxShadow(
            color: Color(0x44265370), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: child,
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return _playfulCard(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 31),
        const SizedBox(width: 5),
        Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF4A7194),
                fontSize: 9, fontWeight: FontWeight.w800)),
            Text(value, style: const TextStyle(color: Color(0xFF163B5B),
                fontSize: 16, fontWeight: FontWeight.w900)),
          ]),
      ]),
    );
  }

  Widget _levelCard() {
    final stage = widget.level;
    final progress = (simulation.completedLegs / stage.requiredArrivals)
        .clamp(0.0, 1.0);
    return _playfulCard(
      child: SizedBox(
        width: 132,
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stage.country.flag + ' ' + stage.number.toString() +
                '/10 ' + GameL10n.tr('PÁLYA'),
                style: const TextStyle(color: Color(0xFF184E78),
                    fontWeight: FontWeight.w900, fontSize: 11)),
            const SizedBox(height: 3),
            ClipRRect(borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress, minHeight: 7,
                backgroundColor: const Color(0xFFB2DCE8),
                valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF39DFA8)),
              )),
            const SizedBox(height: 2),
            Text(simulation.completedLegs.toString() + '/' +
                stage.requiredArrivals.toString() + ' ' + GameL10n.tr('menet'),
                style: const TextStyle(color: Color(0xFF406A88),
                    fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _missions(bool compact) {
    final target = widget.level.requiredArrivals;
    final amount = simulation.completedLegs.clamp(0, target);
    return GestureDetector(
      onTap: () => setState(() => _missionsExpanded = !_missionsExpanded),
      child: SizedBox(
        width: compact ? 188 : 228,
        child: _playfulCard(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.fact_check_rounded,
                    color: Color(0xFF2788BB), size: 18),
                const SizedBox(width: 5),
                Expanded(child: Text(GameL10n.tr('MAI FELADATOK'),
                  style: TextStyle(color: Color(0xFF153E62),
                    fontSize: 11, fontWeight: FontWeight.w900))),
                Icon(_missionsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF275A85), size: 19),
              ]),
              const SizedBox(height: 5),
              if (!_missionsExpanded)
                Row(children: [
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: amount / target, minHeight: 7,
                      backgroundColor: const Color(0xFFD2E5F2),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF35CB82)),
                    ),
                  )),
                  const SizedBox(width: 6),
                  Text(amount.toString() + '/' + target.toString(),
                    style: const TextStyle(
                      color: Color(0xFF20537C), fontSize: 11,
                      fontWeight: FontWeight.w900)),
                ])
              else ...[
                const Divider(height: 10),
                _missionRow(GameL10n.tr('Sikeres menetek'), simulation.completedLegs,
                  target, const Color(0xFF31CC83)),
                _missionRow(GameL10n.tr('Gyűjts pontokat'), simulation.score,
                  target * 120, const Color(0xFFFFB93B)),
                _missionRow(GameL10n.tr('Balesetmentes'), 3 - simulation.collisionCount,
                  3, const Color(0xFF459DDF)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _missionRow(String name, int current, int target, Color color) {
    final safe = current.clamp(0, target);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name,
            style: const TextStyle(color: Color(0xFF1F5278),
                fontSize: 10, fontWeight: FontWeight.w700))),
          Text(safe.toString() + '/' + target.toString(),
            style: const TextStyle(color: Color(0xFF153E62),
                fontSize: 10, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 2),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: safe / target, minHeight: 6,
            backgroundColor: const Color(0xFFCFDFE9),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ]),
    );
  }

  Widget _tools(bool compact) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _squareAction(icon: Icons.settings_rounded,
        tooltip: GameL10n.tr('BEÁLLÍTÁSOK'), onTap: _openSettings),
      const SizedBox(width: 5),
      _squareAction(icon: simulation.running
          ? Icons.pause_rounded : Icons.play_arrow_rounded,
        tooltip: GameL10n.tr('Szünet / folytatás'),
        onTap: () => simulation.setRunning(!simulation.running)),
      const SizedBox(width: 5),
      _speedControl(),
      const SizedBox(width: 5),
      _helpAction(),
      const SizedBox(width: 5),
      TutorialTarget(
        active: _tutorial?.step == TutorialStep.enableAutomatic,
        child: _squareAction(icon: simulation.automatic
          ? Icons.smart_toy_rounded : Icons.tune_rounded,
        tooltip: GameL10n.tr('Automatikus / kézi forgalom'),
        onTap: () {
          if (_tutorial?.active == true &&
              _tutorial?.step != TutorialStep.enableAutomatic) {
            _warn(GameL10n.tr('Kövesd a sárgával kiemelt következő lépést!'));
            return;
          }
          simulation.setAutomatic(!simulation.automatic);
          widget.store.setAuto(simulation.automatic);
          if (simulation.automatic) {
            _advanceTutorial(TutorialAction.enabledAutomatic);
          }
        }),
      ),
      if (!compact) ...[
        const SizedBox(width: 5),
        _squareAction(icon: Icons.zoom_in_rounded,
          tooltip: GameL10n.tr('Nagyítás'), onTap: () => game.zoom(1.25)),
        const SizedBox(width: 5),
        _squareAction(icon: Icons.zoom_out_rounded,
          tooltip: GameL10n.tr('Kicsinyítés'), onTap: () => game.zoom(.8)),
      ],
      const SizedBox(width: 5),
      _squareAction(icon: Icons.warning_amber_rounded,
        tooltip: simulation.emergency
            ? 'Resume traffic' : GameL10n.tr('Vészleállítás'),
        danger: simulation.emergency,
        onTap: () => simulation.setEmergency(!simulation.emergency)),
    ]);
  }

  Widget _speedControl() {
    final current = simulation.timeMultiplier;
    return PopupMenuButton<int>(
      tooltip: GameL10n.tr('Játéksebesség') + ': ' + current.toString() + '×',
      initialValue: current,
      onSelected: (next) {
        simulation.setMultiplier(next);
        widget.store.setSpeed(next);
        _warn(GameL10n.tr('Játéksebesség') + ': ' + next.toString() + '×');
      },
      itemBuilder: (_) => [
        for (final speed in const [1, 10, 30, 60])
          PopupMenuItem<int>(
            value: speed,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (speed == current) const Icon(Icons.check_rounded, size: 18),
              const SizedBox(width: 6),
              Text(speed.toString() + '×',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ),
      ],
      child: Container(
        width: 57, height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(
            color: Color(0x55253B61), blurRadius: 5,
            offset: Offset(0, 3))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed_rounded,
              color: Color(0xFF155783), size: 17),
            Text(current.toString() + '×', style: const TextStyle(
              color: Color(0xFF155783), height: 1.1,
              fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _helpAction() {
    final stock = widget.store.helpInventory;
    return Stack(clipBehavior: Clip.none, children: [
      _squareAction(icon: Icons.lightbulb_rounded,
        tooltip: 'Segítségek: ' + stock.totalItems.toString() +
            ', ládák: ' + stock.chests.toString(),
        onTap: _openHelpCenter),
      Positioned(right: -3, top: -5,
        child: Container(
          constraints: const BoxConstraints(minWidth: 20),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            color: stock.chests > 0
              ? const Color(0xFFFFCA43) : const Color(0xFF33BCCD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Text(stock.chests > 0 ? '🎁' : stock.totalItems.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF174A72),
              fontSize: 10, fontWeight: FontWeight.w900)),
        ),
      ),
    ]);
  }

  Widget _squareAction({required IconData icon, required String tooltip,
      required VoidCallback onTap, bool danger = false}) {
    return Tooltip(message: tooltip,
      child: Material(
        color: danger ? const Color(0xFFFFDBE0) : const Color(0xFFE6F6FF),
        borderRadius: BorderRadius.circular(15),
        elevation: 4,
        shadowColor: const Color(0x55253B61),
        child: InkWell(
          borderRadius: BorderRadius.circular(15), onTap: onTap,
          child: Container(
            width: 43, height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(icon, color: danger
                ? const Color(0xFFE54B63) : const Color(0xFF155783),
                size: 25),
          ),
        ),
      ),
    );
  }

  Widget _softTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xCC153D61),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(
        color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _selectedCard(bool compact) {
    final train = _tutorial?.step == TutorialStep.selectTrain
        ? simulation.train('S 2412')
        : selectedTrainId == null
            ? null : simulation.train(selectedTrainId!);
    final learningTrain = _tutorial?.step == TutorialStep.selectTrain;
    return TutorialTarget(
      active: learningTrain,
      child: GestureDetector(
      onTap: () {
        if (learningTrain) {
          _selectTrain('S 2412');
        } else {
          _showInfoSheet();
        }
      },
      child: SizedBox(
        width: compact ? 212 : 264,
        child: _playfulCard(
          padding: const EdgeInsets.all(11),
          child: Row(children: [
            Container(
              width: 44, height: 49,
              decoration: BoxDecoration(
                color: const Color(0xFFCCEAF7),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(train == null
                  ? Icons.holiday_village_rounded
                  : Icons.train_rounded,
                color: const Color(0xFF1B75AB), size: 32),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(train?.number ?? simulation.station(selectedStationId).name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF153E61),
                    fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 3),
                Text(train == null ? GameL10n.tr('Állomásvezérlés megnyitása')
                    : GameL10n.tr(train.moving ? 'ÚTON' : 'INDULÁSRA VÁR'),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF336E82),
                    fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            )),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF1E6DA2)),
          ]),
        ),
      ),
    ),
    );
  }

  Widget _dispatchButton(bool compact) {
    return TutorialTarget(
      active: _tutorial?.step == TutorialStep.departTrain,
      child: Material(
      borderRadius: BorderRadius.circular(23),
      elevation: 8,
      shadowColor: const Color(0x88599C20),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: _dispatchSelected,
        child: Container(
          width: compact ? 139 : 164,
          height: compact ? 54 : 65,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9AF85A), Color(0xFF24BE4B)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(23)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded,
                  color: Color(0xFF135631), size: 32),
              Text('INDÍTÁS', style: TextStyle(
                  color: Color(0xFF135631),
                  fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _navigation(bool compact) {
    final items = <(String, IconData, VoidCallback)>[
      (GameL10n.tr('Hálózat'), Icons.map_rounded, game.recenter),
      (GameL10n.tr('Állomás'), Icons.holiday_village_rounded, () {
        setState(() {
          selectedTrainId = null;
          if (_tutorial?.step == TutorialStep.openStationMenu) {
            selectedStationId = 'fenyvesliget';
          }
        });
        _advanceTutorial(TutorialAction.openedStation);
        _showInfoSheet();
      }),
      (GameL10n.tr('Járatok'), Icons.train_rounded, _showTrainList),
      (GameL10n.tr('Ranglista'), Icons.emoji_events_rounded,
          () => showLeaderboard(context, widget.store)),
      (GameL10n.tr('Menü'), Icons.home_rounded, () => _finishShift()),
    ];
    return Container(
      height: compact ? 53 : 62,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF146DAE), Color(0xFF144A88)]),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFF6FFFF), width: 2),
        boxShadow: const [BoxShadow(
          color: Color(0x88264B66), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(children: [
        for (final item in items)
          Expanded(child: TutorialTarget(
            active: _tutorial?.step == TutorialStep.openStationMenu &&
                item.$1 == GameL10n.tr('Állomás'),
            child: InkWell(
            onTap: item.$3,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: Colors.white,
                    size: compact ? 20 : 24),
                Text(item.$1,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 9 : 11)),
              ],
            ),
          ),
          )),
      ]),
    );
  }

  void _dispatchSelected() {
    if (simulation.levelComplete || simulation.gameOver) return;
    if (_tutorial?.active == true &&
        _tutorial?.step != TutorialStep.departTrain) {
      _warn(GameL10n.tr('Kövesd a sárgával kiemelt következő lépést!'));
      return;
    }
    if (simulation.emergency) {
      _warn('Vészleállítás aktív. Előbb oldd fel!');
      return;
    }
    if (simulation.automatic) {
      _warn('Automata módban a forgalomirányító kezeli az indulásokat.');
      return;
    }
    final available = simulation.trains.where((t) => !t.moving).toList();
    if (available.isEmpty) {
      _warn('Nincs indulásra váró vonat.');
      return;
    }
    final train = selectedTrainId == null
        ? available.first
        : simulation.train(selectedTrainId!);
    if (!simulation.authorize(train.number)) {
      _warn('A vonat nem indítható.');
      return;
    }
    if (train.number == 'S 2412') {
      _advanceTutorial(TutorialAction.dispatchedTrain);
    }
    _warn(train.number + ': indulási engedély rögzítve.');
  }

  void _showTrainList() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFE7F8FF),
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .83,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Text(GameL10n.tr('Járatok'), style: const TextStyle(
              color: Color(0xFF124469),
              fontSize: 19, fontWeight: FontWeight.w900)),
            for (final t in simulation.trains)
              ListTile(
                leading: const Icon(Icons.train_rounded,
                    color: Color(0xFF1A78B4)),
                title: Text(t.number, style: const TextStyle(
                  color: Color(0xFF15486B), fontWeight: FontWeight.bold)),
                subtitle: Text(t.typeLabel,
                    style: const TextStyle(color: Color(0xFF406C80))),
                trailing: const Icon(Icons.chevron_right,
                    color: Color(0xFF15486B)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _selectTrain(t.number);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _details() {
    final train = selectedTrainId == null
        ? null : simulation.train(selectedTrainId!);
    final station = simulation.station(selectedStationId);
    final tutorialSheet = _tutorial != null && _tutorial!.inStation;
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF84BEDB), width: 2)),
      padding: const EdgeInsets.all(10),
      child: Column(children: [
        if (tutorialSheet)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: TutorialCoach(guide: _tutorial!, compact: true)),
        Row(children: [
          Expanded(child: Text(train == null
              ? GameL10n.tr('ÁLLOMÁSI IRÁNYÍTÁS')
              : GameL10n.tr('SZERELVÉNY ADATAI'),
            style: const TextStyle(color: _accent,
              fontWeight: FontWeight.w900, fontSize: 12))),
          TutorialTarget(
            active: _tutorial?.step == TutorialStep.closeStationMenu,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: Text(GameL10n.tr('Hálózat')),
            ),
          ),
        ]),
        if (train == null) ...[
          const SizedBox(height: 7),
          SizedBox(height: 39,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final item in simulation.stations) ...[
                  TutorialTarget(
                    active: _tutorial?.step ==
                        TutorialStep.chooseReceivingStation &&
                        item.id == 'korospatak',
                    child: ChoiceChip(
                      selected: selectedStationId == item.id,
                      label: Text(GameL10n.tr(item.name),
                        style: const TextStyle(fontSize: 11)),
                      onSelected: (_) {
                        setState(() => selectedStationId = item.id);
                        if (item.id == 'korospatak') {
                          _advanceTutorial(TutorialAction.selectedReceiver);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 5),
        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          children: [
            if (train != null) _trainDetails(train)
            else _stationDetails(station),
          ],
        )),
      ]),
    );
  }

  Widget _trainDetails(SimTrain train) {
    final current = simulation.station(train.currentStationId).name;
    final next = simulation.station(train.nextStationId).name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(train.number, style: const TextStyle(
          fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(train.typeLabel, style: const TextStyle(color: _muted)),
        const Divider(height: 24),
        _dataRow(GameL10n.tr('Mozdonyvezető'), train.driver),
        _dataRow(GameL10n.tr('Indulás'), current),
        _dataRow(GameL10n.tr('Következő'), next),
        _dataRow(GameL10n.tr('Sebesség'),
            train.moving ? '${train.speedKmH.round()} km/h' : '0 km/h'),
        _dataRow(GameL10n.tr('Állapot'),
            train.moving ? 'Úton, ${(train.progress * 100).round()}%'
                : GameL10n.tr('Állomáson vár')),
        _dataRow(GameL10n.tr('Teljesített szakaszok'), '${train.completedLegs}'),
        const SizedBox(height: 12),
        if (!simulation.automatic && !train.moving) ...[
          FilledButton.icon(
            onPressed: () {
              if (_tutorial?.active == true &&
                  _tutorial?.step != TutorialStep.departTrain) {
                _warn(GameL10n.tr('Kövesd a sárgával kiemelt következő lépést!'));
                return;
              }
              if (!simulation.authorize(train.number)) {
                _warn(GameL10n.tr('Ez a vonat nem indítható.'));
              } else if (train.number == 'S 2412' &&
                  _tutorial?.step == TutorialStep.departTrain) {
                _advanceTutorial(TutorialAction.dispatchedTrain);
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(GameL10n.tr('Indulás engedélyezése')),
          ),
          if (simulation.riskMode) ...[
            const SizedBox(height: 7),
            OutlinedButton.icon(
              onPressed: () => _unsafe(train.number),
              icon: const Icon(Icons.warning_amber, color: Color(0xFFF16A74)),
              label: Text(GameL10n.tr('KOCKÁZATOS INDÍTÁS')),
            ),
          ],
        ],
        TextButton(
          onPressed: () => setState(() => selectedTrainId = null),
          child: Text(GameL10n.tr('Vissza az állomáshoz')),
        ),
      ],
    );
  }

  Widget _stationDetails(RailwayStation station) =>
      StationControlsPanel(
        simulation: simulation,
        station: station,
        onRejected: _warn,
        hint: _activeHint,
        tutorial: _tutorial,
        onTutorialAction: _advanceTutorial,
        onAutomatic: (enabled) {
          simulation.setAutomatic(enabled);
          widget.store.setAuto(enabled);
        },
      );

  Widget _dataRow(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
                fontSize: 11, color: _muted)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );

}
