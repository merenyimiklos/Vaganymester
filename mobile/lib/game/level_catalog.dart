import 'package:flutter/material.dart';

enum LevelFeature {
  tutorial, rushHour, fog, maintenance, express,
  freight, night, festival, mountains, finale,
}

class RailwayCountry {
  const RailwayCountry(this.code, this.name, this.flag, this.subtitle,
      this.landscape, this.color, this.stationNames, this.prefix,
      this.speedFactor);

  final String code;
  final String name;
  final String flag;
  final String subtitle;
  final String landscape;
  final Color color;
  final List<String> stationNames;
  final String prefix;
  final double speedFactor;
}

class GameLevel {
  const GameLevel(this.country, this.number, this.title,
      this.description, this.feature);

  final RailwayCountry country;
  final int number;
  final String title;
  final String description;
  final LevelFeature feature;

  String get id => country.code + '-' + number.toString();
  int get difficulty => ((number - 1) ~/ 2 + 1).clamp(1, 5);
  String get difficultyLabel => List.filled(difficulty, '★').join() +
      List.filled(5 - difficulty, '☆').join();
  int get trainCount => switch (feature) {
    LevelFeature.tutorial => 3,
    LevelFeature.rushHour || LevelFeature.festival => 5,
    LevelFeature.finale => 6,
    LevelFeature.express || LevelFeature.freight => 4,
    _ => 3,
  };
  int get requiredArrivals => 2 + number +
      (feature == LevelFeature.finale ? 2 : 0);
  int get platformCount => feature == LevelFeature.finale ? 5 :
      feature == LevelFeature.maintenance || number >= 7 ? 4 : 3;
  double get sectionKm => switch (country.code) {
    'hu' => 4.2, 'at' => 3.9, 'ch' => 3.5,
    'de' => 5.4, 'it' => 4.3, 'jp' => 5.0,
    _ => 4.5,
  } + number * .23;
  double get speedFactor => country.speedFactor * switch (feature) {
    LevelFeature.fog => .75,
    LevelFeature.night => .87,
    LevelFeature.mountains => .76,
    LevelFeature.maintenance => .84,
    LevelFeature.express => 1.18,
    _ => 1.0,
  };
  double get departureInterval => switch (feature) {
    LevelFeature.rushHour => 5,
    LevelFeature.festival => 7,
    LevelFeature.finale => 5,
    LevelFeature.freight => 14,
    _ => 11,
  };
  double get turnaroundSeconds => feature == LevelFeature.rushHour ||
      feature == LevelFeature.finale ? 12 : 22;
  int get targetSeconds => (requiredArrivals *
      (sectionKm * 3600 / (speedFactor * 135) + turnaroundSeconds) *
      .9).round() + 150;

  String get featureLabel => switch (feature) {
    LevelFeature.tutorial => 'Váltókezelés',
    LevelFeature.rushHour => 'Csúcsforgalom',
    LevelFeature.fog => 'Korlátozott látás',
    LevelFeature.maintenance => 'Vágányzár',
    LevelFeature.express => 'Gyorsvonat-elsőbbség',
    LevelFeature.freight => 'Teherforgalom',
    LevelFeature.night => 'Éjszakai szolgálat',
    LevelFeature.festival => 'Rendezvényforgalom',
    LevelFeature.mountains => 'Hegyvidéki vonal',
    LevelFeature.finale => 'Forgalmi kihívás',
  };
}

class LevelCatalog {
  static const countries = <RailwayCountry>[
    RailwayCountry('hu','Magyarország','🇭🇺',
      'Balaton, Duna és nagyvárosi forgalom', 'Pannon síkság',
      Color(0xFF56BA65), ['Fenyvesliget','Kőröspatak','Tiszaváros'],
      'MÁV', 1),
    RailwayCountry('at','Ausztria','🇦🇹',
      'Alpesi alagutak és hegyi vonatok', 'Alpok',
      Color(0xFF63B9AA), ['Innsbruck','Brenner','Villach'],
      'ÖBB', .92),
    RailwayCountry('ch','Svájc','🇨🇭',
      'Óraműpontos csatlakozások a hegyekben', 'Havas Alpok',
      Color(0xFF6BB5DD), ['Luzern','Andermatt','Bellinzona'],
      'SBB', .90),
    RailwayCountry('de','Németország','🇩🇪',
      'ICE és S-Bahn a sűrű hálózaton', 'Nagyvárosi folyosó',
      Color(0xFFEDAC48), ['Köln','Frankfurt','Würzburg'],
      'DB', 1.16),
    RailwayCountry('it','Olaszország','🇮🇹',
      'Tengerparti vonalak és gyorsvonatok', 'Mediterrán part',
      Color(0xFFE99B65), ['Genova','La Spezia','Pisa'],
      'FS', 1.06),
    RailwayCountry('jp','Japán','🇯🇵',
      'Sinkanszen és percre pontos sűrű üzem', 'A Fudzsi vidéke',
      Color(0xFFE78AB5), ['Kyoto','Shin-Osaka','Kobe'],
      'JR', 1.30),
  ];

  static const _titles = <String, List<String>>{
    'hu': ['Kőröspataki kezdés','Balatoni hétvége','Alföldi köd',
      'Dunai vágányzár','InterCity-elsőbbség','Iparvágányi menet',
      'Éjszakai posta','Sziget Fesztivál','Bakonyi emelkedő',
      'Budapesti csomópont'],
    'at': ['Bécsi indulás','Innsbruck csúcsidő','Köd az Arlberg-hágón',
      'Tauern-alagút lezárva','Railjet elsőbbség','Graz tehervonatai',
      'Éjszaka Salzburgban','Sívilágkupa menetei','Brenner-hágó',
      'Alpesi csomópont'],
    'ch': ['Svájci pontosság','Zürichi S-Bahn','Köd a Vierwaldstättinél',
      'Gotthard-karbantartás','InterCity csatlakozás',
      'Alpesi teherszállítás','Luzerni éjszaka','Luganoi ünnep',
      'Bernina-hágó','Svájci menetrendi csúcs'],
    'de': ['Rajna menti indulás','Berlini csúcsforgalom','Hamburgi köd',
      'Ruhr-vidéki vágányzár','ICE-folyosó','Duisburg konténervonatai',
      'München éjjel','Oktoberfest-járatok','Fekete-erdő',
      'Frankfurti főpályaudvar'],
    'it': ['Római reggel','Milánói ingázók','Köd a Pó-síkságon',
      'Velencei pályamunka','Frecciarossa útvonala','Genovai kikötő',
      'Nápoly éjszaka','Firenzei fesztivál','Cinque Terre',
      'Olasz nagysebességi csomópont'],
    'jp': ['Kyotói állomás','Tokiói csúcsidő','Reggeli köd Narában',
      'Osakai pályazár','Sinkanszen elsőbbség','Kobei tehervonatok',
      'Éjszakai gyorsvonat','Hanami különjáratok',
      'Fudzsi hegyvidéki szakasz','Tokiói forgalmi vizsga'],
  };

  static const _details = <String, List<String>>{
    'hu': [
      'Ismerd meg a magyar állomásokat és a biztonságos jelzőkezelést.',
      'A balatoni nyaralók csúcsidős különvonatokat kérnek.',
      'Az alföldi pára lassítja a vonatokat.',
      'Karbantartás miatt egy peron lezárva.',
      'A gyors InterCity-t előnyben kell részesíteni.',
      'Iparvágányi tehervonatok torlódnak a vonalon.',
      'Éjszaka fokozott figyelemmel irányítsd a jelzőket.',
      'A fesztivál tömegei több szerelvényt hoznak.',
      'A Bakonyban lassabban haladnak a vonatok.',
      'Bizonyíts egy összetett budapesti csomópontban.',
    ],
    'at': [
      'Kezdd a Railjet-vonal első váltóinak kezelésével.',
      'Az osztrák ingázók egyszerre kérnek vágányutat.',
      'A hegyi köd sebességkorlátozást hoz.',
      'Egy alpesi állomáson peronlezárás van.',
      'Az érkező Railjetnek elsőbbséget kell adnod.',
      'A tranzit teherforgalom lassan halad.',
      'Sötétben figyeld a salzburgi jelzőket.',
      'A sívilágkupa különvonatai mind érkeznek.',
      'Vezesd át a vonatokat a magashegyi szakaszon.',
      'Minden vonat összefut a Brenner térségében.',
    ],
    'ch': [
      'Szervezd meg a svájci pontosságú indulásokat.',
      'Sűrű városi vasúti forgalom érkezik.',
      'A tóparti köd lassítja a szerelvényeket.',
      'A Gotthard térségében vágánykarbantartás zajlik.',
      'Az InterCity nem várhat a csatlakozásra.',
      'Nemzetközi tehervonatokat is továbbítani kell.',
      'Hegyvidéki éjszakai szolgálat következik.',
      'Ünnepi különvonatok érkeznek Luganóba.',
      'A Bernina magashegyi pályája lassít.',
      'Oldd meg a legösszetettebb svájci csatlakozást.',
    ],
    'de': [
      'Ismerd meg a Rajna menti vasúti szolgálatot.',
      'S-Bahn csúcsidőszakban sűrűn érkezik.',
      'A hamburgi köd csökkenti a pályasebességet.',
      'A Ruhr-vidéki felújítás egy vágányt lezár.',
      'Az ICE-nek elsőbbség jár a folyosón.',
      'Sok konténervonat érkezik Duisburgból.',
      'Éjszakai forgalom a bajor vonalakon.',
      'Oktoberfestre különvonatok érkeznek.',
      'Kanyargós pálya a Fekete-erdőben.',
      'Frankfurtban minden vágány foglalt lesz.',
    ],
    'it': [
      'Irányítsd a mediterrán regionális forgalmat.',
      'Milánó ingázói megrohamozzák az állomásokat.',
      'A Pó-síkságon sűrű köd van.',
      'Velencében lezártak egy peront.',
      'Tartsd szabadon a Frecciarossa útvonalát.',
      'A kikötőből nehéz tehervonatok érkeznek.',
      'Éjszakai járatok haladnak a tengerparton.',
      'Ünnepi különjáratok érkeznek Firenzébe.',
      'A Cinque Terre hegyei lelassítanak.',
      'Az olasz gyorsvonatok összehangolása a feladat.',
    ],
    'jp': [
      'Tanuld meg a japán menetrendszerűséget.',
      'Tokióban nagyon sűrű az ingázóforgalom.',
      'Reggeli köd borítja a régi várost.',
      'Osakában egy peront javítanak.',
      'A Sinkanszen elsőbbséget kap a forgalomban.',
      'A kikötő felől tehervonatok érkeznek.',
      'Az éjszakai gyorsvonat is pontosan indul.',
      'A hanami cseresznyevirágzás különjáratokat hoz.',
      'A Fudzsi körüli hegyi vonal lassabb.',
      'Teljesítsd a legnehezebb japán forgalmi vizsgát.',
    ],
  };

  static final List<GameLevel> all = [
    for (final country in countries)
      for (var i = 0; i < 10; i++)
        GameLevel(country, i + 1, _titles[country.code]![i],
            _details[country.code]![i], LevelFeature.values[i]),
  ];

  static List<GameLevel> inCountry(String code) =>
      all.where((level) => level.country.code == code).toList();

  static GameLevel byId(String id) =>
      all.firstWhere((level) => level.id == id);

  static GameLevel get initial => all.first;

  static GameLevel? next(GameLevel level) {
    final idx = all.indexWhere((e) => e.id == level.id);
    return idx < 0 || idx == all.length - 1 ? null : all[idx + 1];
  }
}
