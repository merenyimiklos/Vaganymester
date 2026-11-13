import 'package:flutter/material.dart';
import '../game/tutorial_guide.dart';
import '../l10n/game_l10n.dart';

/// Pulsing border around the actual clickable widget.
class TutorialTarget extends StatefulWidget {
  const TutorialTarget({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;
  @override
  State<TutorialTarget> createState() => _TutorialTargetState();
}
class _TutorialTargetState extends State<TutorialTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 750),
  );
  @override
  void initState() {
    super.initState();
    if (widget.active) {
      _pulse.repeat(reverse: true);
      _reveal();
    }
  }
  @override
  void didUpdateWidget(covariant TutorialTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      _pulse.repeat(reverse: true);
      _reveal();
    } else if (oldWidget.active && !widget.active) {
      _pulse.stop();
    }
  }
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.active || Scrollable.maybeOf(context) == null) {
        return;
      }
      Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 400),
        alignment: .45,
        curve: Curves.easeOutCubic);
    });
  }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.lerp(
            const Color(0xFFFFEF81), const Color(0xFFFFA300), _pulse.value)!,
            width: 3.5),
          boxShadow: [BoxShadow(color: const Color(0xFFFFC331)
              .withValues(alpha: .35 + _pulse.value * .5),
            spreadRadius: 2 + _pulse.value * 4,
            blurRadius: 7 + _pulse.value * 14)],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class TutorialCoach extends StatelessWidget {
  const TutorialCoach({super.key, required this.guide,
    this.onBegin, this.compact = false});
  final TutorialGuide guide;
  final VoidCallback? onBegin;
  final bool compact;

  static const _messages = <TutorialStep, List<String>>{
    TutorialStep.introduction: [
      'Üdv a tanulópályán! A sárgán világító gombokat nyomd meg. Az első vonatodat te fogod elindítani.',
      'Welcome to training! Tap the glowing yellow controls to dispatch your first train.',
      'Willkommen im Training! Tippe auf die gelb leuchtenden Tasten und starte deinen ersten Zug.'],
    TutorialStep.openStationMenu: [
      '1. Koppints az ÁLLOMÁS gombra az alsó menüben!',
      '1. Tap STATION in the bottom menu!',
      '1. Tippe unten auf BAHNHOF!'],
    TutorialStep.originSwitch: [
      '2. Fenyvesliget KELETI váltóját állítsd a 2. vágányra!',
      '2. Set Pine Grove EAST switch to track 2!',
      '2. Stelle die OST-Weiche in Fichtenhain auf Gleis 2!'],
    TutorialStep.exitSignal: [
      '3. Engedd SZABAD-ra a KELETI KIJÁRATI jelzőt!',
      '3. Set the EAST EXIT signal to CLEAR!',
      '3. Stelle das ÖSTLICHE AUSFAHRTSIGNAL auf FREI!'],
    TutorialStep.chooseReceivingStation: [
      '4. Válaszd ki fent KŐRÖSPATAK állomást!',
      '4. Select CREEK JUNCTION above!',
      '4. Wähle oben BACHKREUZ!'],
    TutorialStep.destinationSwitch: [
      '5. Kőröspatak NYUGATI váltóját állítsd a 2. vágányra!',
      '5. Set Creek Junction WEST switch to track 2!',
      '5. Stelle die WEST-Weiche in Bachkreuz auf Gleis 2!'],
    TutorialStep.entrySignal: [
      '6. Engedd SZABAD-ra a NYUGATI BEJÁRATI jelzőt!',
      '6. Set the WEST ENTRY signal to CLEAR!',
      '6. Stelle das WESTLICHE EINFAHRTSIGNAL auf FREI!'],
    TutorialStep.closeStationMenu: [
      '7. Lépj vissza a térképre a kiemelt gombbal!',
      '7. Return to the map with the highlighted button!',
      '7. Kehre mit der markierten Taste zur Karte zurück!'],
    TutorialStep.selectTrain: [
      '8. Érintsd meg az S 2412 vonat kártyáját!',
      '8. Tap the S 2412 train card!',
      '8. Tippe auf die Zugkarte S 2412!'],
    TutorialStep.departTrain: [
      '9. A vágányút kész. Nyomd meg az INDÍTÁS gombot!',
      '9. Route is ready. Press DEPART!',
      '9. Die Fahrstraße ist frei. Drücke ABFAHRT!'],
    TutorialStep.waitForArrival: [
      '10. Figyeld az S 2412 vonat érkezését!',
      '10. Watch train S 2412 arrive!',
      '10. Beobachte die Ankunft von S 2412!'],
    TutorialStep.enableAutomatic: [
      '11. Próbáld ki az AUTOMATA irányítást a jobb felső gombbal!',
      '11. Try AUTO dispatch with the top-right control!',
      '11. Aktiviere die AUTOMATIK oben rechts!'],
    TutorialStep.completed: [
      'Oktatás befejezve! Már önállóan tudsz vonatokat irányítani.',
      'Training complete! You can now control the trains.',
      'Training abgeschlossen! Du kannst jetzt Züge steuern.'],
  };

  @override
  Widget build(BuildContext context) {
    final language = switch (GameL10n.language) {
      'en' => 1, 'de' => 2, _ => 0,
    };
    return Container(
      constraints: BoxConstraints(maxWidth: compact ? 290 : 420),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7C3), Color(0xFFFFD876)]),
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [BoxShadow(color: Color(0x885A4016),
          blurRadius: 13, offset: Offset(0, 4))]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.ads_click_rounded,
          color: Color(0xFF91651A), size: 25),
        const SizedBox(width: 8),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(GameL10n.tr('TANULÓPÁLYA') + ' ' +
                guide.current.toString() + '/' + guide.total.toString(),
              style: const TextStyle(color: Color(0xFF725019),
                fontSize: 10, fontWeight: FontWeight.w900)),
            Text(_messages[guide.step]![language],
              style: const TextStyle(color: Color(0xFF573B0B),
                fontSize: 12, fontWeight: FontWeight.w800)),
          ])),
        if (guide.step == TutorialStep.introduction)
          FilledButton(onPressed: onBegin,
            child: Text(GameL10n.tr('KEZDÉS'))),
      ]),
    );
  }
}
