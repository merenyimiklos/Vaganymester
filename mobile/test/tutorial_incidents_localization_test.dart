import 'package:flutter_test/flutter_test.dart';
import 'package:vaganymester/game/level_catalog.dart';
import 'package:vaganymester/game/simulation.dart';
import 'package:vaganymester/game/tutorial_guide.dart';
import 'package:vaganymester/l10n/game_l10n.dart';
import 'package:vaganymester/l10n/level_l10n.dart';

void main() {
  test('Az első magyar pálya tényleges tanulószint, kezdő váltófeladattal', () {
    final level = LevelCatalog.initial;
    final sim = RailwaySimulation(level: level);
    expect(level.id, 'hu-1');
    expect(level.feature, LevelFeature.tutorial);
    expect(sim.train('S 2412').readyAt, 0);
    expect(sim.train('S 2412').platformTrack, 1);
    sim.setAutomatic(false);
    expect(sim.setTurnout('fenyvesliget', RailwaySide.east, 1), isTrue);
    expect(sim.setSignal('fenyvesliget',
        RailwaySide.east, SignalKind.exit, true), isTrue);
    expect(sim.setTurnout('korospatak', RailwaySide.west, 1), isTrue);
    expect(sim.setSignal('korospatak',
        RailwaySide.west, SignalKind.entry, true), isTrue);
    expect(sim.authorize('S 2412'), isTrue);
    sim.tick(.2);
    expect(sim.train('S 2412').moving, isTrue);
    expect(sim.train('S 2412').arrivalTrack, 1);
  });

  test('A tutorial nem ugorható át: csak helyes műveletre lép tovább', () {
    final guide = TutorialGuide();
    expect(guide.step, TutorialStep.introduction);
    expect(guide.accept(TutorialAction.dispatchedTrain), isFalse);
    final actions = [
      TutorialAction.begin,
      TutorialAction.openedStation,
      TutorialAction.changedOriginSwitch,
      TutorialAction.clearedExitSignal,
      TutorialAction.selectedReceiver,
      TutorialAction.changedDestinationSwitch,
      TutorialAction.clearedEntrySignal,
      TutorialAction.closedStation,
      TutorialAction.selectedTrain,
      TutorialAction.dispatchedTrain,
      TutorialAction.firstArrival,
      TutorialAction.enabledAutomatic,
    ];
    for (final action in actions) {
      expect(guide.accept(action), isTrue);
    }
    expect(guide.active, isFalse);
    expect(guide.step, TutorialStep.completed);
    expect(guide.accept(TutorialAction.begin), isFalse);
    guide.dispose();
  });

  test('A 2. pályán a pályára tévedő gyalogos megállítja a vonatot', () {
    final level = LevelCatalog.inCountry('hu')[1];
    final sim = RailwaySimulation(level: level);
    for (var i = 0; i < 7; i++) {
      sim.tick(.2);
    }
    expect(sim.hasHazard, isTrue);
    expect(sim.activeHazard!.kind, 'pedestrian');
    final section = sim.sections.first;
    final train = sim.occupying(section);
    if (train != null) {
      final before = train.progress;
      sim.tick(.2);
      expect(train.progress, before);
    }
    expect(sim.secureHazard(), isTrue);
    expect(sim.secureHazard(), isFalse);
    expect(sim.hasHazard, isFalse);
    expect(sim.hazardResolvedCount, 1);
    expect(sim.score, greaterThanOrEqualTo(80));
    sim.dispose();
  });

  test('Elhanyagolt veszélynél egy élet fogy, nem ismétlődik a riasztás', () {
    final sim = RailwaySimulation(
      level: LevelCatalog.inCountry('de')[1],
    );
    for (var i = 0; i < 7; i++) sim.tick(.2);
    expect(sim.hasHazard, isTrue);
    for (var i = 0; i < 130; i++) sim.tick(.2);
    expect(sim.hasHazard, isFalse);
    expect(sim.hazardFailedCount, 1);
    expect(sim.lives, 2);
    expect(sim.hazardTriggered, isTrue);
    sim.dispose();
  });

  test('Az eseményben érintett szakaszra nem indulhat új vonat', () {
    final sim = RailwaySimulation(
      level: LevelCatalog.inCountry('it')[1],
    )..setAutomatic(false);
    for (var i = 0; i < 7; i++) sim.tick(.2);
    expect(sim.hasHazard, isTrue);
    final train = sim.trains.first;
    expect(train.moving, isFalse);
    sim.authorize(train.number);
    sim.tick(.2);
    expect(train.moving, isFalse);
    sim.dispose();
  });

  test('Magyar/angol/német fordítás és minden ország 10 szintcíme', () {
    final former = GameL10n.language;
    for (final language in GameL10n.supported) {
      GameL10n.language = language;
      for (final country in LevelCatalog.countries) {
        final levels = LevelCatalog.inCountry(country.code);
        expect(levels.length, 10);
        expect(country.localizedName.isNotEmpty, isTrue);
        expect(levels.map((l) => l.localizedTitle).toSet().length, 10);
        expect(levels.every((l) => l.localizedFeature.isNotEmpty), isTrue);
      }
      expect(GameL10n.tr('INDÍTÁS').isNotEmpty, isTrue);
      expect(GameL10n.tr('TANULÓPÁLYA').isNotEmpty, isTrue);
    }
    GameL10n.language = former;
  });

  test('Angol/német nyelveken a fontos menüfeliratok valóban eltérnek', () {
    final old = GameL10n.language;
    GameL10n.language = 'en';
    expect(GameL10n.tr('INDÍTÁS'), 'DEPART');
    expect(GameL10n.tr('BEÁLLÍTÁSOK'), 'SETTINGS');
    GameL10n.language = 'de';
    expect(GameL10n.tr('INDÍTÁS'), 'ABFAHRT');
    expect(GameL10n.tr('BEÁLLÍTÁSOK'), 'EINSTELLUNGEN');
    GameL10n.language = old;
  });
}
