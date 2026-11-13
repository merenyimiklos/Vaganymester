import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/railway_game.dart';
import '../game/simulation.dart';
import '../game/level_catalog.dart';
import '../data/session_store.dart';
import 'main_menu.dart';
import 'station_controls_panel.dart';

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

  @override
  void initState() {
    super.initState();
    simulation = RailwaySimulation(level: widget.level)
      ..setAutomatic(widget.store.autoDispatch)
      ..setRiskMode(widget.store.riskMode)
      ..setMultiplier(widget.store.speed);
    simulation.addListener(_checkGameOver);
    game = RailwayGame(
      simulation: simulation,
      onStation: _selectStation,
      onTrain: _selectTrain,
    );
  }

  @override
  void dispose() {
    simulation.removeListener(_checkGameOver);
    simulation.dispose();
    super.dispose();
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
        title: Text(widget.level.country.flag + '  PÁLYA TELJESÍTVE!',
          style: const TextStyle(color: Color(0xFF174A70),
              fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(List.filled(stars, '⭐').join() +
                List.filled(3 - stars, '☆').join(),
              style: const TextStyle(fontSize: 39)),
            const SizedBox(height: 9),
            Text(widget.level.title,
              style: const TextStyle(color: Color(0xFF174A70),
                  fontSize: 18, fontWeight: FontWeight.w800)),
            Text(simulation.score.toString() + ' pont • ' +
                  simulation.completedLegs.toString() + ' sikeres menet',
              style: const TextStyle(color: Color(0xFF416D84))),
            const SizedBox(height: 7),
            Text(unlocked ? 'Új pálya feloldva!' : 'A kampány végére értél!',
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
            child: const Text('PÁLYAVÁLASZTÓ'),
          ),
          if (unlocked)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onNext(next!);
              },
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('KÖVETKEZŐ PÁLYA'),
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
        title: const Text('VÉGE A SZOLGÁLATNAK'),
        content: Text('Elfogytak az életeid. Pontszám: ' +
            simulation.score.toString() +
            '\nAz eredmény bekerült a helyi ranglistába.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _finishShift(save: false);
            },
            child: const Text('FŐMENÜ'),
          ),
          FilledButton(
            onPressed: () {
              simulation.newShift();
              _scoreRecorded = false;
              setState(() => selectedTrainId = null);
              Navigator.pop(dialogContext);
            },
            child: const Text('ÚJRA'),
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
    await showSettings(context, widget.store);
    if (!mounted) return;
    simulation.setAutomatic(widget.store.autoDispatch);
    simulation.setRiskMode(widget.store.riskMode);
    simulation.setMultiplier(widget.store.speed);
  }

  void _warn(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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
    setState(() {
      selectedStationId = id;
      selectedTrainId = null;
    });
    _showInfoSheet();
  }

  void _selectTrain(String id) {
    setState(() => selectedTrainId = id);
    if (MediaQuery.sizeOf(context).width < 1030) _showInfoSheet();
  }

  void _showInfoSheet() {
    showModalBottomSheet<void>(
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
            animation: simulation,
            builder: (context, _) => _details(),
          ),
        ),
        ),
      ),
    );
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
                    tooltip: 'Térkép középre',
                    onTap: game.recenter,
                  ),
                ),
                Positioned(
                  left: compact ? 80 : 125,
                  right: compact ? 80 : 125,
                  bottom: 9,
                  child: _navigation(compact),
                ),
                if (widget.store.showHints && !compact)
                  Positioned(
                    right: 205, bottom: 92,
                    child: _softTag('↔  Két ujjal nagyítható és mozgatható'),
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
          _statCard(Icons.stars_rounded, 'PONT',
              simulation.score.toString(), const Color(0xFFFFCB55)),
          const SizedBox(width: 7),
          _statCard(Icons.favorite_rounded, 'ÉLET',
              simulation.lives.toString() + '/3',
              const Color(0xFFFF677A)),
          const SizedBox(width: 7),
          _statCard(Icons.timer_rounded, 'MŰSZAK',
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
                '/10 PÁLYA',
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
                stage.requiredArrivals.toString() + ' menet',
                style: const TextStyle(color: Color(0xFF406A88),
                    fontSize: 9, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _missions(bool compact) {
    final height = compact ? 125.0 : 151.0;
    return SizedBox(
      width: compact ? 194 : 238,
      height: height,
      child: _playfulCard(
        padding: const EdgeInsets.fromLTRB(9, 9, 9, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.fact_check_rounded, color: Color(0xFF2788BB),
                size: 20),
              SizedBox(width: 6),
              Text('MAI FELADATOK',
                style: TextStyle(color: Color(0xFF153E62),
                    fontSize: 12, fontWeight: FontWeight.w900)),
            ]),
            const Divider(height: 10),
            _missionRow('Sikeres menetek', simulation.completedLegs,
                widget.level.requiredArrivals,
                const Color(0xFF31CC83)),
            _missionRow('Gyűjts pontokat', simulation.score,
                widget.level.requiredArrivals * 120,
                const Color(0xFFFFB93B)),
            if (!compact)
              _missionRow('Balesetmentes', 3 - simulation.collisionCount, 3,
                  const Color(0xFF459DDF)),
          ],
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
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _squareAction(icon: Icons.settings_rounded,
          tooltip: 'Beállítások', onTap: _openSettings),
      const SizedBox(height: 7),
      _squareAction(icon: simulation.running
          ? Icons.pause_rounded : Icons.play_arrow_rounded,
        tooltip: 'Szünet / Indítás',
        onTap: () => simulation.setRunning(!simulation.running)),
      const SizedBox(height: 7),
      _squareAction(icon: Icons.speed_rounded,
        tooltip: 'Sebesség: ' + simulation.timeMultiplier.toString() + '×',
        onTap: () {
          const speeds = [1, 10, 30, 60];
          final idx = speeds.indexOf(simulation.timeMultiplier);
          final next = speeds[(idx + 1) % speeds.length];
          simulation.setMultiplier(next);
          widget.store.setSpeed(next);
          _warn('Szimulációs sebesség: ' + next.toString() + '×');
        }),
      const SizedBox(height: 7),
      if (!compact) ...[
        _squareAction(icon: simulation.automatic
            ? Icons.smart_toy_rounded : Icons.tune_rounded,
          tooltip: 'Automatikus / Kézi forgalom',
          onTap: () {
            simulation.setAutomatic(!simulation.automatic);
            widget.store.setAuto(simulation.automatic);
          }),
        const SizedBox(height: 7),
        const SizedBox(height: 7),
        _squareAction(icon: Icons.zoom_in_map_rounded,
            tooltip: 'Nagyítás', onTap: () => game.zoom(1.25)),
        const SizedBox(height: 7),
        _squareAction(icon: Icons.zoom_out_map_rounded,
            tooltip: 'Kicsinyítés', onTap: () => game.zoom(.8)),
      ],
      const SizedBox(height: 7),
      _squareAction(icon: Icons.warning_amber_rounded,
        tooltip: simulation.emergency ? 'Vészleállítás feloldása' :
            'Vészleállítás',
        danger: simulation.emergency,
        onTap: () => simulation.setEmergency(!simulation.emergency)),
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
    final train = selectedTrainId == null
        ? null : simulation.train(selectedTrainId!);
    return GestureDetector(
      onTap: _showInfoSheet,
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
                Text(train == null ? 'Állomásvezérlés megnyitása'
                    : (train.moving ? 'ÚTON' : 'INDULÁSRA VÁR'),
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
    );
  }

  Widget _dispatchButton(bool compact) {
    return Material(
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded,
                  color: Color(0xFF135631), size: 32),
              Text('INDÍTÁS', style: TextStyle(
                  color: Color(0xFF135631),
                  fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigation(bool compact) {
    final items = <(String, IconData, VoidCallback)>[
      ('Hálózat', Icons.map_rounded, game.recenter),
      ('Állomás', Icons.holiday_village_rounded, () {
        setState(() => selectedTrainId = null);
        _showInfoSheet();
      }),
      ('Járatok', Icons.train_rounded, _showTrainList),
      ('Ranglista', Icons.emoji_events_rounded,
          () => showLeaderboard(context, widget.store)),
      ('Menü', Icons.home_rounded, () => _finishShift()),
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
          Expanded(child: InkWell(
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
          )),
      ]),
    );
  }

  void _dispatchSelected() {
    if (simulation.levelComplete || simulation.gameOver) return;
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
            const Text('JÁRATOK', style: TextStyle(
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
        ? null
        : simulation.train(selectedTrainId!);
    final station = simulation.station(selectedStationId);
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF84BEDB), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            train == null ? 'ÁLLOMÁSI IRÁNYÍTÁS' : 'SZERELVÉNY ADATAI',
            style: const TextStyle(
              color: _accent, fontWeight: FontWeight.w700,
              fontSize: 11, letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          if (train != null) _trainDetails(train)
          else _stationDetails(station),
        ],
      ),
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
        _dataRow('Mozdonyvezető', train.driver),
        _dataRow('Indulás', current),
        _dataRow('Következő', next),
        _dataRow('Sebesség',
            train.moving ? '${train.speedKmH.round()} km/h' : '0 km/h'),
        _dataRow('Állapot',
            train.moving ? 'Úton, ${(train.progress * 100).round()}%'
                : 'Állomáson vár'),
        _dataRow('Teljesített szakaszok', '${train.completedLegs}'),
        const SizedBox(height: 12),
        if (!simulation.automatic && !train.moving) ...[
          FilledButton.icon(
            onPressed: () {
              if (!simulation.authorize(train.number)) {
                _warn('Ez a vonat nem indítható.');
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Indulás engedélyezése'),
          ),
          if (simulation.riskMode) ...[
            const SizedBox(height: 7),
            OutlinedButton.icon(
              onPressed: () => _unsafe(train.number),
              icon: const Icon(Icons.warning_amber, color: Color(0xFFF16A74)),
              label: const Text('KOCKÁZATOS INDÍTÁS'),
            ),
          ],
        ],
        TextButton(
          onPressed: () => setState(() => selectedTrainId = null),
          child: const Text('Vissza az állomáshoz'),
        ),
      ],
    );
  }

  Widget _stationDetails(RailwayStation station) =>
      StationControlsPanel(
        simulation: simulation,
        station: station,
        onRejected: _warn,
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
