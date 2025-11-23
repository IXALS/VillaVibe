import 'package:flutter/material.dart';
import 'package:villavibe/core/router/app_router.dart';

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

class _BookingProgressBarState extends State<BookingProgressBar>
    with RouteAware {
  double _widthFactor = 0.0;
  Duration _animationDuration = const Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    // Forward Animation: Start from previous step (e.g., 0.2)
    _widthFactor =
        ((widget.currentStep - 1) / widget.totalSteps).clamp(0.0, 1.0);

    // Animate to current step (e.g., 0.4) after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _widthFactor =
              (widget.currentStep / widget.totalSteps).clamp(0.0, 1.0);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Backward Animation:
    // We are returning to this screen from a later step.
    // 1. Instantly snap to the "next" step (e.g., 0.6) so it looks like we are starting there.
    setState(() {
      _animationDuration = Duration.zero;
      _widthFactor =
          ((widget.currentStep + 1) / widget.totalSteps).clamp(0.0, 1.0);
    });

    // 2. Smoothly animate down to the current step (e.g., 0.4).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animationDuration = const Duration(milliseconds: 800);
          _widthFactor =
              (widget.currentStep / widget.totalSteps).clamp(0.0, 1.0);
        });
      }
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
        duration: _animationDuration,
        curve: Curves.easeInOut,
        widthFactor: _widthFactor,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black, // Updated to Black
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
