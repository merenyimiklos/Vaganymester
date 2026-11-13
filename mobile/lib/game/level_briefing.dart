import 'level_catalog.dart';

/// Country-specific, localized briefing displayed when a level first starts.
/// The help text describes implemented game mechanics, not real signalling rules.
class LevelBriefing {
  const LevelBriefing._();

  static String title(GameLevel level, String language) {
    if (level.feature == LevelFeature.tutorial) {
      return _pick(language, 'Tanulópálya', 'Tutorial', 'Tutorial');
    }
    return _pick(language, 'Új kihívás', 'New challenge', 'Neue Herausforderung') +
        ': ' + level.country.flag + ' ' +
        level.number.toString() + '/10';
  }

  static String explanation(GameLevel level, String language) {
    final label = level.country.name;
    return switch (level.feature) {
      LevelFeature.tutorial => _pick(language,
        'Az első vonatot lépésről lépésre együtt indítjuk.',
        'We will dispatch your first train step by step.',
        'Wir starten deinen ersten Zug gemeinsam Schritt für Schritt.'),
      LevelFeature.rushHour => _pick(language,
        'Csúcsforgalom indul! Több vonat érkezik rövid időközökkel. '
        'Váratlanul gyalogos tévedhet a sínekre: a piros riasztásnál '
        'nyomd meg a pályabiztosítás gombját, mielőtt lejár az idő.',
        'Rush hour brings extra trains. A pedestrian may enter the '
        'tracks: tap SECURE THE TRACK on the red alert before time expires.',
        'Zur Hauptverkehrszeit kommen mehr Züge. Eine Person kann '
        'das Gleis betreten: tippe rechtzeitig auf GLEIS SICHERN.'),
      LevelFeature.fog => _pick(language,
        'Köd miatt minden vonat lassabban halad. Használd a sebességjelzőt '
        'és hagyj időt a szerelvényeknek a célba éréshez!',
        'Fog slows every train. Watch the speed control and plan for longer trips.',
        'Nebel verlangsamt alle Züge. Plane mehr Reisezeit ein.'),
      LevelFeature.maintenance => _pick(language,
        'Egy állomási vágány le van zárva. Nyisd meg az állomásvezérlést '
        'és csak szabad peronra állíts be érkezést!',
        'One station track is closed. Open station control and select '
        'a free platform for arrivals.',
        'Ein Bahnhofsgleis ist gesperrt. Wähle einen freien Bahnsteig.'),
      LevelFeature.express => _pick(language,
        'A gyors InterCity járatok elsőbbséget élveznek. '
        'Ügyelj az indulási sorrendre!',
        'Fast InterCity services have priority. Manage departure order.',
        'Schnelle InterCity-Züge haben Vorrang. Beachte die Abfahrtsfolge.'),
      LevelFeature.freight => _pick(language,
        'A nehéz tehervonatok lassabbak. Hosszabban foglalják a szakaszokat.',
        'Heavy freight trains are slower and occupy sections longer.',
        'Schwere Güterzüge fahren langsamer und belegen Gleise länger.'),
      LevelFeature.night => _pick(language,
        'Éjszakai műszak: csökken a látótávolság és a vonatok sebessége.',
        'Night shift: visibility and running speed are reduced.',
        'Nachtschicht: Sichtweite und Geschwindigkeit sind reduziert.'),
      LevelFeature.festival => _pick(language,
        'Rendezvény miatt különvonatok érkeznek. '
        'Váratlan pályára lépés is előfordulhat: figyeld a riasztást!',
        'An event creates extra trains and possible track intrusions. '
        'Watch for emergency alerts!',
        'Ein Fest bringt Sonderzüge und mögliche Gleisalarme.'),
      LevelFeature.mountains => _pick(language,
        'A hegyi szakaszokon csökkentett sebességgel közlekednek a vonatok.',
        'Trains move more slowly over mountain sections.',
        'Auf Bergstrecken fahren Züge langsamer.'),
      LevelFeature.finale => _pick(language,
        'Sűrű forgalom, több vágány és váratlan veszélyek. '
        'Használd minden eddig megszerzett tudásodat!',
        'Dense traffic, extra tracks and unexpected hazards. '
        'Use everything you have learned!',
        'Dichter Verkehr, zusätzliche Gleise und Überraschungen. '
        'Nutze dein ganzes Wissen!'),
    } + '\n\n' + label;
  }

  static String _pick(String language, String hu, String en, String de) =>
      switch (language) {
        'en' => en, 'de' => de, _ => hu,
      };
}
