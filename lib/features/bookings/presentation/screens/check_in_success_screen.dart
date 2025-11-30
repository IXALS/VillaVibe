import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class CheckInSuccessScreen extends StatefulWidget {
  final Property property;

  const CheckInSuccessScreen({super.key, required this.property});

  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessScreenState();
}

class _CheckInSuccessScreenState extends State<CheckInSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-close after 3 seconds (allowing for entrance animation + hold time)
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Animated Check Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.check, size: 48, color: Colors.green),
          )
          .animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 400.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Check-in Completed',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          )
          .animate()
          .fadeIn(delay: 200.ms)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          
          const SizedBox(height: 8),
          
          Text(
            'Welcome to ${widget.property.name}!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          )
          .animate()
          .fadeIn(delay: 400.ms)
          .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

}
