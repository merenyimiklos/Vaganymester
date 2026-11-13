import 'dart:async';
import 'package:flutter/material.dart';

enum GameAlertStyle { info, success, warning, danger }

/// Large, legible game alert with a close button. Never a tiny system snackbar.
class GameAlertCard extends StatelessWidget {
  const GameAlertCard({
    super.key, required this.message, required this.onClose,
    this.title, this.style = GameAlertStyle.info,
  });
  final String message;
  final String? title;
  final VoidCallback onClose;
  final GameAlertStyle style;

  @override
  Widget build(BuildContext context) {
    final accent = switch (style) {
      GameAlertStyle.info => const Color(0xFF1477B5),
      GameAlertStyle.success => const Color(0xFF1D956F),
      GameAlertStyle.warning => const Color(0xFFE39B19),
      GameAlertStyle.danger => const Color(0xFFE34F64),
    };
    final icon = switch (style) {
      GameAlertStyle.info => Icons.info_rounded,
      GameAlertStyle.success => Icons.check_circle_rounded,
      GameAlertStyle.warning => Icons.warning_amber_rounded,
      GameAlertStyle.danger => Icons.dangerous_rounded,
    };
    final heading = title ?? switch(style) {
      GameAlertStyle.info => 'FORGALMI ÜZENET',
      GameAlertStyle.success => 'SIKERES MŰVELET',
      GameAlertStyle.warning => 'FIGYELEM!',
      GameAlertStyle.danger => 'VESZÉLY!',
    };
    return Material(
      color: Colors.transparent,
      elevation: 17,
      shadowColor: const Color(0x99072A48),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FDFF),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: accent, width: 3)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(children: [
          CircleAvatar(radius: 23, backgroundColor: accent,
            child: Icon(icon, color: Colors.white, size: 25)),
          const SizedBox(width: 11),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(heading, style: TextStyle(color: accent,
                fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(message, maxLines: 3, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF16405B),
                  fontSize: 13, fontWeight: FontWeight.w700)),
            ])),
          IconButton(onPressed: onClose,
            tooltip: 'Bezárás',
            icon: const Icon(Icons.close_rounded,
              color: Color(0xFF345D73))),
        ]),
      ),
    );
  }
}

Future<void> showGameMessage(
  BuildContext context, String message, {
    GameAlertStyle style = GameAlertStyle.info,
    Duration duration = const Duration(seconds: 5),
  }) => showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TimedAlert(message: message, duration: duration,
        style: style),
  );

class _TimedAlert extends StatefulWidget {
  const _TimedAlert({required this.message,
      required this.duration, required this.style});
  final String message;
  final Duration duration;
  final GameAlertStyle style;
  @override
  State<_TimedAlert> createState() => _TimedAlertState();
}
class _TimedAlertState extends State<_TimedAlert> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _close);
  }
  void _close() {
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      Navigator.of(context).pop();
    }
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: GameAlertCard(message: widget.message, style: widget.style,
        onClose: _close),
    ),
  );
}
