import 'package:flutter/material.dart';
import '../data/session_store.dart';
import '../game/academy_lesson.dart';
import '../game/academy_progress.dart';
import '../services/audio_service.dart';
import 'academy_lesson_screen.dart';

/// Progress hub before the normal country campaign. A deliberate "skip"
/// unlocks gameplay without awarding training points.
class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key, required this.store, required this.audio,
    required this.onBack, required this.onCampaign});
  final SessionStore store;
  final GameAudio audio;
  final VoidCallback onBack;
  final VoidCallback onCampaign;
  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}
class _AcademyScreenState extends State<AcademyScreen> {
  int? _playing;

  Future<void> _complete(int index) async {
    final reward = await widget.store.completeAcademyLesson(index);
    if (!mounted) return;
    await widget.audio.success();
    if (!mounted) return;
    final finished = widget.store.academy.graduated;
    final chosen = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2FCFF),
        title: Row(children: [
          const Icon(Icons.emoji_events_rounded,
            color: Color(0xFFF4B937), size: 31),
          const SizedBox(width: 9),
          Expanded(child: Text(finished
            ? _t('Sikeres vizsga!', 'Graduated!', 'Prüfung bestanden!')
            : _t('Tanulópálya kész!', 'Lesson complete!',
                'Lektion abgeschlossen!'),
            style: const TextStyle(color: Color(0xFF17466C),
              fontWeight: FontWeight.w900))),
        ]),
        content: Text(_t('Jutalom: +', 'Reward: +', 'Belohnung: +') +
            reward.toString() + ' ' +
            _t('oktatópont. Az egyenleged: ', 'academy points. Balance: ',
                'Lernpunkte. Kontostand: ') +
            widget.store.academy.points.toString(),
          style: const TextStyle(color: Color(0xFF285679),
            fontSize: 17, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text(_t('PÁLYALISTA', 'LESSON LIST', 'LEKTIONSLISTE'))),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(finished ? _t('JÁTÉK INDÍTÁSA', 'PLAY', 'SPIELEN')
                : _t('KÖVETKEZŐ', 'NEXT', 'WEITER')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (finished && chosen == true) {
      widget.onCampaign();
      return;
    }
    if (chosen != true) widget.audio.showMenu();
    setState(() {
      final next = widget.store.academy.nextLesson;
      _playing = chosen == true && next < AcademyProgress.lessonCount
          ? next : null;
    });
  }

  Future<void> _skip() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_t('Kihagyod az oktatást?', 'Skip training?',
            'Training überspringen?')),
        content: Text(_t(
          'A játék azonnal megnyílik, de kihagyásért nem jár pont. '
          'Később bármikor visszatérhetsz az Akadémiára.',
          'You can play immediately, but skipping gives no reward. '
          'You can return to the Academy later.',
          'Du kannst sofort spielen, aber Überspringen gibt keine '
          'Punkte. Die Akademie bleibt jederzeit erreichbar.',
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text(_t('MÉGSE', 'CANCEL', 'ABBRECHEN'))),
          FilledButton(onPressed: () => Navigator.pop(context, true),
            child: Text(_t('KIHAGYOM', 'SKIP', 'ÜBERSPRINGEN'))),
        ],
      ),
    );
    if (yes != true) return;
    await widget.store.skipAcademy();
    if (mounted) widget.onCampaign();
  }

  String _t(String hu, String en, String de) =>
      switch (widget.store.language) {
        'en' => en, 'de' => de, _ => hu,
      };

  @override
  Widget build(BuildContext context) {
    if (_playing != null) {
      return AcademyLessonScreen(
        key: ValueKey(_playing),
        lesson: AcademyLesson.all[_playing!],
        store: widget.store, audio: widget.audio,
        onBack: () {
          widget.audio.showMenu();
          setState(() => _playing = null);
        },
        onComplete: () => _complete(_playing!),
      );
    }
    final progress = widget.store.academy;
    return Scaffold(
      backgroundColor: const Color(0xFFB9EFFF),
      body: SafeArea(child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [
            Color(0xFF1579B3), Color(0xFF153E81)])),
          child: Row(children: [
            IconButton(onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white)),
            const Text('🚆', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 7),
            Expanded(child: Text(_t('VÁGÁNYMESTER AKADÉMIA',
                'RAILMASTER ACADEMY', 'BAHNMEISTER AKADEMIE'),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w900))),
            _pill('⭐ ' + progress.points.toString() +
                ' ' + _t('pont', 'points', 'Punkte')),
            const SizedBox(width: 10),
            _pill(progress.completedCount.toString() + '/10'),
          ]),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 15),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFF3FCFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('10 rövid, valóban játszható tanulópálya.',
                      '10 short, interactive training levels.',
                      '10 kurze, interaktive Trainingslevel.'),
                    style: const TextStyle(color: Color(0xFF164B70),
                      fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(_t(
                    'Minden új leckéért +80 pont, az akadémia végén +220 bónusz. '
                    '160 pontból egy garantált segítségeket tartalmazó ládát vehetsz.',
                    '+80 points per new lesson, +220 graduation bonus. '
                    'A chest with guaranteed hints costs 160 points.',
                    '+80 Punkte pro Lektion, +220 Abschlussbonus. '
                    'Eine Kiste mit garantierten Hilfen kostet 160 Punkte.'),
                    style: const TextStyle(color: Color(0xFF54738C),
                      fontSize: 12)),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(9),
                    child: LinearProgressIndicator(
                      value: progress.completedCount / 10,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFBFDFEC),
                      color: const Color(0xFF36BD83))),
                ]),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (_, layout) {
              final width = layout.maxWidth;
              final cols = width >= 1040 ? 4 : width >= 660 ? 3 : 2;
              final cardWidth = (width - 10 * (cols - 1)) / cols;
              return Wrap(spacing: 10, runSpacing: 9, children: [
                for (final lesson in AcademyLesson.all)
                  SizedBox(width: cardWidth,
                    child: _lessonCard(lesson, progress)),
              ]);
            }),
            const SizedBox(height: 10),
            Row(children: [
              if (!progress.graduated)
                OutlinedButton.icon(
                  onPressed: _skip,
                  icon: const Icon(Icons.fast_forward_rounded),
                  label: Text(_t('Oktatás kihagyása', 'Skip training',
                      'Training überspringen'))),
              const Spacer(),
              if (progress.campaignUnlocked)
                FilledButton.icon(
                  onPressed: widget.onCampaign,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_t('ORSZÁGOK ÉS PÁLYÁK',
                      'COUNTRIES & LEVELS', 'LÄNDER & LEVEL')),
                ),
            ]),
          ]),
        ),
      ])),
    );
  }

  Widget _lessonCard(AcademyLesson lesson, AcademyProgress p) {
    final can = p.canPlay(lesson.index);
    final done = p.cleared.contains(lesson.index);
    return Material(color: can ? const Color(0xFFF7FCFF)
        : const Color(0xFFD6E2E9),
      elevation: can ? 3 : 0,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: can ? () => setState(() => _playing = lesson.index) : null,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: done
                ? const Color(0xFF30B58B) : Colors.white, width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(lesson.icon, style: const TextStyle(fontSize: 23)),
                const Spacer(),
                Icon(done ? Icons.check_circle_rounded
                    : can ? Icons.play_circle_fill_rounded
                        : Icons.lock_rounded,
                  color: done ? const Color(0xFF279E6C)
                      : const Color(0xFF2D719B)),
              ]),
              const SizedBox(height: 5),
              Text((lesson.index + 1).toString() + '. ' +
                  lesson.name(widget.store.language),
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF153F61),
                  fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(lesson.detail(widget.store.language),
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF50758D),
                  fontSize: 10)),
              const SizedBox(height: 4),
              Text(done ? '✓ ' + _t('Kész', 'Complete', 'Erledigt')
                  : '+80 ⭐', style: const TextStyle(
                  color: Color(0xFF248A70), fontWeight: FontWeight.w900,
                  fontSize: 12)),
            ]),
        ),
      ),
    );
  }
  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xFFDAF7FF),
      borderRadius: BorderRadius.circular(18)),
    child: Text(text, style: const TextStyle(color: Color(0xFF154777),
      fontWeight: FontWeight.w900, fontSize: 12)),
  );
}
