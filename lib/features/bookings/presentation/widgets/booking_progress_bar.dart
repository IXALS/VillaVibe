import 'package:flutter/material.dart';

class BookingProgressBar extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
  });

  @override
  State<BookingProgressBar> createState() => _BookingProgressBarState();
}

class _BookingProgressBarState extends State<BookingProgressBar> {
  double _widthFactor = 0.0;

  @override
  void initState() {
    super.initState();
    _updateWidthFactor();
  }

  @override
  void didUpdateWidget(BookingProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _updateWidthFactor();
    }
  }

  void _updateWidthFactor() {
    setState(() {
      _widthFactor = (widget.currentStep / widget.totalSteps).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        widthFactor: _widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
