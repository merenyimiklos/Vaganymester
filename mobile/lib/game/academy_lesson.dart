import 'level_catalog.dart';

/// Each training scenario exercises an actual simulated function.
enum AcademyAction {
  setOriginTurnout,
  clearExit,
  setArrivalTurnout,
  clearEntry,
  authorize,
  trainArrived,
  changeSpeed,
  pause,
  resume,
  closeLine,
  reopenLine,
  selectIntercity,
  selectFreight,
  selectNightTrain,
  resolveIncident,
  openHelp,
  openChest,
  enableAuto,
  automaticArrival,
  selectStation,
}

class AcademyLesson {
  const AcademyLesson(this.index, this.nameHu, this.nameEn,
      this.nameDe, this.detailHu, this.detailEn, this.detailDe,
      this.feature, this.actions, this.icon);

  final int index;
  final String nameHu, nameEn, nameDe;
  final String detailHu, detailEn, detailDe;
  final LevelFeature feature;
  final List<AcademyAction> actions;
  final String icon;

  String name(String language) => switch (language) {
    'en' => nameEn, 'de' => nameDe, _ => nameHu,
  };
  String detail(String language) => switch (language) {
    'en' => detailEn, 'de' => detailDe, _ => detailHu,
  };

  static const all = <AcademyLesson>[
    AcademyLesson(0, 'Váltók és jelzők', 'Switches & signals',
      'Weichen & Signale',
      'Állítsd a váltókat és a jelzőket, indítsd el az első vonatodat, és várd meg az érkezést.',
      'Set switches and signals, dispatch your first train and watch it arrive.',
      'Stelle Weichen und Signale, starte deinen ersten Zug und warte auf die Ankunft.',
      LevelFeature.tutorial, [
        AcademyAction.setOriginTurnout, AcademyAction.clearExit,
        AcademyAction.setArrivalTurnout, AcademyAction.clearEntry,
        AcademyAction.authorize, AcademyAction.trainArrived,
      ], '🚦'),
    AcademyLesson(1, 'Idő és sebesség', 'Time & speed', 'Zeit & Tempo',
      'Kapcsold 10× sebességre a játékot, állítsd meg, majd indítsd újra.',
      'Choose 10× speed, pause the simulation and resume.',
      'Wähle 10× Tempo, pausiere und setze die Simulation fort.',
      LevelFeature.rushHour, [
        AcademyAction.changeSpeed, AcademyAction.pause, AcademyAction.resume,
      ], '⏱️'),
    AcademyLesson(2, 'Pályaudvarok és peronok', 'Stations & platforms',
      'Bahnhöfe & Bahnsteige',
      'Nyisd meg Kőröspatakot, és állítsd a nyugati váltót a 3. vágányra.',
      'Open Creek Junction and set the west switch to track 3.',
      'Öffne Bachkreuz und stelle die Westweiche auf Gleis 3.',
      LevelFeature.fog, [AcademyAction.selectStation,
        AcademyAction.setArrivalTurnout], '🏢'),
    AcademyLesson(3, 'Vágányzár és feloldás', 'Track closures', 'Gleissperrungen',
      'Zárd le, majd nyisd meg újra az FV–KP vonali szakaszt.',
      'Close the FV–KP line, then reopen it.',
      'Sperre die Strecke FV–KP und gib sie wieder frei.',
      LevelFeature.maintenance, [
        AcademyAction.closeLine, AcademyAction.reopenLine,
      ], '🛠️'),
    AcademyLesson(4, 'InterCity-elsőbbség', 'InterCity priority',
      'InterCity-Vorrang',
      'Válassz ki egy InterCity-szerelvényt, és nézd meg az adatait.',
      'Select an InterCity and inspect its details.',
      'Wähle einen InterCity und prüfe seine Daten.',
      LevelFeature.express, [AcademyAction.selectIntercity], '🚄'),
    AcademyLesson(5, 'Teherforgalom', 'Freight traffic', 'Güterverkehr',
      'Válassz ki egy lassabb tehervonatot, és figyeld meg a sebességét.',
      'Select a slower freight train and study its speed.',
      'Wähle einen langsameren Güterzug und beachte sein Tempo.',
      LevelFeature.freight, [AcademyAction.selectFreight], '🚛'),
    AcademyLesson(6, 'Éjszakai szolgálat', 'Night shift', 'Nachtschicht',
      'Állítsd 1× sebességre az éjszakai pályát, és válassz egy vonatot.',
      'Set night speed to 1× and select a train.',
      'Stelle nachts auf 1× Tempo und wähle einen Zug.',
      LevelFeature.night, [
        AcademyAction.changeSpeed, AcademyAction.selectNightTrain,
      ], '🌙'),
    AcademyLesson(7, 'Váratlan veszély', 'Unexpected hazard',
      'Unerwartete Gefahr',
      'Gyalogos tévedt a sínekre. Biztosítsd a szakaszt a piros gombbal.',
      'A pedestrian is on the track. Secure the line using the red button.',
      'Eine Person steht auf dem Gleis. Sichere die Strecke mit der roten Taste.',
      LevelFeature.festival, [AcademyAction.resolveIncident], '⚠️'),
    AcademyLesson(8, 'Segítségek és ládák', 'Hints & chests',
      'Hilfen & Kisten',
      'Nyisd meg a segítségeket, majd egy ingyenes ládát.',
      'Open the hint center, then open a free chest.',
      'Öffne die Hilfe und anschließend eine kostenlose Kiste.',
      LevelFeature.mountains, [
        AcademyAction.openHelp, AcademyAction.openChest,
      ], '🎁'),
    AcademyLesson(9, 'Automata forgalom', 'Automatic dispatch',
      'Automatische Zugleitung',
      'Kapcsold be az automatát, és várd meg az első sikeres menetet.',
      'Enable automatic dispatch and wait for one completed trip.',
      'Aktiviere die Automatik und warte auf eine erfolgreiche Fahrt.',
      LevelFeature.finale, [
        AcademyAction.enableAuto, AcademyAction.automaticArrival,
      ], '🏆'),
  ];

  /// Reuse the real simulation catalogue: no parallel fake engine.
  GameLevel get simulatorLevel => LevelCatalog.inCountry('hu')[index];
}
class AcademyStepProgress {
  AcademyStepProgress(this.lesson);
  final AcademyLesson lesson;
  int step = 0;
  bool get done => step >= lesson.actions.length;
  AcademyAction? get expected => done ? null : lesson.actions[step];
  int get count => lesson.actions.length;
  bool accept(AcademyAction action) {
    if (expected != action) return false;
    step++;
    return true;
  }
}
