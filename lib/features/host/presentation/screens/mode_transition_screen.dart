import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/host/presentation/providers/host_mode_provider.dart';

class ModeTransitionScreen extends ConsumerStatefulWidget {
  final bool targetIsHost;

  const ModeTransitionScreen({super.key, required this.targetIsHost});

  @override
  ConsumerState<ModeTransitionScreen> createState() => _ModeTransitionScreenState();
}

class _ModeTransitionScreenState extends ConsumerState<ModeTransitionScreen> {
  @override
  void initState() {
    super.initState();
    _handleTransition();
  }

  Future<void> _handleTransition() async {
    // Wait for animation to play
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      // Switch mode
      ref.read(hostModeProvider.notifier).state = widget.targetIsHost;
      
      // Pop the screen (slide down)
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSwitchingToHost = widget.targetIsHost;
    final brandColor = const Color(0xFFE31C5F);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                isSwitchingToHost ? LucideIcons.home : LucideIcons.user,
                size: 48,
                color: Colors.white,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),
            
            const SizedBox(height: 32),
            
            // Text
            Text(
              isSwitchingToHost ? 'Switching to Host' : 'Switching to Guest',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            
            const SizedBox(height: 12),
            
            Text(
              isSwitchingToHost 
                  ? 'Preparing your dashboard...' 
                  : 'Finding your next getaway...',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms),
            
            const SizedBox(height: 48),
            
            // Loading Indicator
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(brandColor),
                strokeWidth: 2,
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
