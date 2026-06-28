import 'package:flutter/material.dart';
import '../namaz_guide_model.dart';

class PostureIllustration extends StatelessWidget {
  final PrayerPosture posture;
  final Color color;
  final double size;

  const PostureIllustration({
    super.key,
    required this.posture,
    required this.color,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _PosturePainter(posture: posture, color: color),
      ),
    );
  }
}

class _PosturePainter extends CustomPainter {
  final PrayerPosture posture;
  final Color color;

  _PosturePainter({required this.posture, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawMat(canvas, w, h);

    switch (posture) {
      case PrayerPosture.standing:
        _drawStanding(canvas, w, h, armsFolded: false);
        break;
      case PrayerPosture.qiyam:
        _drawStanding(canvas, w, h, armsFolded: true);
        break;
      case PrayerPosture.handsRaised:
        _drawStanding(canvas, w, h, armsFolded: false, armsRaised: true);
        break;
      case PrayerPosture.qaumah:
        _drawStanding(canvas, w, h, armsFolded: false);
        break;
      case PrayerPosture.ruku:
        _drawRuku(canvas, w, h);
        break;
      case PrayerPosture.sujud:
        _drawSujud(canvas, w, h);
        break;
      case PrayerPosture.jalsa:
        _drawSitting(canvas, w, h, pointFinger: false, turnHead: false);
        break;
      case PrayerPosture.tashahhud:
        _drawSitting(canvas, w, h, pointFinger: true, turnHead: false);
        break;
      case PrayerPosture.tasleem:
        _drawSitting(canvas, w, h, pointFinger: false, turnHead: true);
        break;
    }
  }

  // ---------------- Prayer mat ----------------
  void _drawMat(Canvas canvas, double w, double h) {
    final matRect = Rect.fromLTWH(w * 0.08, h * 0.86, w * 0.84, h * 0.12);
    final matFill = Paint()..color = color.withValues(alpha: 0.08);
    final matBorder = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012;
    final rrect = RRect.fromRectAndRadius(matRect, Radius.circular(w * 0.03));
    canvas.drawRRect(rrect, matFill);
    canvas.drawRRect(rrect, matBorder);
    // inner decorative border (like a janamaz pattern)
    final innerRect = matRect.deflate(w * 0.025);
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(w * 0.02)),
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.006,
    );
  }

  // ---------------- Head + Cap + Face ----------------
  void _drawHead(Canvas canvas, double cx, double cy, double r, {double tilt = 0}) {
    final headFill = Paint()..color = color;
    final eyeFill = Paint()..color = Colors.white;
    final capFill = Paint()..color = Colors.white;
    final capOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(tilt);

    // Head circle
    canvas.drawCircle(Offset.zero, r, headFill);

    // Cap (small dome on top of head)
    final capRect = Rect.fromCenter(center: Offset(0, -r * 0.55), width: r * 1.5, height: r * 1.1);
    canvas.drawArc(capRect, -3.3, -3.0, false, capFill..style = PaintingStyle.fill);
    canvas.drawArc(capRect, -3.3, -3.0, false, capOutline);

    // Eyes
    canvas.drawCircle(Offset(-r * 0.35, r * 0.05), r * 0.13, eyeFill);
    canvas.drawCircle(Offset(r * 0.35, r * 0.05), r * 0.13, eyeFill);

    canvas.restore();
  }

  // ---------------- Standing figure ----------------
  void _drawStanding(Canvas canvas, double w, double h, {required bool armsFolded, bool armsRaised = false}) {
    final cx = w * 0.5;
    final robeFill = Paint()..color = color.withValues(alpha: 0.14);
    final robeOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;
    final limbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    final handFill = Paint()..color = color;

    // Head + cap
    _drawHead(canvas, cx, h * 0.11, w * 0.085);

    // Neck
    canvas.drawLine(Offset(cx, h * 0.18), Offset(cx, h * 0.22), robeOutline);

    // Robe — shoulders to flared hem, with feet peeking out
    final robe = Path()
      ..moveTo(cx - w * 0.13, h * 0.23)
      ..lineTo(cx + w * 0.13, h * 0.23)
      ..quadraticBezierTo(cx + w * 0.24, h * 0.55, cx + w * 0.22, h * 0.88)
      ..quadraticBezierTo(cx + w * 0.1, h * 0.93, cx, h * 0.9)
      ..quadraticBezierTo(cx - w * 0.1, h * 0.93, cx - w * 0.22, h * 0.88)
      ..quadraticBezierTo(cx - w * 0.24, h * 0.55, cx - w * 0.13, h * 0.23)
      ..close();
    canvas.drawPath(robe, robeFill);
    canvas.drawPath(robe, robeOutline);

    // Feet
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.07, h * 0.91), width: w * 0.08, height: h * 0.025), handFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.07, h * 0.91), width: w * 0.08, height: h * 0.025), handFill);

    // Arms
    if (armsRaised) {
      canvas.drawLine(Offset(cx - w * 0.13, h * 0.27), Offset(cx - w * 0.3, h * 0.1), limbPaint);
      canvas.drawLine(Offset(cx + w * 0.13, h * 0.27), Offset(cx + w * 0.3, h * 0.1), limbPaint);
      canvas.drawCircle(Offset(cx - w * 0.3, h * 0.1), w * 0.03, handFill);
      canvas.drawCircle(Offset(cx + w * 0.3, h * 0.1), w * 0.03, handFill);
    } else if (armsFolded) {
      canvas.drawLine(Offset(cx - w * 0.13, h * 0.29), Offset(cx + w * 0.04, h * 0.4), limbPaint);
      canvas.drawLine(Offset(cx + w * 0.13, h * 0.29), Offset(cx - w * 0.04, h * 0.43), limbPaint);
      canvas.drawCircle(Offset(cx + w * 0.04, h * 0.4), w * 0.03, handFill);
      canvas.drawCircle(Offset(cx - w * 0.04, h * 0.43), w * 0.03, handFill);
    } else {
      canvas.drawLine(Offset(cx - w * 0.13, h * 0.29), Offset(cx - w * 0.2, h * 0.58), limbPaint);
      canvas.drawLine(Offset(cx + w * 0.13, h * 0.29), Offset(cx + w * 0.2, h * 0.58), limbPaint);
      canvas.drawCircle(Offset(cx - w * 0.2, h * 0.58), w * 0.03, handFill);
      canvas.drawCircle(Offset(cx + w * 0.2, h * 0.58), w * 0.03, handFill);
    }
  }

  // ---------------- Ruku (bowing) ----------------
  void _drawRuku(Canvas canvas, double w, double h) {
    final robeFill = Paint()..color = color.withValues(alpha: 0.14);
    final robeOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;
    final limbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    final handFill = Paint()..color = color;

    _drawHead(canvas, w * 0.78, h * 0.46, w * 0.075, tilt: 0.35);

    final robe = Path()
      ..moveTo(w * 0.68, h * 0.5)
      ..quadraticBezierTo(w * 0.48, h * 0.5, w * 0.32, h * 0.58)
      ..quadraticBezierTo(w * 0.22, h * 0.72, w * 0.2, h * 0.86)
      ..quadraticBezierTo(w * 0.28, h * 0.9, w * 0.34, h * 0.86)
      ..quadraticBezierTo(w * 0.36, h * 0.72, w * 0.44, h * 0.62)
      ..quadraticBezierTo(w * 0.58, h * 0.56, w * 0.72, h * 0.55)
      ..close();
    canvas.drawPath(robe, robeFill);
    canvas.drawPath(robe, robeOutline);

    // feet
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.22, h * 0.87), width: w * 0.07, height: h * 0.02), handFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.34, h * 0.87), width: w * 0.07, height: h * 0.02), handFill);

    // arm reaching to knee
    canvas.drawLine(Offset(w * 0.55, h * 0.54), Offset(w * 0.4, h * 0.63), limbPaint);
    canvas.drawCircle(Offset(w * 0.4, h * 0.63), w * 0.028, handFill);
  }

  // ---------------- Sujud (prostration) ----------------
  void _drawSujud(Canvas canvas, double w, double h) {
    final robeFill = Paint()..color = color.withValues(alpha: 0.14);
    final robeOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;
    final limbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    final handFill = Paint()..color = color;

    _drawHead(canvas, w * 0.22, h * 0.82, w * 0.07, tilt: -0.9);

    final robe = Path()
      ..moveTo(w * 0.28, h * 0.8)
      ..quadraticBezierTo(w * 0.42, h * 0.62, w * 0.56, h * 0.56)
      ..quadraticBezierTo(w * 0.68, h * 0.58, w * 0.74, h * 0.7)
      ..quadraticBezierTo(w * 0.78, h * 0.8, w * 0.8, h * 0.87)
      ..quadraticBezierTo(w * 0.72, h * 0.9, w * 0.65, h * 0.87)
      ..quadraticBezierTo(w * 0.6, h * 0.76, w * 0.52, h * 0.7)
      ..quadraticBezierTo(w * 0.4, h * 0.74, w * 0.3, h * 0.84)
      ..close();
    canvas.drawPath(robe, robeFill);
    canvas.drawPath(robe, robeOutline);

    // feet
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.79, h * 0.88), width: w * 0.07, height: h * 0.02), handFill);

    // forearms on ground near head
    canvas.drawLine(Offset(w * 0.32, h * 0.84), Offset(w * 0.2, h * 0.89), limbPaint);
    canvas.drawCircle(Offset(w * 0.2, h * 0.89), w * 0.028, handFill);
  }

  // ---------------- Sitting (Jalsa / Tashahhud / Tasleem) ----------------
  void _drawSitting(Canvas canvas, double w, double h, {required bool pointFinger, required bool turnHead}) {
    final cx = w * 0.5;
    final headX = turnHead ? cx - w * 0.1 : cx;
    final robeFill = Paint()..color = color.withValues(alpha: 0.14);
    final robeOutline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;
    final limbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    final handFill = Paint()..color = color;

    _drawHead(canvas, headX, h * 0.27, w * 0.08, tilt: turnHead ? -0.3 : 0);

    // Torso + folded legs (sitting on heels)
    final robe = Path()
      ..moveTo(cx - w * 0.12, h * 0.36)
      ..lineTo(cx + w * 0.12, h * 0.36)
      ..quadraticBezierTo(cx + w * 0.18, h * 0.5, cx + w * 0.16, h * 0.64)
      ..quadraticBezierTo(cx + w * 0.3, h * 0.74, cx + w * 0.34, h * 0.87)
      ..quadraticBezierTo(cx + w * 0.15, h * 0.93, cx, h * 0.9)
      ..quadraticBezierTo(cx - w * 0.15, h * 0.93, cx - w * 0.34, h * 0.87)
      ..quadraticBezierTo(cx - w * 0.3, h * 0.74, cx - w * 0.16, h * 0.64)
      ..quadraticBezierTo(cx - w * 0.18, h * 0.5, cx - w * 0.12, h * 0.36)
      ..close();
    canvas.drawPath(robe, robeFill);
    canvas.drawPath(robe, robeOutline);

    // Arms resting on thighs
    canvas.drawLine(Offset(cx - w * 0.12, h * 0.4), Offset(cx - w * 0.22, h * 0.62), limbPaint);
    canvas.drawCircle(Offset(cx - w * 0.22, h * 0.62), w * 0.026, handFill);

    if (pointFinger) {
      canvas.drawLine(Offset(cx + w * 0.12, h * 0.4), Offset(cx + w * 0.24, h * 0.6), limbPaint);
      canvas.drawLine(Offset(cx + w * 0.24, h * 0.6), Offset(cx + w * 0.3, h * 0.5), limbPaint); // raised finger
      canvas.drawCircle(Offset(cx + w * 0.3, h * 0.5), w * 0.018, handFill);
    } else {
      canvas.drawLine(Offset(cx + w * 0.12, h * 0.4), Offset(cx + w * 0.22, h * 0.62), limbPaint);
      canvas.drawCircle(Offset(cx + w * 0.22, h * 0.62), w * 0.026, handFill);
    }
  }

  @override
  bool shouldRepaint(covariant _PosturePainter oldDelegate) =>
      oldDelegate.posture != posture || oldDelegate.color != color;
}