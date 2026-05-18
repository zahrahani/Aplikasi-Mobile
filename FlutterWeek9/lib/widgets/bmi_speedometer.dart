// Widget visualisasi BMI berbentuk speedometer

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';

const double _kWidth = 260;
const double _kHeight = 160;

class BmiSpeedometer extends StatefulWidget {
  final double bmi;
  final Color bmiColor;

  /// Usia pengguna. Diisi untuk menentukan mode anak (2–18) atau dewasa.
  /// Default 0 → mode dewasa.
  final int usia;

  /// Gender pengguna ('Laki-laki' / 'Perempuan').
  /// Hanya dipakai pada mode anak untuk menentukan batas normal.
  final String gender;

  const BmiSpeedometer({
    super.key,
    required this.bmi,
    required this.bmiColor,
    this.usia = 0,
    this.gender = '',
  });

  @override
  State<BmiSpeedometer> createState() => _BmiSpeedometerState();
}

class _BmiSpeedometerState extends State<BmiSpeedometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool get _isAnak => widget.usia >= 2 && widget.usia <= 18;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final targetPosition = BmiUtils.getSpeedometerPosition(
      widget.bmi,
      usia: widget.usia,
      gender: widget.gender,
    );

    _animation = Tween<double>(begin: 0.0, end: targetPosition).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kWidth,
      height: _kHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Arc bergradasi + jarum (CustomPaint)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(_kWidth, _kHeight),
                painter: _SpeedometerPainter(
                  progress: _animation.value,
                  bmiColor: widget.bmiColor,
                  isAnak: _isAnak,
                ),
              );
            },
          ),

          // Layer 2: Text BMI
          Padding(
            padding: const EdgeInsets.only(
              top: 42,
              left: 24,
              right: 24,
              bottom: 18,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label BMI
                  Text(
                    'BMI',
                    style: TextStyle(
                      color: widget.bmiColor.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // Nilai BMI
                  Text(
                    widget.bmi.toStringAsFixed(1),
                    style: TextStyle(
                      color: widget.bmiColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter

class _SpeedometerPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color bmiColor;

  /// true  → gunakan gradient & stops zona ANAK (5 zona)
  /// false → gunakan gradient & stops zona DEWASA (6 zona)
  final bool isAnak;

  _SpeedometerPainter({
    required this.progress,
    required this.bmiColor,
    required this.isAnak,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 24);
    final double outerRadius = size.width / 2 - 12;
    const double trackWidth = 22;

    // Pilih warna & stops berdasarkan mode
    final List<Color>  gradientColors = isAnak
        ? BmiUtils.gradientColorsAnak
        : BmiUtils.gradientColorsDewasa;
    final List<double> gradientStops  = isAnak
        ? BmiUtils.gradientStopsAnak
        : BmiUtils.gradientStopsDewasa;

    // 1. Arc Gradasi (outer track)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: gradientColors,
        stops: gradientStops,
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      pi,   // Mulai dari kiri (180°)
      pi,   // Sweep ke kanan 180°
      false,
      trackPaint,
    );

    // 2. Semi Circle Grey (inner fill)
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF1F3F6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius - 30),
      pi,
      pi,
      true,
      fillPaint,
    );

    // 3. Pointer
    final angle = pi + (progress * pi);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle + pi / 2);

    final double pointerCenterY = -(outerRadius - (trackWidth / 2));

    const double pointerWidth  = 19;
    const double pointerHeight = 21;

    final path = Path()
      ..moveTo(0, pointerCenterY - (pointerHeight / 2))
      ..lineTo( pointerWidth / 2, pointerCenterY + (pointerHeight / 2))
      ..lineTo(-pointerWidth / 2, pointerCenterY + (pointerHeight / 2))
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) =>
      old.progress != progress || old.isAnak != isAnak;
}