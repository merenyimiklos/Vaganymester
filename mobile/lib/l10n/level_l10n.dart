import '../game/level_catalog.dart';
import '../game/level_briefing.dart';
import 'game_l10n.dart';

/// Localized country names, unique level titles and new-mechanic descriptions.
extension LocalizedCountry on RailwayCountry {
  String get localizedName => switch (GameL10n.language) {
    'en' => switch(code) {
      'hu' => 'Hungary', 'at' => 'Austria', 'ch' => 'Switzerland',
      'de' => 'Germany', 'it' => 'Italy', 'jp' => 'Japan', _ => name,
    },
    'de' => switch(code) {
      'hu' => 'Ungarn', 'at' => 'Österreich', 'ch' => 'Schweiz',
      'de' => 'Deutschland', 'it' => 'Italien', 'jp' => 'Japan', _ => name,
    },
    _ => name,
  };

  String get localizedSubtitle => switch (GameL10n.language) {
    'en' => switch(code) {
      'hu' => 'Lake Balaton, Danube and urban rail',
      'at' => 'Alpine tunnels and mountain trains',
      'ch' => 'Precision connections in the Alps',
      'de' => 'ICE and S-Bahn across busy routes',
      'it' => 'Coastal rails and high-speed service',
      'jp' => 'Shinkansen and precision scheduling', _ => subtitle,
    },
    'de' => switch(code) {
      'hu' => 'Balaton, Donau und Stadtverkehr',
      'at' => 'Alpentunnel und Bergbahnen',
      'ch' => 'Pünktliche Verbindungen in den Alpen',
      'de' => 'ICE und S-Bahn auf dichten Strecken',
      'it' => 'Küstenbahn und Hochgeschwindigkeit',
      'jp' => 'Shinkansen und präzise Fahrpläne', _ => subtitle,
    },
    _ => subtitle,
  };
}

extension LocalizedLevel on GameLevel {
  String get localizedTitle {
    if (GameL10n.language == 'hu') return title;
    final lang = GameL10n.language;
    final lines = _titles[lang]?[country.code];
    if (lines == null || number < 1 || number > lines.length) return title;
    return lines[number - 1];
  }

  String get localizedDescription {
    if (GameL10n.language == 'hu') return description;
    return LevelBriefing.explanation(this, GameL10n.language);
  }

  String get localizedFeature => switch(GameL10n.language) {
    'en' => switch(feature) {
      LevelFeature.tutorial => 'Switches and signals',
      LevelFeature.rushHour => 'Rush hour',
      LevelFeature.fog => 'Reduced visibility',
      LevelFeature.maintenance => 'Closed platform',
      LevelFeature.express => 'Express priority',
      LevelFeature.freight => 'Freight traffic',
      LevelFeature.night => 'Night shift',
      LevelFeature.festival => 'Festival traffic',
      LevelFeature.mountains => 'Mountain railway',
      LevelFeature.finale => 'Final challenge',
    },
    'de' => switch(feature) {
      LevelFeature.tutorial => 'Weichen und Signale',
      LevelFeature.rushHour => 'Hauptverkehrszeit',
      LevelFeature.fog => 'Eingeschränkte Sicht',
      LevelFeature.maintenance => 'Gleissperrung',
      LevelFeature.express => 'Express-Vorrang',
      LevelFeature.freight => 'Güterverkehr',
      LevelFeature.night => 'Nachtschicht',
      LevelFeature.festival => 'Festverkehr',
      LevelFeature.mountains => 'Bergbahn',
      LevelFeature.finale => 'Abschlussprüfung',
    },
    _ => featureLabel,
  };
}

const _titles = <String, Map<String, List<String>>>{
  'en': {
    'hu': ['Starting at Creek Junction','Balaton Weekend','Fog on the Great Plain',
      'Danube Track Closure','InterCity Priority','Industrial Freight',
      'Night Mail','Island Festival','Bakony Mountain Climb','Budapest Junction'],
    'at': ['Vienna Departure','Innsbruck Rush Hour','Arlberg Fog',
      'Tauern Tunnel Closure','Railjet Priority','Graz Freight',
      'Salzburg at Night','Ski World Cup Trains','Brenner Pass','Alpine Junction'],
    'ch': ['Swiss Precision','Zurich S-Bahn','Lake Lucerne Fog',
      'Gotthard Maintenance','InterCity Connections','Alpine Freight',
      'Lucerne at Night','Lugano Festival','Bernina Pass','Swiss Timetable Finale'],
    'de': ['Rhine Valley Start','Berlin Rush Hour','Hamburg Fog',
      'Ruhr Track Closure','ICE Corridor','Duisburg Containers',
      'Munich at Night','Oktoberfest Specials','Black Forest','Frankfurt Central'],
    'it': ['Roman Morning','Milan Commuters','Po Valley Fog',
      'Venice Track Works','Frecciarossa Route','Genoa Port',
      'Naples by Night','Florence Festival','Cinque Terre','Italian High-Speed Hub'],
    'jp': ['Kyoto Station','Tokyo Rush Hour','Morning Fog in Nara',
      'Osaka Track Closure','Shinkansen Priority','Kobe Freight',
      'Night Express','Hanami Specials','Mount Fuji Railway','Tokyo Dispatcher Exam'],
  },
  'de': {
    'hu': ['Start in Bachkreuz','Balaton-Wochenende','Nebel in der Puszta',
      'Gleissperrung an der Donau','InterCity-Vorrang','Industriegüterverkehr',
      'Nachtpost','Sziget-Festival','Bakony-Bergfahrt','Knoten Budapest'],
    'at': ['Start in Wien','Innsbrucker Berufsverkehr','Arlberg-Nebel',
      'Tauern-Tunnelsperrung','Railjet-Vorrang','Güterzüge in Graz',
      'Salzburg bei Nacht','Ski-WM-Sonderzüge','Brennerpass','Alpenknoten'],
    'ch': ['Schweizer Pünktlichkeit','Zürcher S-Bahn','Nebel am Vierwaldstättersee',
      'Gotthard-Wartung','InterCity-Anschlüsse','Alpengüterverkehr',
      'Luzern bei Nacht','Fest in Lugano','Berninapass','Schweizer Fahrplanfinale'],
    'de': ['Start am Rhein','Berliner Berufsverkehr','Hamburger Nebel',
      'Ruhr-Gleissperrung','ICE-Korridor','Container in Duisburg',
      'München bei Nacht','Oktoberfest-Züge','Schwarzwald','Frankfurter Hauptbahnhof'],
    'it': ['Morgen in Rom','Mailänder Pendler','Nebel in der Po-Ebene',
      'Bauarbeiten in Venedig','Frecciarossa-Strecke','Hafen Genua',
      'Neapel bei Nacht','Fest in Florenz','Cinque Terre','Italienischer Schnellbahnknoten'],
    'jp': ['Bahnhof Kyoto','Tokios Berufsverkehr','Morgennebel in Nara',
      'Gleissperrung Osaka','Shinkansen-Vorrang','Güterzüge in Kobe',
      'Nacht-Express','Hanami-Sonderzüge','Fuji-Bergbahn','Tokios Fahrdienstprüfung'],
  },
};
