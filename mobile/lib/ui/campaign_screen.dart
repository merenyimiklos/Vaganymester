import 'package:flutter/material.dart';

import '../data/session_store.dart';
import '../game/level_catalog.dart';
import 'menu_art.dart';

const _ink = Color(0xFF153C60);
const _muted = Color(0xFF43738B);
const _blue = Color(0xFF186CA3);

/// Fekvő, modern country/level választó. A lezárt szintek nem indíthatók.
class CampaignScreen extends StatefulWidget {
  const CampaignScreen({
    super.key, required this.store,
    required this.onBack, required this.onPlay,
  });
  final SessionStore store;
  final VoidCallback onBack;
  final ValueChanged<GameLevel> onPlay;

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  String selectedCountry = 'hu';

  @override
  Widget build(BuildContext context) {
    final country = LevelCatalog.countries
        .firstWhere((c) => c.code == selectedCountry);
    final progress = widget.store.campaign;
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          const Positioned.fill(
            child: CustomPaint(painter: MenuScenePainter())),
          Positioned.fill(child: Container(
            color: const Color(0xDDF0F9FC))),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(children: [
              _header(),
              const SizedBox(height: 9),
              Expanded(
                child: Row(children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width < 820 ? 185 : 255,
                    child: _countries(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    children: [
                      _countryHeader(country),
                      const SizedBox(height: 8),
                      Expanded(child: _levels(country)),
                    ],
                  )),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _panelDecoration(),
      child: Row(children: [
        IconButton(onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded, color: _blue),
          tooltip: 'Vissza a főmenübe'),
        const Text('ORSZÁGOK ÉS PÁLYÁK',
          style: TextStyle(color: _ink, fontSize: 17,
              fontWeight: FontWeight.w900)),
        const Spacer(),
        const Icon(Icons.emoji_events_rounded,
            color: Color(0xFFF5AE30), size: 24),
        const SizedBox(width: 5),
        Text(widget.store.campaign.totalStars.toString() + '/180',
          style: const TextStyle(color: _ink, fontSize: 15,
              fontWeight: FontWeight.w900)),
        const SizedBox(width: 14),
        const Icon(Icons.flag_rounded, color: _blue),
        const SizedBox(width: 4),
        Text(widget.store.campaign.completedCount.toString() + '/60',
          style: const TextStyle(color: _ink, fontSize: 14,
              fontWeight: FontWeight.w800)),
      ]),
    );
  }

  Widget _countries() {
    final progress = widget.store.campaign;
    return ListView.separated(
      itemCount: LevelCatalog.countries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final country = LevelCatalog.countries[index];
        final selected = selectedCountry == country.code;
        final unlocked = progress.isCountryUnlocked(country);
        final completed = LevelCatalog.inCountry(country.code)
            .where((e) => progress.starsFor(e) > 0).length;
        return Material(
          color: selected
              ? const Color(0xFFBCE9FF)
              : const Color(0xF7FFFFFF),
          elevation: selected ? 5 : 1,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => setState(() => selectedCountry = country.code),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? _blue : const Color(0xFFBBD5E4),
                  width: selected ? 2 : 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(children: [
                Text(country.flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(country.name, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _ink,
                        fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(height: 3),
                    Text(unlocked
                        ? completed.toString() + '/10 pálya'
                        : '🔒 Zárolva',
                      style: const TextStyle(
                          color: _muted, fontSize: 10)),
                  ]),
                )),
                if (selected)
                  const Icon(Icons.chevron_right, color: _blue, size: 18),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _countryHeader(RailwayCountry country) {
    final locked = !widget.store.campaign.isCountryUnlocked(country);
    return Container(
      height: 69,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: _panelDecoration(),
      child: Row(children: [
        Text(country.flag, style: const TextStyle(fontSize: 37)),
        const SizedBox(width: 11),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(country.name,
              style: const TextStyle(color: _ink,
                  fontSize: 18, fontWeight: FontWeight.w900)),
            Text(country.subtitle,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        )),
        if (locked)
          const Chip(
            avatar: Icon(Icons.lock_outline_rounded, size: 17),
            label: Text('Előző ország szükséges'),
          )
        else
          const Chip(
            avatar: Icon(Icons.route_rounded, color: Color(0xFF279E6C)),
            label: Text('10 egyedi szint'),
          ),
      ]),
    );
  }

  Widget _levels(RailwayCountry country) {
    final levels = LevelCatalog.inCountry(country.code);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 790 ? 2 : width < 1100 ? 3 : 4;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: width < 790 ? 1.95 : 1.6,
        mainAxisSpacing: 8, crossAxisSpacing: 8,
      ),
      itemCount: levels.length,
      itemBuilder: (context, i) => _levelTile(levels[i]),
    );
  }

  Widget _levelTile(GameLevel level) {
    final progress = widget.store.campaign;
    final unlocked = progress.isUnlocked(level);
    final won = progress.starsFor(level);
    return Material(
      elevation: unlocked ? 3 : 0,
      color: unlocked ? const Color(0xFFF9FDFF) :
          const Color(0xFFC6D6E0),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: unlocked ? () => _openLevel(level) : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: unlocked ? level.country.color :
                  const Color(0xFFACC3D0), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                CircleAvatar(radius: 15,
                  backgroundColor: unlocked
                      ? level.country.color : const Color(0xFF9FB4C4),
                  child: unlocked
                      ? Text(level.number.toString(),
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w900))
                      : const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 16),
                ),
                const Spacer(),
                if (won > 0)
                  Text(List.filled(won, '⭐').join(),
                    style: const TextStyle(fontSize: 13))
                else if (unlocked)
                  const Icon(Icons.play_circle_fill_rounded,
                      color: Color(0xFF34B36C), size: 24),
              ]),
              Text(level.title, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unlocked ? _ink : const Color(0xFF6B8393),
                  fontSize: 12, fontWeight: FontWeight.w900,
                )),
              Row(children: [
                Text(level.difficultyLabel,
                  style: const TextStyle(color: Color(0xFFEBAC28),
                      fontSize: 13, fontWeight: FontWeight.w900)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                  color: unlocked ? _blue : const Color(0xFF9AB0BF)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _openLevel(GameLevel level) {
    if (!widget.store.campaign.isUnlocked(level)) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF5FCFF),
        title: Row(children: [
          Text(level.country.flag),
          const SizedBox(width: 8),
          Expanded(child: Text(level.title,
              style: const TextStyle(color: _ink, fontSize: 20,
                  fontWeight: FontWeight.w900))),
        ]),
        content: SizedBox(width: 400, child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level.description,
                  style: const TextStyle(color: _muted)),
              const SizedBox(height: 12),
              _info('Nehézség', level.difficultyLabel),
              _info('Különleges kihívás', level.featureLabel),
              _info('Vonatok', level.trainCount.toString()),
              _info('Teljesítendő menetek',
                  level.requiredArrivals.toString()),
              _info('3 csillagos időcél',
                  (level.targetSeconds ~/ 60).toString() + ' perc'),
              const SizedBox(height: 8),
              const Text(
                'Az első teljesítés feloldja a következő pályát. '
                'Az újrajátszással több csillag gyűjthető.',
                style: TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('VISSZA'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onPlay(level);
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('PÁLYA INDÍTÁSA'),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(label,
        style: const TextStyle(color: _muted, fontSize: 13))),
      Text(value, style: const TextStyle(color: _ink,
          fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
  );

  BoxDecoration _panelDecoration() => BoxDecoration(
    color: const Color(0xF7FFFFFF),
    borderRadius: BorderRadius.circular(17),
    border: Border.all(color: Colors.white, width: 2),
    boxShadow: const [BoxShadow(color: Color(0x553F7389),
      blurRadius: 7, offset: Offset(0, 3))],
  );
}
