import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthsTabView extends StatefulWidget {
  final DateTime? startDate;
  final Function(DateTime startDate, int months) onRangeChanged;
  final VoidCallback onDateTap;

  const MonthsTabView({
    super.key,
    this.startDate,
    required this.onRangeChanged,
    required this.onDateTap,
  });

  @override
  State<MonthsTabView> createState() => _MonthsTabViewState();
}

class _MonthsTabViewState extends State<MonthsTabView> {
  int _months = 6;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(MonthsTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startDate != null && widget.startDate != oldWidget.startDate) {
      _startDate = widget.startDate!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final endDate = DateTime(_startDate.year, _startDate.month + _months, _startDate.day);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: CircularDurationSlider(
              value: _months,
              min: 1,
              max: 12,
              onChanged: (val) {
                setState(() {
                  _months = val;
                });
                widget.onRangeChanged(_startDate, _months);
              },
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onDateTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('d MMM yyyy').format(_startDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
                Text(
                  DateFormat('d MMM yyyy').format(endDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class CircularDurationSlider extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const CircularDurationSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<CircularDurationSlider> createState() => _CircularDurationSliderState();
}

class _CircularDurationSliderState extends State<CircularDurationSlider> {
  late double _angle;

  @override
  void initState() {
    super.initState();
    _angle = _valueToAngle(widget.value);
  }

  double _valueToAngle(int value) {
    // Map value (min-max) to angle (-pi/2 to 3pi/2)
    // 0 degrees is at 3 o'clock. We want start at 12 o'clock (-pi/2)
    // Actually, let's say 0 is top.
    double progress = (value - widget.min) / (widget.max - widget.min);
    return -math.pi / 2 + (progress * 2 * math.pi);
  }

  int _angleToValue(double angle) {
    // Normalize angle to 0-2pi starting from top
    double normalized = angle + math.pi / 2;
    if (normalized < 0) normalized += 2 * math.pi;
    
    double progress = normalized / (2 * math.pi);
    int val = widget.min + (progress * (widget.max - widget.min)).round();
    return val.clamp(widget.min, widget.max);
  }

  void _updateAngle(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final angle = math.atan2(dy, dx);
    
    setState(() {
      _angle = angle;
      final newValue = _angleToValue(angle);
      if (newValue != widget.value) {
        widget.onChanged(newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanUpdate: (details) => _updateAngle(details.localPosition, Size(size, size)),
          onPanDown: (details) => _updateAngle(details.localPosition, Size(size, size)),
          child: CustomPaint(
            size: Size(size, size),
            painter: _SliderPainter(
              value: widget.value,
              min: widget.min,
              max: widget.max,
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.value}',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Text(
                      'months',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final int value;
  final int min;
  final int max;

  _SliderPainter({required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw background track
    final trackPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw ticks
    final tickPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i / 12) * 2 * math.pi;
      final tickRadius = radius - 35; // Inner ticks
      final dx = center.dx + tickRadius * math.cos(angle);
      final dy = center.dy + tickRadius * math.sin(angle);
      canvas.drawCircle(Offset(dx, dy), 2, tickPaint);
    }

    // Draw active arc
    final progress = (value - min) / (max - min);
    final sweepAngle = progress * 2 * math.pi;
    
    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF5A5F), // Airbnb-ish red/pink
          Color(0xFFE31C5F),
          Color(0xFFD90B56),
        ],
        transform: GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // Draw knob
    final knobAngle = -math.pi / 2 + sweepAngle;
    final knobCenter = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );

    // Knob shadow
    canvas.drawCircle(
      knobCenter,
      22,
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Knob body
    canvas.drawCircle(
      knobCenter,
      18,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
