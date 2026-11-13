import 'package:flutter/material.dart';
import '../data/session_store.dart';
import '../l10n/game_l10n.dart';

const ink = Color(0xFF174A70);
const blue = Color(0xFF207CB2);
String loc(String lang, String hu, String en, String de) =>
    switch (lang) { 'en' => en, 'de' => de, _ => hu };

Future<void> showGameSettingsDialog(
    BuildContext context, SessionStore store) async {
  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 610,
          maxHeight: MediaQuery.sizeOf(context).height * .88),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFFF9FFFF), Color(0xFFD4EFFC)]),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x990C3958),
              blurRadius: 22, offset: Offset(0, 5))]),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 8, 8, 8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20)),
                gradient: LinearGradient(colors: [
                  Color(0xFF198FC2), Color(0xFF155390)])),
              child: Row(children: [
                const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 29),
                const SizedBox(width: 9),
                Expanded(child: Text(GameL10n.tr('BEÁLLÍTÁSOK'),
                  style: const TextStyle(color: Colors.white,
                    fontSize: 19, fontWeight: FontWeight.w900))),
                IconButton(onPressed: () => Navigator.of(context).pop(),
                  tooltip: GameL10n.tr('BEZÁRÁS'),
                  icon: const Icon(Icons.close_rounded,
                    color: Colors.white)),
              ]),
            ),
            Expanded(child: AnimatedBuilder(
              animation: store,
              builder: (_, __) => ListView(
                padding: const EdgeInsets.all(13),
                children: [
                  _section(GameL10n.tr('Nyelv'), Icons.language_rounded, [
                    Wrap(spacing: 7, runSpacing: 5, children: [
                      for (final lang in const [
                        ('hu', '🇭🇺', 'Magyar'),
                        ('en', '🇬🇧', 'English'),
                        ('de', '🇩🇪', 'Deutsch'),
                      ])
                        ChoiceChip(
                          selected: store.language == lang.$1,
                          selectedColor: const Color(0xFF9DEADA),
                          label: Text(lang.$2 + ' ' + lang.$3,
                            style: const TextStyle(color: ink,
                              fontWeight: FontWeight.w800)),
                          onSelected: (_) => store.setLanguage(lang.$1),
                        ),
                    ]),
                  ]),
                  _section(loc(store.language, 'HANG ÉS REZGÉS',
                      'SOUND & HAPTICS', 'TON & VIBRATION'),
                      Icons.volume_up_rounded, [
                    _toggle(Icons.music_note_rounded,
                      loc(store.language, 'Menüzene', 'Menu music',
                        'Menümusik'),
                      store.musicEnabled, store.setMusic),
                    _toggle(Icons.train_rounded,
                      loc(store.language, 'Vonathangok', 'Train sounds',
                        'Zuggeräusche'),
                      store.trainSoundsEnabled, store.setTrainSounds),
                    _toggle(Icons.vibration_rounded,
                      loc(store.language, 'Rezgés', 'Vibration', 'Vibration'),
                      store.hapticsEnabled, store.setHaptics),
                    Row(children: [
                      const Icon(Icons.volume_up_rounded, color: blue),
                      Expanded(child: Slider(value: store.masterVolume,
                        activeColor: blue, onChanged: store.setVolume)),
                      Text((store.masterVolume * 100).round().toString() + '%',
                        style: const TextStyle(color: ink,
                          fontWeight: FontWeight.w900)),
                    ]),
                  ]),
                  _section(loc(store.language, 'JÁTÉK',
                      'GAMEPLAY', 'SPIEL'),
                      Icons.sports_esports_rounded, [
                    _toggle(Icons.smart_toy_rounded,
                      GameL10n.tr('Automatikus irányítás'),
                      store.autoDispatch, store.setAuto),
                    _toggle(Icons.warning_amber_rounded,
                      GameL10n.tr('Kockázatos játékmód'),
                      store.riskMode, store.setRisk),
                    _toggle(Icons.tips_and_updates_rounded,
                      GameL10n.tr('Kezelési tippek'),
                      store.showHints, store.setHints),
                    Text(GameL10n.tr('Alapértelmezett sebesség'),
                      style: const TextStyle(color: ink,
                        fontSize: 12, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 7, children: [
                      for (final n in const [1, 10, 30, 60])
                        ChoiceChip(
                          selected: store.speed == n,
                          selectedColor: const Color(0xFFB0F2F0),
                          label: Text(n.toString() + '×',
                            style: const TextStyle(color: ink)),
                          onSelected: (_) => store.setSpeed(n)),
                    ]),
                  ]),
                  Text(GameL10n.tr(
                      'Az eredmények kizárólag ezen az eszközön maradnak.'),
                    style: const TextStyle(color: Color(0xFF5A7C90),
                      fontSize: 11)),
                ],
              ),
            )),
          ]),
        ),
      ),
    ),
  );
}

Widget _section(String title, IconData icon, List<Widget> children) =>
  Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 11),
    decoration: BoxDecoration(color: const Color(0xFFF0F9FF),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFB8DFEF), width: 1.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: blue),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: ink,
          fontWeight: FontWeight.w900, fontSize: 15)),
      ]),
      const SizedBox(height: 8),
      ...children,
    ]),
  );

Widget _toggle(IconData icon, String title, bool value,
    ValueChanged<bool> onChange) => SwitchListTile(
  dense: true,
  visualDensity: VisualDensity.compact,
  contentPadding: EdgeInsets.zero,
  secondary: Icon(icon, color: blue),
  title: Text(title, style: const TextStyle(color: ink,
    fontSize: 13, fontWeight: FontWeight.w800)),
  value: value,
  onChanged: onChange,
);
