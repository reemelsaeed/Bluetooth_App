import 'package:flutter/material.dart';
import 'dart:math' as math;

class PressureGauge extends StatelessWidget {
  final double current;
  final double target;
  final double max;

  const PressureGauge({
    super.key,
    required this.current,
    required this.target,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final double safeMax = max;
    final double progress = (current / safeMax).clamp(0.0, 1.0);

    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: GaugePainter(progress: progress, max: safeMax, target: target),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                current.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const Text(
                'PSI',
                style: TextStyle(fontSize: 16, color: Color(0xFF0097A7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final double max;
  final double target;

  static const double startAngle = 150 * math.pi / 180;
  static const double sweepAngle = 240 * math.pi / 180;

  GaugePainter({
    required this.progress,
    required this.max,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    _drawTrack(canvas, center, radius);
    _drawTargetMarker(canvas, center, radius);
    _drawProgress(canvas, center, radius);
    _drawNeedle(canvas, center, radius);
    _drawCenter(canvas, center);
    _drawLabels(canvas, center, radius);
  }

  void _drawTrack(Canvas canvas, Offset center, double radius) {
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = const Color(0xFFCFD8DC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawProgress(Canvas canvas, Offset center, double radius) {
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: const [Color(0xFF0097A7), Color(0xFF1565C0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTargetMarker(Canvas canvas, Offset center, double radius) {
    if (target <= 0 || max <= 0) return;
    final double targetProgress = (target / max).clamp(0.0, 1.0);
    final double targetAngle = startAngle + sweepAngle * targetProgress;

    final innerR = radius - 14;
    final outerR = radius + 14;

    final p1 = Offset(
      center.dx + innerR * math.cos(targetAngle),
      center.dy + innerR * math.sin(targetAngle),
    );
    final p2 = Offset(
      center.dx + outerR * math.cos(targetAngle),
      center.dy + outerR * math.sin(targetAngle),
    );

    canvas.drawLine(
      p1,
      p2,
      Paint()
        ..color = const Color(0xFF00838F)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // draw target value at marker
    final labelRadius = radius * 0.75;
    final labelPos = Offset(
      center.dx + labelRadius * math.cos(targetAngle),
      center.dy + labelRadius * math.sin(targetAngle),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: target.toInt().toString(),
        style: const TextStyle(
          color: Color(0xFF00838F),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
    );
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final needleAngle = startAngle + sweepAngle * progress;
    final needleEnd = Offset(
      center.dx + radius * 0.7 * math.cos(needleAngle),
      center.dy + radius * 0.7 * math.sin(needleAngle),
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = const Color(0xFF616161)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // draw current value at needle tip
    final labelRadius = radius * 0.85;
    final labelPos = Offset(
      center.dx + labelRadius * math.cos(needleAngle),
      center.dy + labelRadius * math.sin(needleAngle),
    );

    final tp = TextPainter(
      text: TextSpan(
        text: (max * progress).toStringAsFixed(0),
        style: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
    );
  }

  void _drawCenter(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 8, Paint()..color = const Color(0xFF1A73E8));
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    _drawText(canvas, '0', startAngle, center, radius);
    _drawText(
      canvas,
      max.toInt().toString(),
      startAngle + sweepAngle,
      center,
      radius,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double angle,
    Offset center,
    double radius,
  ) {
    final x = center.dx + (radius + 22) * math.cos(angle);
    final y = center.dy + (radius + 22) * math.sin(angle);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF546E7A), fontSize: 13),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.progress != progress || old.target != target || old.max != max;
}
