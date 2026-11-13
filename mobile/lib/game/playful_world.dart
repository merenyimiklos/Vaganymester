import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'simulation.dart';
import 'level_catalog.dart';
import '../l10n/game_l10n.dart';

/// Original, vector-based, colorful casual-game world.
/// Everything here is decoration or a visual representation of actual
/// simulator state, never an independent source of track/signal logic.
class PlayfulWorld extends PositionComponent {
  PlayfulWorld(this.simulation)
      : super(position: Vector2.zero(), size: Vector2(1400, 650), priority: -100);

  final RailwaySimulation simulation;

  @override
  void render(Canvas canvas) {
    _background(canvas);
    _countryScenery(canvas);
    _terrain(canvas);
    _details(canvas);
    for (final station in simulation.stations) {
      _station(canvas, station);
    }
    _tracks(canvas);
    _signals(canvas);
    _atmosphere(canvas);
  }

  void _background(Canvas canvas) {
    final sky = Rect.fromLTWH(0, 0, 1400, 650);
    final colors = switch (simulation.level.country.code) {
      'at' => const <Color>[
        Color(0xFF7ACAF2), Color(0xFFC6F4FE),
        Color(0xFF96D8AB), Color(0xFF67B99B)],
      'ch' => const <Color>[
        Color(0xFF7BB8F0), Color(0xFFE6F9FF),
        Color(0xFFD7E9E9), Color(0xFF81C7AF)],
      'de' => const <Color>[
        Color(0xFF84C7F5), Color(0xFFC5E9FD),
        Color(0xFFB7E19A), Color(0xFF8FC77B)],
      'it' => const <Color>[
        Color(0xFF67C9F1), Color(0xFFCCF6FF),
        Color(0xFF95DEBB), Color(0xFF62C79C)],
      'jp' => const <Color>[
        Color(0xFF79BDF3), Color(0xFFFFE9F7),
        Color(0xFFD6DAB7), Color(0xFF87C69C)],
      _ => const <Color>[
        Color(0xFF70CDF9), Color(0xFFC7F2FF),
        Color(0xFF91D77B), Color(0xFF70C96E)],
    };
    canvas.drawRect(sky, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: colors, stops: const [0, .31, .34, 1],
      ).createShader(sky));

    for (final data in <(double, double, double)>[
      (84, 56, 49), (280, 75, 45), (460, 42, 55),
      (758, 66, 42), (1030, 40, 51), (1275, 85, 51),
    ]) {
      _cloud(canvas, data.$1, data.$2, data.$3);
    }
    final distant = Path()
      ..moveTo(0, 225)
      ..lineTo(0, 163)
      ..quadraticBezierTo(140, 90, 250, 162)
      ..quadraticBezierTo(340, 115, 450, 169)
      ..quadraticBezierTo(635, 100, 740, 174)
      ..quadraticBezierTo(930, 91, 1040, 163)
      ..quadraticBezierTo(1180, 106, 1400, 169)
      ..lineTo(1400, 225)..close();
    canvas.drawPath(distant, Paint()..color = const Color(0xFF8EBCC0));
    final hills = Path()
      ..moveTo(0, 239)..lineTo(0, 190)
      ..quadraticBezierTo(175, 134, 295, 200)
      ..quadraticBezierTo(485, 138, 625, 213)
      ..quadraticBezierTo(835, 153, 970, 201)
      ..quadraticBezierTo(1117, 144, 1400, 190)
      ..lineTo(1400, 239)..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF75B875));
  }

  void _countryScenery(Canvas c) {
    final code = simulation.level.country.code;
    final mountains = code == 'at' || code == 'ch' || code == 'jp';
    if (mountains) {
      final paint = Paint()..color = code == 'ch'
          ? const Color(0xFF8EA7BD)
          : const Color(0xFF7E9FA8);
      for (final x in <double>[90, 420, 870, 1190]) {
        final peak = Path()
          ..moveTo(x - 150, 217)
          ..lineTo(x + 12, 96)
          ..lineTo(x + 160, 217)..close();
        c.drawPath(peak, paint);
        final snow = Path()
          ..moveTo(x - 24, 133)..lineTo(x + 12, 96)
          ..lineTo(x + 56, 136)
          ..lineTo(x + 23, 128)
          ..lineTo(x + 9, 143)
          ..lineTo(x - 2, 129)..close();
        c.drawPath(snow, Paint()
          ..color = const Color(0xFFF7FEFF));
      }
    }
    if (code == 'jp') {
      final fuji = Path()
        ..moveTo(920, 215)
        ..lineTo(1082, 76)
        ..lineTo(1250, 215)..close();
      c.drawPath(fuji, Paint()..color = const Color(0xFF8E9EBC));
      final snow = Path()
        ..moveTo(1031, 124)..lineTo(1082, 76)
        ..lineTo(1135, 124)
        ..lineTo(1115, 117)
        ..lineTo(1094, 139)
        ..lineTo(1077, 121)
        ..lineTo(1060, 139)..close();
      c.drawPath(snow, Paint()..color = const Color(0xFFF9FFFF));
    }
    if (code == 'it') {
      final shore = Path()
        ..moveTo(0, 242)
        ..cubicTo(380, 184, 650, 252, 1400, 204)
        ..lineTo(1400, 283)
        ..cubicTo(730, 284, 400, 237, 0, 296)..close();
      c.drawPath(shore, Paint()..color = const Color(0xFF57D7D5));
      for (final x in <double>[64, 445, 1095, 1260]) {
        final palm = Paint()..color = const Color(0xFF8F6740)
          ..strokeWidth = 7;
        c.drawLine(Offset(x, 260), Offset(x + 9, 195), palm);
        for (var d = -2; d <= 2; d++) {
          c.drawLine(Offset(x + 9, 195),
              Offset(x + 9 + 26 * d, 185.0 + 8 * d.abs()),
              Paint()..color = const Color(0xFF32835C)..strokeWidth = 6);
        }
      }
    }
    if (code == 'de') {
      for (final (x, height) in <(double, double)>[
        (90, 61), (135, 105), (208, 82), (1160, 97), (1220, 72),
      ]) {
        c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 216 - height, 39, height),
          const Radius.circular(5)),
          Paint()..color = const Color(0xFF709CB8));
        for (var i = 0; i < 3; i++) {
          for (var j = 0; j < 2; j++) {
            c.drawRect(Rect.fromLTWH(x + 8 + j * 15,
              224 - height + i * 18, 8, 9),
              Paint()..color = const Color(0xFFE5F5FF));
          }
        }
      }
    }
  }

  void _atmosphere(Canvas c) {
    final feature = simulation.level.feature;
    if (feature == LevelFeature.night) {
      c.drawRect(Rect.fromLTWH(0, 0, 1400, 650),
          Paint()..color = const Color(0x77324574));
      c.drawCircle(const Offset(1280, 92), 25,
        Paint()..color = const Color(0xFFF9F8DB));
    } else if (feature == LevelFeature.fog) {
      c.drawRect(Rect.fromLTWH(0, 70, 1400, 280),
        Paint()..shader = const LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x22E7FBFF), Color(0xB4F1FBFF)],
        ).createShader(const Rect.fromLTWH(0, 70, 1400, 280)));
    }
    if (simulation.level.country.code == 'jp') {
      for (var i = 0; i < 44; i++) {
        final x = ((i * 137 + 57) % 1400).toDouble();
        final y = (200 + i * 71 % 440).toDouble();
        c.drawCircle(Offset(x, y), 3,
          Paint()..color = const Color(0xFFFF9DD3));
      }
    }
  }

  void _cloud(Canvas c, double x, double y, double scale) {
    final p = Paint()..color = const Color(0xDDFFFFFF);
    c.drawOval(Rect.fromCenter(center: Offset(x, y),
        width: scale * 2, height: scale * 0.7), p);
    c.drawCircle(Offset(x - scale * 0.44, y - scale * 0.19),
        scale * 0.42, p);
    c.drawCircle(Offset(x + scale * 0.22, y - scale * 0.35),
        scale * 0.56, p);
  }

  void _terrain(Canvas c) {
    final river = Path()
      ..moveTo(0, 183)
      ..cubicTo(310, 249, 405, 125, 687, 196)
      ..cubicTo(954, 256, 1120, 139, 1400, 197)
      ..lineTo(1400, 231)
      ..cubicTo(1102, 172, 931, 283, 690, 228)
      ..cubicTo(433, 166, 316, 286, 0, 218)
      ..close();
    c.drawPath(river, Paint()..color = const Color(0xFF7DE4F1));
    c.drawPath(river, Paint()
      ..color = const Color(0xFFCBFBFF)
      ..style = PaintingStyle.stroke..strokeWidth = 4);

    final gravel = Rect.fromLTWH(0, 310, 1400, 255);
    c.drawRRect(RRect.fromRectAndRadius(
        gravel, const Radius.circular(22)),
      Paint()..color = const Color(0xFFDBD0B7));
    c.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 315, 1400, 245), const Radius.circular(22)),
      Paint()..color = const Color(0xFFB6B5A8));
    for (var i = 0; i < 180; i++) {
      final x = ((i * 137 + 29) % 1399).toDouble();
      final y = 324.0 + ((i * 53 + 11) % 223);
      c.drawCircle(Offset(x, y), i.isEven ? 2 : 3,
        Paint()..color = i.isEven
            ? const Color(0xFFC8C4B8) : const Color(0xFF9A9E96));
    }

    // Platform and path surfaces under the rails.
    for (final station in simulation.stations) {
      final x = station.mapX;
      final edge = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 154, 269, 308, 43), const Radius.circular(10));
      c.drawRRect(edge, Paint()..color = const Color(0xFF938F8A));
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 154, 267, 308, 38),
          const Radius.circular(9)),
        Paint()..color = const Color(0xFFF4E9CD));
      for (var i = 0; i < 14; i++) {
        c.drawLine(Offset(x - 148 + i * 22, 270),
            Offset(x - 148 + i * 22, 306),
            Paint()..color = const Color(0xFFD8C7A9)
                ..strokeWidth = 1);
      }
    }
  }

  void _details(Canvas c) {
    // Tiny original trees and color accents. Coordinates are deterministic.
    final spots = <(double, double, double)>[
      (24, 240, 0.85), (90, 207, 0.64), (332, 234, 0.75),
      (400, 188, 0.72), (504, 215, 0.85), (902, 206, 0.77),
      (991, 228, 0.89), (1110, 195, 0.68), (1364, 231, 0.94),
      (39, 608, 0.85), (390, 604, 0.7), (958, 612, 0.85),
      (1306, 607, 0.82),
    ];
    for (final tree in spots) {
      _tree(c, tree.$1, tree.$2, tree.$3);
    }
    for (var i = 0; i < 95; i++) {
      final x = ((i * 241 + 41) % 1400).toDouble();
      final y = i.isEven ? 585.0 + ((i * 11) % 62) :
          235.0 + ((i * 31) % 42);
      final color = i % 3 == 0
          ? const Color(0xFFFF7CB2)
          : i % 3 == 1 ? const Color(0xFFFFE96F)
              : const Color(0xFFFFFFFF);
      c.drawCircle(Offset(x, y), 2.3,
          Paint()..color = color);
    }
  }

  void _tree(Canvas c, double x, double y, double s) {
    c.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 5 * s, y - 16 * s, 10 * s, 35 * s),
        const Radius.circular(3)),
      Paint()..color = const Color(0xFF916A47));
    c.drawCircle(Offset(x, y - 26 * s), 31 * s,
        Paint()..color = const Color(0xFF318F48));
    c.drawCircle(Offset(x - 17 * s, y - 42 * s), 24 * s,
        Paint()..color = const Color(0xFF58B954));
    c.drawCircle(Offset(x + 17 * s, y - 47 * s), 24 * s,
        Paint()..color = const Color(0xFF74C855));
    c.drawCircle(Offset(x + 4 * s, y - 61 * s), 21 * s,
        Paint()..color = const Color(0xFF98DE69));
  }

  void _station(Canvas c, RailwayStation station) {
    final x = station.mapX;
    final isHub = station.id == 'korospatak';
    final w = isHub ? 214.0 : 137.0;
    final h = isHub ? 86.0 : 61.0;
    final y = 278 - h;
    c.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x - w / 2 + 5, y + 5, w, h + 3),
        const Radius.circular(9)),
      Paint()..color = const Color(0x440A3957));
    c.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x - w / 2, y, w, h),
        const Radius.circular(9)),
      Paint()..color = const Color(0xFFFFE9BA));
    c.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x - w / 2 + 6, y + 8, w - 12, h - 14),
        const Radius.circular(7)),
      Paint()..color = const Color(0xFFFFF2D3));
    final roof = Path()
      ..moveTo(x - w / 2 - 11, y + 7)
      ..lineTo(x, y - 29)
      ..lineTo(x + w / 2 + 11, y + 7)
      ..close();
    c.drawPath(roof, Paint()..color = const Color(0xFFB34E43));
    final front = Path()
      ..moveTo(x - w / 2 - 7, y + 1)
      ..lineTo(x, y - 27)
      ..lineTo(x + w / 2 + 7, y + 1);
    c.drawPath(front, Paint()
      ..color = const Color(0xFFFF8C68)
      ..strokeWidth = 7..style = PaintingStyle.stroke);
    final windowCount = isHub ? 4 : 2;
    for (var i = 0; i < windowCount; i++) {
      final wx = x - w / 2 + 21 + i * (w - 42) / (windowCount - 1);
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(wx - 12, y + h * 0.36, 24, 33),
          const Radius.circular(7)),
        Paint()..color = const Color(0xFF1F587D));
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(wx - 9, y + h * 0.39, 18, 26),
          const Radius.circular(5)),
        Paint()..color = const Color(0xFF8CE1F7));
      c.drawLine(Offset(wx, y + h * 0.39),
          Offset(wx, y + h * 0.39 + 26),
          Paint()..color = Colors.white..strokeWidth = 2);
    }
    if (isHub) {
      c.drawCircle(Offset(x, y - 6), 13,
          Paint()..color = const Color(0xFF153F66));
      c.drawCircle(Offset(x, y - 6), 10,
          Paint()..color = Colors.white);
      c.drawLine(Offset(x, y - 6), Offset(x + 4, y - 10),
          Paint()..color = const Color(0xFF173651)..strokeWidth = 2);
      c.drawLine(Offset(x, y - 6), Offset(x, y - 13),
          Paint()..color = const Color(0xFF173651)..strokeWidth = 2);
    }
    _bench(c, x - w * 0.37, 294);
    _bench(c, x + w * 0.37, 294);
  }

  void _bench(Canvas c, double x, double y) {
    c.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 17, y - 10, 34, 9),
        const Radius.circular(3)),
      Paint()..color = const Color(0xFFAD7046));
    c.drawLine(Offset(x - 13, y - 1), Offset(x - 13, y + 7),
        Paint()..color = const Color(0xFF5B6D76)..strokeWidth = 3);
    c.drawLine(Offset(x + 13, y - 1), Offset(x + 13, y + 7),
        Paint()..color = const Color(0xFF5B6D76)..strokeWidth = 3);
  }

  void _tracks(Canvas c) {
    final ballast = Paint()..color = const Color(0xFF797E83)
        ..strokeWidth = 24..strokeCap = StrokeCap.round;
    final rail = Paint()..color = const Color(0xFFE9F2F1)
        ..strokeWidth = 3.4..strokeCap = StrokeCap.round;
    final ties = Paint()..color = const Color(0xFF78513B)
        ..strokeWidth = 5;

    void rails(Offset from, Offset to) {
      c.drawLine(from, to, ballast);
      if ((from.dy - to.dy).abs() < 1) {
        for (var x = from.dx; x < to.dx; x += 20) {
          c.drawLine(Offset(x, from.dy - 15),
              Offset(x, from.dy + 15), ties);
        }
      }
      c.drawLine(Offset(from.dx, from.dy - 7),
          Offset(to.dx, to.dy - 7), rail);
      c.drawLine(Offset(from.dx, from.dy + 7),
          Offset(to.dx, to.dy + 7), rail);
    }

    rails(const Offset(30, 340), const Offset(1370, 340));
    for (final st in simulation.stations) {
      final x = st.mapX;
      final cState = simulation.controls(st.id);
      for (var i = 0; i < st.platforms; i++) {
        final yy = 346.0 + i * 36;
        rails(Offset(x - 95, yy), Offset(x + 95, yy));
        rails(Offset(x - 146, 340), Offset(x - 95, yy));
        rails(Offset(x + 95, yy), Offset(x + 146, 340));
        _label(c, (i + 1).toString(),
            Offset(x - 84, yy - 34), fontSize: 13,
            color: const Color(0xFF153F67), bold: true);
        if (cState.closedTracks.contains(i)) {
          c.drawLine(Offset(x - 95, yy), Offset(x + 95, yy),
            Paint()..color = const Color(0xFFE75562)
              ..strokeWidth = 5..strokeCap = StrokeCap.round);
        }
      }

      void active(double x1, double y1, double x2, double y2) {
        c.drawLine(Offset(x1, y1), Offset(x2, y2),
          Paint()..color = const Color(0xFFCCFF63)
            ..strokeWidth = 6..strokeCap = StrokeCap.round);
        c.drawLine(Offset(x1, y1), Offset(x2, y2),
          Paint()..color = const Color(0xFF4AE579)
            ..strokeWidth = 3..strokeCap = StrokeCap.round);
      }

      active(x - 146, 340, x - 95,
          346 + cState.westTurnout * 36);
      active(x + 95, 346 + cState.eastTurnout * 36,
          x + 146, 340);
    }
  }

  void _signals(Canvas c) {
    for (final st in simulation.stations) {
      final ctrl = simulation.controls(st.id);
      _signal(c, st.mapX - 137, 315, ctrl.westEntry);
      _signal(c, st.mapX + 137, 315, ctrl.eastExit);
    }
    for (final section in simulation.sections) {
      final a = simulation.station(section.from).mapX;
      final b = simulation.station(section.to).mapX;
      final middle = (a + b) / 2;
      final isBusy = simulation.occupying(section) != null;
      _signal(c, middle, 310, !section.closed && !isBusy);
    }
  }

  void _signal(Canvas c, double x, double y, bool green) {
    c.drawLine(Offset(x, y + 25), Offset(x, y - 22),
      Paint()..color = const Color(0xFF3B5261)..strokeWidth = 7);
    c.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 12, y - 40, 24, 40),
        const Radius.circular(8)),
      Paint()..color = const Color(0xFF243A4B));
    c.drawCircle(Offset(x, y - 29), 7,
      Paint()..color = green ? const Color(0xFF345D3B)
          : const Color(0xFFFF5569));
    c.drawCircle(Offset(x, y - 11), 7,
      Paint()..color = green ? const Color(0xFF62FC7B)
          : const Color(0xFF603946));
    c.drawOval(Rect.fromCenter(center: Offset(x, y + 26),
        width: 30, height: 9),
      Paint()..color = const Color(0xFF3B5261));
  }

  void _label(Canvas canvas, String text, Offset point,
      {double fontSize = 13, Color color = Colors.white, bool bold = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      )),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, point);
  }
}

/// Compact touch target above each actual station; not painted into an image.
class PlayfulStationMarker extends PositionComponent with TapCallbacks {
  PlayfulStationMarker(this.station, this.simulation, this.onSelect)
      : super(
          position: Vector2(station.mapX - 99, 132),
          size: Vector2(198, 65),
          priority: 5,
        );

  final RailwayStation station;
  final RailwaySimulation simulation;
  final void Function(String) onSelect;

  @override
  void onTapDown(TapDownEvent event) => onSelect(station.id);

  @override
  void render(Canvas canvas) {
    const blue = Color(0xFF153F67);
    const light = Color(0xFFF4FCFF);
    final outer = Rect.fromLTWH(0, 0, size.x, size.y - 4);
    canvas.drawRRect(RRect.fromRectAndRadius(
        outer.shift(const Offset(0, 4)), const Radius.circular(17)),
      Paint()..color = const Color(0x660A3857));
    canvas.drawRRect(RRect.fromRectAndRadius(
        outer, const Radius.circular(17)),
      Paint()
        ..shader = const LinearGradient(
            colors: [Color(0xFFF7FFFF), Color(0xFFB9E5FC)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ).createShader(outer));
    canvas.drawRRect(RRect.fromRectAndRadius(
        outer.deflate(1.5), const Radius.circular(16)),
      Paint()..color = const Color(0xFF5DA6D9)
        ..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(const Offset(30, 31), 19,
      Paint()..color = const Color(0xFFFFC955));
    final icon = TextPainter(
      text: const TextSpan(text: '🚉', style: TextStyle(fontSize: 24)),
      textDirection: TextDirection.ltr,
    )..layout();
    icon.paint(canvas, const Offset(15, 15));
    final name = TextPainter(
      text: TextSpan(text: GameL10n.tr(station.name),
        style: const TextStyle(color: blue,
            fontSize: 16, fontWeight: FontWeight.w900)),
      maxLines: 1, textDirection: TextDirection.ltr,
    )..layout(maxWidth: 147);
    name.paint(canvas, const Offset(56, 10));
    final used = simulation.reservedPlatforms(station.id);
    final status = TextPainter(
      text: TextSpan(
        text: used.toString() + '/' +
            station.platforms.toString() + ' peron foglalt',
        style: const TextStyle(
            color: Color(0xFF41728B), fontSize: 11,
            fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    status.paint(canvas, const Offset(58, 35));
    canvas.drawLine(const Offset(100, 60), const Offset(100, 82),
        Paint()..color = light..strokeWidth = 3);
  }
}
