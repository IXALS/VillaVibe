import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThreeDotsLoader extends StatelessWidget {
  final Color color;
  final double size;

  const ThreeDotsLoader({
    super.key,
    this.color = Colors.black54,
    this.size = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 600.ms,
          delay: (index * 200).ms,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        )
        .fade(
          duration: 600.ms,
          delay: (index * 200).ms,
          begin: 0.5,
          end: 1.0,
        );
  }
}
