import 'package:flutter/foundation.dart';

/// The first Hungarian stage is a real interactive guided lesson.
/// Progress advances ONLY after the player presses the correct real control.
enum TutorialStep {
  introduction,
  openStationMenu,
  originSwitch,
  exitSignal,
  chooseReceivingStation,
  destinationSwitch,
  entrySignal,
  closeStationMenu,
  selectTrain,
  departTrain,
  waitForArrival,
  enableAutomatic,
  completed,
}

enum TutorialAction {
  begin,
  openedStation,
  changedOriginSwitch,
  clearedExitSignal,
  selectedReceiver,
  changedDestinationSwitch,
  clearedEntrySignal,
  closedStation,
  selectedTrain,
  dispatchedTrain,
  firstArrival,
  enabledAutomatic,
}

class TutorialGuide extends ChangeNotifier {
  TutorialStep step = TutorialStep.introduction;

  bool get active => step != TutorialStep.completed;
  bool get inStation => step.index >= TutorialStep.originSwitch.index &&
      step.index <= TutorialStep.closeStationMenu.index;
  int get current => step.index;
  int get total => TutorialStep.values.length - 1;

  static const _order = <TutorialAction>[
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

  bool accept(TutorialAction action) {
    if (!active || _order[step.index] != action) return false;
    step = TutorialStep.values[step.index + 1];
    notifyListeners();
    return true;
  }

  bool accepts(TutorialAction action) =>
      active && _order[step.index] == action;
}
