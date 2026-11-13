import 'help_inventory.dart';
import 'simulation.dart';

enum HintFocus { train, turnout, entrySignal, exitSignal, departure }

class HelpSuggestion {
  const HelpSuggestion({
    required this.type,
    required this.trainNumber,
    required this.stationId,
    required this.title,
    required this.detail,
    required this.focus,
    this.side,
    this.track,
  });

  final HelpType type;
  final String trainNumber;
  final String stationId;
  final String title;
  final String detail;
  final HintFocus focus;
  final RailwaySide? side;
  final int? track;
}

/// Read-only railway advice. Never changes signal, turnout or train state.
class RailwayHelpAdvisor {
  const RailwayHelpAdvisor();

  HelpSuggestion? suggest(RailwaySimulation sim, HelpType type,
      {String? preferredTrain}) {
    if (sim.emergency || sim.levelComplete || sim.gameOver ||
        sim.automatic) return null;
    final eligible = sim.trains.where((train) {
      if (train.moving || train.readyAt > sim.elapsedSeconds) return false;
      final section = sim.sectionBetween(
        train.currentStationId, train.nextStationId);
      if (section.closed || sim.occupying(section) != null) return false;
      if (sim.controls(train.currentStationId)
          .closedTracks.contains(train.platformTrack)) return false;
      final destination = sim.station(train.nextStationId);
      return List.generate(destination.platforms, (i) => i).any(
        (i) => !sim.controls(destination.id).closedTracks.contains(i) &&
            !sim.trackReserved(destination.id, i),
      );
    }).toList();
    if (eligible.isEmpty) return null;
    eligible.sort((a, b) {
      if (a.number == preferredTrain) return -1;
      if (b.number == preferredTrain) return 1;
      return a.readyAt.compareTo(b.readyAt);
    });
    final train = eligible.first;
    final origin = sim.station(train.currentStationId);
    final target = sim.station(train.nextStationId);
    final direction = sim.travelSide(train);
    final entrySide = sim.opposite(direction);
    final fromControls = sim.controls(origin.id);
    final toControls = sim.controls(target.id);
    final freeTracks = List.generate(target.platforms, (i) => i)
        .where((i) => !toControls.closedTracks.contains(i) &&
            !sim.trackReserved(target.id, i)).toList();
    if (freeTracks.isEmpty) return null;
    final platform = freeTracks.contains(toControls.turnout(entrySide))
        ? toControls.turnout(entrySide) : freeTracks.first;
    final label = direction == RailwaySide.east ? 'keleti' : 'nyugati';
    final entryLabel = entrySide == RailwaySide.east ? 'keleti' : 'nyugati';

    HelpSuggestion result({
      required String title,
      required String description,
      required String stationId,
      required HintFocus focus,
      RailwaySide? side,
      int? track,
    }) => HelpSuggestion(
      type: type,
      trainNumber: train.number,
      stationId: stationId,
      title: title,
      detail: description,
      focus: focus,
      side: side,
      track: track,
    );

    if (type == HelpType.freePlatform) {
      return result(
        title: target.name + ': ' + (platform + 1).toString() + '. vágány',
        description: train.number + ' számára ez az érkezési vágány '
            'szabad. Nyisd meg a fogadó állomást, és állítsd a ' +
            entryLabel + ' bejárati váltót a ' +
            (platform + 1).toString() + '. vágányra.',
        stationId: target.id,
        focus: HintFocus.turnout,
        side: entrySide,
        track: platform,
      );
    }

    if (fromControls.turnout(direction) != train.platformTrack) {
      return result(
        title: 'Állítsd az induló váltót!',
        description: origin.name + ': a ' + label + ' oldalon válaszd a ' +
            (train.platformTrack + 1).toString() + '. vágányt a ' +
            train.number + ' vonathoz.',
        stationId: origin.id,
        focus: HintFocus.turnout,
        side: direction,
        track: train.platformTrack,
      );
    }
    if (!freeTracks.contains(toControls.turnout(entrySide))) {
      return result(
        title: 'Állítsd a fogadó váltót!',
        description: target.name + ': a ' + entryLabel + ' bejáratnál '
            'válaszd a ' + (platform + 1).toString() + '. szabad vágányt.',
        stationId: target.id,
        focus: HintFocus.turnout,
        side: entrySide,
        track: platform,
      );
    }
    if (!fromControls.signal(direction, SignalKind.exit)) {
      return result(
        title: 'Kijárati jelző: SZABAD',
        description: origin.name + ': a ' + label + ' kijárati jelzőt '
            'állítsd SZABAD-ra, majd ellenőrizd a fogadó állomást.',
        stationId: origin.id,
        focus: HintFocus.exitSignal,
        side: direction,
      );
    }
    if (!toControls.signal(entrySide, SignalKind.entry)) {
      return result(
        title: 'Bejárati jelző: SZABAD',
        description: target.name + ': a ' + entryLabel + ' bejárati jelzőt '
            'állítsd SZABAD-ra. Ezzel kész az érkezési vágányút.',
        stationId: target.id,
        focus: HintFocus.entrySignal,
        side: entrySide,
      );
    }
    return result(
      title: 'Most indulhat ' + train.number + '!',
      description: 'A ' + train.number + ' vonat vágányútja készen áll. '
          'Válaszd ki a vonatot, és érintsd meg az INDÍTÁS gombot.',
      stationId: origin.id,
      focus: HintFocus.departure,
    );
  }
}
