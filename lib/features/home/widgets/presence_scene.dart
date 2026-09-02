import 'package:flutter/material.dart';

import '../../../design_system/xiaxia_tokens.dart';
import '../../../domain/presence/presence_state.dart';

class PresenceScene extends StatelessWidget {
  const PresenceScene({super.key, required this.presence});

  final PresenceState presence;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: _semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 1.42,
          child: CustomPaint(
            painter: _PresenceScenePainter(mode: presence.mode, dark: dark),
          ),
        ),
      ),
    );
  }

  String get _semanticLabel => switch (presence.mode) {
        PresenceMode.trace => '窗边留着书与杯子的安静房间',
        PresenceMode.shadow => '窗边的安静房间里有一只小猫影子',
        PresenceMode.embodied => '为夏夏的短暂视觉出现预留的位置',
        PresenceMode.absent => '安静、无人出现的房间',
      };
}

class _PresenceScenePainter extends CustomPainter {
  const _PresenceScenePainter({required this.mode, required this.dark});

  final PresenceMode mode;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF30342F), Color(0xFF1E211E)]
            : const [Color(0xFFF4EBDD), Color(0xFFDAD8C8)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = dark ? const Color(0xFF4B5149) : const Color(0xFFBFB8AA)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final warm = Paint()
      ..color = dark ? const Color(0xFF777A65) : const Color(0xFFD8C6A4);
    final ink = Paint()
      ..color = dark ? const Color(0xFF111310) : const Color(0xFF353630);

    // Window and quiet curtain folds.
    final window = Rect.fromLTWH(size.width * .08, size.height * .09, size.width * .5, size.height * .58);
    canvas.drawRRect(RRect.fromRectAndRadius(window, const Radius.circular(4)), Paint()..color = dark ? const Color(0xFF252A27) : const Color(0xFFECE7D9));
    canvas.drawLine(Offset(window.center.dx, window.top), Offset(window.center.dx, window.bottom), line);
    canvas.drawLine(Offset(window.left, window.center.dy), Offset(window.right, window.center.dy), line);
    canvas.drawPath(
      Path()
        ..moveTo(window.left + size.width * .08, window.top)
        ..quadraticBezierTo(window.left + size.width * .02, window.center.dy, window.left + size.width * .09, window.bottom),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(window.right - size.width * .08, window.top)
        ..quadraticBezierTo(window.right - size.width * .01, window.center.dy, window.right - size.width * .08, window.bottom),
      line,
    );

    if (mode == PresenceMode.absent) {
      final quiet = Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, warm.color.withAlpha(40)],
        ).createShader(Rect.fromLTWH(0, size.height * .6, size.width, size.height * .4));
      canvas.drawRect(Rect.fromLTWH(0, size.height * .6, size.width, size.height * .4), quiet);
      return;
    }

    // Desk, a cup, an open book, and a small vase: trace before avatar.
    canvas.drawRect(Rect.fromLTWH(size.width * .04, size.height * .72, size.width * .92, size.height * .07), Paint()..color = dark ? const Color(0xFF3B3C34) : const Color(0xFFC2AB8C));
    canvas.drawRect(Rect.fromLTWH(size.width * .13, size.height * .78, size.width * .035, size.height * .22), ink);
    canvas.drawRect(Rect.fromLTWH(size.width * .82, size.height * .78, size.width * .035, size.height * .22), ink);

    final bookLeft = Path()
      ..moveTo(size.width * .32, size.height * .66)
      ..lineTo(size.width * .49, size.height * .69)
      ..lineTo(size.width * .49, size.height * .79)
      ..lineTo(size.width * .31, size.height * .75)
      ..close();
    final bookRight = Path()
      ..moveTo(size.width * .49, size.height * .69)
      ..lineTo(size.width * .65, size.height * .65)
      ..lineTo(size.width * .67, size.height * .75)
      ..lineTo(size.width * .49, size.height * .79)
      ..close();
    canvas.drawPath(bookLeft, Paint()..color = dark ? const Color(0xFFC0B7A4) : const Color(0xFFF7F0E4));
    canvas.drawPath(bookRight, Paint()..color = dark ? const Color(0xFFAAA28F) : const Color(0xFFEDE4D5));
    canvas.drawLine(Offset(size.width * .49, size.height * .69), Offset(size.width * .49, size.height * .79), line);

    final cup = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .71, size.height * .62, size.width * .1, size.height * .12),
      const Radius.circular(8),
    );
    canvas.drawRRect(cup, Paint()..color = dark ? const Color(0xFF8C8F80) : XiaxiaColors.sage);
    canvas.drawCircle(Offset(size.width * .82, size.height * .68), size.width * .035, line);

    canvas.drawLine(Offset(size.width * .22, size.height * .7), Offset(size.width * .2, size.height * .49), line);
    canvas.drawCircle(Offset(size.width * .2, size.height * .47), size.width * .018, warm);
    canvas.drawCircle(Offset(size.width * .17, size.height * .5), size.width * .016, warm);
    canvas.drawCircle(Offset(size.width * .23, size.height * .51), size.width * .015, warm);

    if (mode == PresenceMode.shadow) _paintCat(canvas, size, ink);
    if (mode == PresenceMode.embodied) _paintEmbodiedSeam(canvas, size, line, warm);
  }

  void _paintCat(Canvas canvas, Size size, Paint ink) {
    final center = Offset(size.width * .74, size.height * .82);
    canvas.drawOval(Rect.fromCenter(center: center, width: size.width * .24, height: size.height * .15), ink);
    canvas.drawCircle(Offset(size.width * .63, size.height * .78), size.width * .045, ink);
    final ears = Path()
      ..moveTo(size.width * .59, size.height * .75)
      ..lineTo(size.width * .605, size.height * .69)
      ..lineTo(size.width * .63, size.height * .75)
      ..lineTo(size.width * .65, size.height * .69)
      ..lineTo(size.width * .67, size.height * .76)
      ..close();
    canvas.drawPath(ears, ink);
    final tail = Paint()
      ..color = ink.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .025
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(size.width * .78, size.height * .74, size.width * .17, size.height * .18),
      -.4,
      3.4,
      false,
      tail,
    );
  }

  void _paintEmbodiedSeam(Canvas canvas, Size size, Paint line, Paint warm) {
    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * .64, size.height * .16, size.width * .24, size.height * .36),
      const Radius.circular(10),
    );
    canvas.drawRRect(frame, Paint()..color = warm.color.withAlpha(60));
    canvas.drawRRect(frame, line);
    canvas.drawCircle(Offset(size.width * .76, size.height * .29), size.width * .045, line);
    canvas.drawArc(
      Rect.fromLTWH(size.width * .69, size.height * .32, size.width * .14, size.height * .15),
      3.14,
      3.14,
      false,
      line,
    );
  }

  @override
  bool shouldRepaint(_PresenceScenePainter oldDelegate) {
    return mode != oldDelegate.mode || dark != oldDelegate.dark;
  }
}
