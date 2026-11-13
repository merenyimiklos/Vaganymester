import 'package:flutter_test/flutter_test.dart';
import 'package:vaganymester/game/campaign_progress.dart';
import 'package:vaganymester/game/level_catalog.dart';
import 'package:vaganymester/game/simulation.dart';

void pump(RailwaySimulation sim, int times) {
  for (var i = 0; i < times; i++) {
    sim.tick(.2);
  }
}

void main() {
  test('Hat különböző országban pontosan tíz szint létezik', () {
    expect(LevelCatalog.countries.length, 6);
    expect(LevelCatalog.all.length, 60);
    final allIds = LevelCatalog.all.map((l) => l.id).toSet();
    expect(allIds.length, 60);
    for (final country in LevelCatalog.countries) {
      final stages = LevelCatalog.inCountry(country.code);
      expect(stages.length, 10);
      expect(stages.map((l) => l.title).toSet().length, 10);
      expect(stages.map((l) => l.feature).toSet().length, 10);
      expect(stages.first.difficulty, 1);
      expect(stages.last.difficulty, 5);
    }
  });

  test('A következő pálya csak az előző teljesítésére nyílik', () {
    final progress = CampaignProgress();
    expect(progress.isUnlocked(LevelCatalog.all[0]), isTrue);
    expect(progress.isUnlocked(LevelCatalog.all[1]), isFalse);
    expect(progress.isCountryUnlocked(LevelCatalog.countries[1]), isFalse);
    expect(progress.award(LevelCatalog.all[1], 3), isFalse);
    expect(progress.award(LevelCatalog.all[0], 2), isTrue);
    expect(progress.isUnlocked(LevelCatalog.all[1]), isTrue);
    expect(progress.award(LevelCatalog.all[0], 1), isFalse);
    expect(progress.starsFor(LevelCatalog.all[0]), 2);
    expect(progress.totalStars, 2);
  });

  test('A második ország a magyar tizedik pálya után válik elérhetővé', () {
    final progress = CampaignProgress();
    for (var i = 0; i < 9; i++) {
      expect(progress.award(LevelCatalog.all[i], 1), isTrue);
    }
    expect(progress.isCountryUnlocked(LevelCatalog.countries[1]), isFalse);
    progress.award(LevelCatalog.all[9], 3);
    expect(progress.isCountryUnlocked(LevelCatalog.countries[1]), isTrue);
    expect(progress.isUnlocked(LevelCatalog.all[11]), isFalse);
  });

  test('Az eredménymentésből a folytonos haladás állítható vissza', () {
    final progress = CampaignProgress();
    progress.award(LevelCatalog.all[0], 1);
    progress.award(LevelCatalog.all[1], 3);
    final saved = CampaignProgress.fromJson(progress.toJson());
    expect(saved.completedCount, 2);
    expect(saved.totalStars, 4);
    expect(saved.isUnlocked(LevelCatalog.all[2]), isTrue);
    expect(saved.isUnlocked(LevelCatalog.all[3]), isFalse);
    final forged = CampaignProgress.fromJson({'jp-10': 3, 'hu-1': 2});
    expect(forged.starsFor(LevelCatalog.all.last), 0);
    expect(forged.completedCount, 1);
  });

  test('Minden országban saját állomások és eltérő sebességek vannak', () {
    final countryNames = <String>{};
    for (final country in LevelCatalog.countries) {
      final level = LevelCatalog.inCountry(country.code).first;
      final sim = RailwaySimulation(level: level);
      expect(sim.stations.map((s) => s.name).toList(),
          country.stationNames);
      expect(sim.sections.every((s) => s.lengthKm > 3), isTrue);
      countryNames.add(sim.station('korospatak').name);
    }
    expect(countryNames.length, 6);
    expect(LevelCatalog.inCountry('jp').first.speedFactor,
        greaterThan(LevelCatalog.inCountry('ch').first.speedFactor));
  });

  test('A vágányzáras forgatókönyv valóban lezár egy peront', () {
    final level = LevelCatalog.inCountry('at')[3];
    final sim = RailwaySimulation(level: level);
    expect(sim.controls('korospatak').closedTracks,
        contains(level.platformCount - 1));
    expect(sim.setTurnout('korospatak', RailwaySide.west,
        level.platformCount - 1), isFalse);
    sim.newShift();
    expect(sim.controls('korospatak').closedTracks,
        contains(level.platformCount - 1));
  });

  test('A csúcsforgalom és a hegyi szakasz eltérő modelleket ad', () {
    final rush = LevelCatalog.inCountry('de')[1];
    final mountain = LevelCatalog.inCountry('de')[8];
    expect(rush.trainCount, greaterThan(mountain.trainCount));
    expect(rush.departureInterval,
        lessThan(mountain.departureInterval));
    expect(mountain.speedFactor, lessThan(rush.speedFactor));
    final simRush = RailwaySimulation(level: rush);
    final simMountain = RailwaySimulation(level: mountain);
    expect(simRush.trains.length, rush.trainCount);
    expect(simMountain.trains.length, mountain.trainCount);
  });

  test('A pálya célja teljesíthető, csillagot és pontot ad', () {
    final level = LevelCatalog.initial;
    final sim = RailwaySimulation(level: level);
    pump(sim, 600);
    expect(sim.levelComplete, isTrue);
    expect(sim.earnedStars, inInclusiveRange(1, 3));
    expect(sim.completedLegs, greaterThanOrEqualTo(level.requiredArrivals));
    expect(sim.score, greaterThan(0));
    expect(sim.running, isFalse);
  });

  test('Az új szolgálat ugyanazt az ország-specifikus pályát indítja', () {
    final level = LevelCatalog.inCountry('jp')[5];
    final sim = RailwaySimulation(level: level);
    expect(sim.trains.length, level.trainCount);
    pump(sim, 15);
    sim.newShift();
    expect(sim.level.id, level.id);
    expect(sim.stations[1].name, level.country.stationNames[1]);
    expect(sim.trains.length, level.trainCount);
    expect(sim.completedLegs, 0);
    expect(sim.earnedStars, 0);
    expect(sim.levelComplete, isFalse);
  });
}
