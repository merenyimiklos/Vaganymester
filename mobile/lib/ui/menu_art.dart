import 'package:flutter/material.dart';

/// Decorative, original vector backdrop. It is only used by the front menu.
class MenuScenePainter extends CustomPainter {
  const MenuScenePainter();

  @override
  void paint(Canvas c, Size size) {
    c.save();
    c.scale(size.width / 1400, size.height / 650);
    final bg = const Rect.fromLTWH(0, 0, 1400, 650);
    c.drawRect(bg, Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF5ABEF5), Color(0xFFC8F5FF),
          Color(0xFFA2E581), Color(0xFF47B85A)],
        stops: [0, .44, .48, 1],
      ).createShader(bg));
    // Puffy clouds.
    final cloud = Paint()..color = const Color(0xDFFFFFFF);
    for (final location in <(double, double)>[
      (200, 80), (485, 135), (815, 71), (1185, 111),
    ]) {
      final x = location.$1, y = location.$2;
      c.drawOval(Rect.fromLTWH(x - 55, y, 120, 38), cloud);
      c.drawCircle(Offset(x - 15, y), 28, cloud);
      c.drawCircle(Offset(x + 23, y - 13), 36, cloud);
    }
    // Distant hills.
    final distant = Path()
      ..moveTo(0, 358)..lineTo(0, 240)
      ..quadraticBezierTo(140, 135, 294, 257)
      ..quadraticBezierTo(405, 164, 550, 252)
      ..quadraticBezierTo(690, 145, 832, 262)
      ..quadraticBezierTo(1067, 160, 1224, 251)
      ..quadraticBezierTo(1340, 207, 1400, 257)
      ..lineTo(1400, 357)..close();
    c.drawPath(distant, Paint()..color = const Color(0xFF8FC6C2));
    final foreground = Path()
      ..moveTo(0, 404)..lineTo(0, 306)
      ..quadraticBezierTo(200, 209, 368, 325)
      ..quadraticBezierTo(555, 223, 735, 326)
      ..quadraticBezierTo(931, 236, 1101, 322)
      ..quadraticBezierTo(1290, 231, 1400, 321)
      ..lineTo(1400, 404)..close();
    c.drawPath(foreground, Paint()..color = const Color(0xFF73BC77));

    // Station: cream facade with warm-red tile roof.
    final building = Rect.fromLTWH(500, 283, 356, 184);
    c.drawRRect(RRect.fromRectAndRadius(building,
        const Radius.circular(17)), Paint()..color = const Color(0xFFFFE5A7));
    c.drawRRect(RRect.fromRectAndRadius(
        building.deflate(10), const Radius.circular(12)),
      Paint()..color = const Color(0xFFFFF0C4));
    final roof = Path()
      ..moveTo(472, 304)..lineTo(678, 223)
      ..lineTo(888, 304)..close();
    c.drawPath(roof, Paint()..color = const Color(0xFFB95048));
    c.drawLine(const Offset(476, 302), const Offset(679, 225),
      Paint()..color = const Color(0xFFFCA47B)..strokeWidth = 12);
    c.drawLine(const Offset(679, 225), const Offset(884, 302),
      Paint()..color = const Color(0xFFFCA47B)..strokeWidth = 12);
    for (final x in <double>[545, 615, 741, 811]) {
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 348, 38, 78),
          const Radius.circular(16)),
        Paint()..color = const Color(0xFF24648D));
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 4, 354, 30, 68),
          const Radius.circular(12)),
        Paint()..color = const Color(0xFF7EE1F7));
    }
    c.drawCircle(const Offset(679, 301), 29,
      Paint()..color = const Color(0xFF19507C));
    c.drawCircle(const Offset(679, 301), 25,
      Paint()..color = Colors.white);
    c.drawLine(const Offset(679, 301), const Offset(679, 286),
      Paint()..color = const Color(0xFF19507C)..strokeWidth = 3);
    c.drawLine(const Offset(679, 301), const Offset(693, 309),
      Paint()..color = const Color(0xFF19507C)..strokeWidth = 3);

    // Trees and bushes.
    for (final t in <(double,double,double)>[
      (85, 351, 1.1), (290, 366, .8), (410, 333, .85),
      (930, 365, 1.0), (1055, 332, .85), (1324, 344, 1.25),
    ]) {
      _tree(c, t.$1, t.$2, t.$3);
    }

    // Clean railroad, with wood ties, rails and toy-train silhouette.
    final tie = Paint()..color = const Color(0xFF7E6149)..strokeWidth = 11;
    final rail = Paint()..color = const Color(0xFFDBE9EC)
      ..strokeWidth = 7..strokeCap = StrokeCap.round;
    c.drawRect(const Rect.fromLTWH(0, 480, 1400, 110),
      Paint()..color = const Color(0xFFAEA99C));
    for (var x = 0.0; x < 1400; x += 38) {
      c.drawLine(Offset(x, 490), Offset(x, 579), tie);
    }
    for (final y in <double>[505, 558]) {
      c.drawLine(Offset(0, y), Offset(1400, y), rail);
    }
    final car = Rect.fromLTWH(302, 445, 400, 83);
    c.drawRRect(RRect.fromRectAndRadius(car,
        const Radius.circular(28)),
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFFFFDF91), Color(0xFFFFB942),
          Color(0xFFE9941E)],
      ).createShader(car));
    for (var i = 0; i < 7; i++) {
      c.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(330.0 + i * 51, 459, 36, 28),
          const Radius.circular(8)),
        Paint()..color = const Color(0xFF287CB3));
    }
    c.drawRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(320, 495, 360, 10),
        const Radius.circular(5)),
      Paint()..color = const Color(0xFFFFFFFF));
    for (final x in <double>[365, 614]) {
      c.drawCircle(Offset(x, 529), 14,
        Paint()..color = const Color(0xFF2C4D62));
    }
    c.drawCircle(const Offset(686, 495), 11,
      Paint()..color = const Color(0xFFFFF5A8));

    c.restore();
  }

  void _tree(Canvas c, double x, double y, double scale) {
    c.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(x - 9 * scale, y - 13 * scale,
          18 * scale, 87 * scale),
      const Radius.circular(5)),
      Paint()..color = const Color(0xFF8D6445));
    c.drawCircle(Offset(x, y - 36 * scale), 59 * scale,
      Paint()..color = const Color(0xFF2F9144));
    c.drawCircle(Offset(x - 32 * scale, y - 62 * scale),
        38 * scale, Paint()..color = const Color(0xFF60B94B));
    c.drawCircle(Offset(x + 30 * scale, y - 81 * scale),
        42 * scale, Paint()..color = const Color(0xFF89D063));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
