import 'package:flutter_test/flutter_test.dart';
import 'package:vaganymester/game/academy_lesson.dart';
import 'package:vaganymester/game/academy_progress.dart';
import 'package:vaganymester/game/simulation.dart';
import 'package:vaganymester/game/level_catalog.dart';

void main() {
  test('Ten different academy stages, three localized descriptions', () {
    expect(AcademyLesson.all.length, AcademyProgress.lessonCount);
    expect(AcademyLesson.all.map((s) => s.feature).toSet().length, 10);
    for (final l in AcademyLesson.all) {
      expect(l.actions, isNotEmpty);
      expect(l.name('hu').isNotEmpty, true);
      expect(l.name('en').isNotEmpty, true);
      expect(l.name('de').isNotEmpty, true);
      expect(l.simulatorLevel.feature, l.feature);
    }
  });
  test('Campaign gate only opens after graduation or explicit skip', () {
    final a = AcademyProgress();
    expect(a.campaignUnlocked, false);
    expect(a.canPlay(0), true);
    expect(a.canPlay(1), false);
    a.skip();
    expect(a.campaignUnlocked, true);
    expect(a.points, 0);
  });
  test('Lessons reward only once and graduate with a bonus', () {
    final a = AcademyProgress();
    expect(a.complete(1), 0);
    for (var i = 0; i < 9; i++) {
      expect(a.complete(i), AcademyProgress.lessonReward);
      expect(a.complete(i), 0);
    }
    expect(a.campaignUnlocked, false);
    expect(a.complete(9), 300);
    expect(a.points, 1020);
    expect(a.campaignUnlocked, true);
    expect(a.complete(9), 0);
  });
  test('Chest costs 160 earned points, insufficient balance fails', () {
    final a = AcademyProgress();
    expect(a.spend(AcademyProgress.chestPrice), false);
    a.complete(0);
    a.complete(1);
    expect(a.spend(AcademyProgress.chestPrice), true);
    expect(a.points, 0);
    expect(a.spend(AcademyProgress.chestPrice), false);
  });
  test('Academy progress survives serialization and replay protection', () {
    final a = AcademyProgress()..complete(0)..complete(1)..skip();
    final copy = AcademyProgress.fromJson(a.toJson());
    expect(copy.points, 160);
    expect(copy.cleared, {0, 1});
    expect(copy.complete(1), 0);
    expect(copy.canPlay(2), true);
    expect(copy.campaignUnlocked, true);
  });
  test('Invalid saved data never generates negative points', () {
    final a = AcademyProgress.fromJson({
      'points': -300, 'cleared': [0, 0, 999, -1, 'bad'],
      'skipped': 'no',
    });
    expect(a.points, 0);
    expect(a.cleared, {0});
    expect(a.campaignUnlocked, false);
  });
  test('Guide cannot advance when an incorrect action is clicked', () {
    for (final chapter in AcademyLesson.all) {
      final p = AcademyStepProgress(chapter);
      for (final action in chapter.actions) {
        expect(p.expected, action);
        expect(p.accept(action), true);
      }
      expect(p.done, true);
      expect(p.accept(chapter.actions.last), false);
    }
  });
  test('First academy level dispatches through actual switches/signals', () {
    final sim = RailwaySimulation(level: LevelCatalog.initial)
      ..setAutomatic(false);
    expect(sim.setTurnout('fenyvesliget', RailwaySide.east, 1), true);
    expect(sim.setSignal('fenyvesliget', RailwaySide.east,
      SignalKind.exit, true), true);
    expect(sim.setTurnout('korospatak', RailwaySide.west, 1), true);
    expect(sim.setSignal('korospatak', RailwaySide.west,
      SignalKind.entry, true), true);
    expect(sim.authorize('S 2412'), true);
    sim.tick(.2);
    expect(sim.train('S 2412').moving, true);
    sim.dispose();
  });
  test('Pedestrian simulation can be enabled only for emergency training', () {
    final level = LevelCatalog.inCountry('hu')[7];
    final hazard = RailwaySimulation(level: level)
      ..setAutomatic(false);
    hazard.elapsedSeconds = 35;
    hazard.tick(.2);
    expect(hazard.hasHazard, true);
    expect(hazard.secureHazard(), true);
    final safe = RailwaySimulation(level: level)
      ..incidentsEnabled = false
      ..setAutomatic(false);
    safe.elapsedSeconds = 35;
    safe.tick(.2);
    expect(safe.hasHazard, false);
    hazard.dispose();
    safe.dispose();
  });
}
