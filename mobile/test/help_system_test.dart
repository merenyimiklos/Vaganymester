import 'package:flutter_test/flutter_test.dart';
import 'package:vaganymester/game/help_advisor.dart';
import 'package:vaganymester/game/help_inventory.dart';
import 'package:vaganymester/game/simulation.dart';

void advanceToFirstDeparture(RailwaySimulation sim) {
  sim.setAutomatic(false);
  sim.tick(.2);
  sim.tick(.2);
}

void main() {
  test('A kezdő láda két garantált segítséget ad, nem véletlenszerűt', () {
    final inventory = HelpInventory();
    expect(inventory.chests, 1);
    expect(inventory.totalItems, 0);
    final awarded = inventory.openChest();
    expect(awarded, [HelpType.nextStep, HelpType.freePlatform]);
    expect(inventory.chests, 0);
    expect(inventory.count(HelpType.nextStep), 1);
    expect(inventory.count(HelpType.freePlatform), 1);
    expect(inventory.openChest(), isEmpty);
  });

  test('Az elfogyott segítség nem használható többször', () {
    final inventory = HelpInventory();
    inventory.openChest();
    expect(inventory.consume(HelpType.nextStep), isTrue);
    expect(inventory.consume(HelpType.nextStep), isFalse);
    expect(inventory.count(HelpType.nextStep), 0);
    expect(inventory.consume(HelpType.signals), isFalse);
  });

  test('Pályánként csak egy új láda szerezhető', () {
    final inventory = HelpInventory();
    expect(inventory.earnChest('hu-1'), isTrue);
    expect(inventory.earnChest('hu-1'), isFalse);
    expect(inventory.earnChest('hu-2'), isTrue);
    expect(inventory.chests, 3);
  });

  test('A felhasználható segítségek és ládák visszatölthetők', () {
    final inventory = HelpInventory();
    inventory.openChest();
    inventory.consume(HelpType.nextStep);
    inventory.earnChest('hu-1');
    final restored = HelpInventory.fromJson(inventory.toJson());
    expect(restored.chests, 1);
    expect(restored.count(HelpType.nextStep), 0);
    expect(restored.count(HelpType.freePlatform), 1);
    expect(restored.earnChest('hu-1'), isFalse);
    expect(restored.openChest(),
      [HelpType.freePlatform, HelpType.signals]);
  });

  test('Hibás és negatív helyi készletadatokat nem fogadunk el', () {
    final restored = HelpInventory.fromJson({
      'chests': -50,
      'opened': 10,
      'items': {'nextStep': -5, 'freePlatform': 3},
      'earned': ['hu-1', 14, null],
    });
    expect(restored.chests, 0);
    expect(restored.count(HelpType.nextStep), 0);
    expect(restored.count(HelpType.freePlatform), 3);
    expect(restored.earnChest('hu-1'), isFalse);
  });

  test('A radar szabad fogadó vágányt keres, nem foglaltat', () {
    final sim = RailwaySimulation();
    advanceToFirstDeparture(sim);
    final hint = const RailwayHelpAdvisor().suggest(
      sim, HelpType.freePlatform,
      preferredTrain: 'S 2412',
    );
    expect(hint, isNotNull);
    expect(hint!.stationId, 'korospatak');
    expect(hint.track, isNotNull);
    expect(sim.trackReserved(hint.stationId, hint.track!), isFalse);
    expect(sim.movingCount, 0);
  });

  test('A segítség követi a valódi vágányút-beállítást', () {
    final sim = RailwaySimulation();
    advanceToFirstDeparture(sim);
    const advisor = RailwayHelpAdvisor();

    var hint = advisor.suggest(
      sim, HelpType.nextStep, preferredTrain: 'S 2412');
    expect(hint?.focus, HintFocus.turnout);
    expect(hint?.stationId, 'korospatak');
    final platform = hint!.track!;
    expect(sim.setTurnout('korospatak', RailwaySide.west, platform), isTrue);
    hint = advisor.suggest(sim, HelpType.nextStep,
      preferredTrain: 'S 2412');
    expect(hint?.focus, HintFocus.exitSignal);
    expect(sim.setSignal('fenyvesliget', RailwaySide.east,
      SignalKind.exit, true), isTrue);
    hint = advisor.suggest(sim, HelpType.nextStep,
      preferredTrain: 'S 2412');
    expect(hint?.focus, HintFocus.entrySignal);
    expect(sim.setSignal('korospatak', RailwaySide.west,
      SignalKind.entry, true), isTrue);
    hint = advisor.suggest(sim, HelpType.nextStep,
      preferredTrain: 'S 2412');
    expect(hint?.focus, HintFocus.departure);
    expect(sim.movingCount, 0); // A tanács csak olvas, nem indít vonatot.
  });

  test('Automatikus módban és vészleállításkor nincs téves tipp', () {
    final sim = RailwaySimulation();
    advanceToFirstDeparture(sim);
    const advisor = RailwayHelpAdvisor();
    sim.setAutomatic(true);
    expect(advisor.suggest(sim, HelpType.nextStep), isNull);
    sim.setAutomatic(false);
    sim.setEmergency(true);
    expect(advisor.suggest(sim, HelpType.nextStep), isNull);
  });

  test('Foglalt vágány miatt nem ad balesetveszélyes javaslatot', () {
    final sim = RailwaySimulation();
    advanceToFirstDeparture(sim);
    sim.setSectionClosed('FV-KP', true);
    final hint = const RailwayHelpAdvisor().suggest(
      sim, HelpType.nextStep, preferredTrain: 'S 2412');
    if (hint != null) {
      expect(hint.trainNumber, isNot('S 2412'));
    }
  });
}
