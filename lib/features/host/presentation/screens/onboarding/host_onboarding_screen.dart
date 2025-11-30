import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villavibe/features/host/presentation/providers/host_mode_provider.dart';
import 'package:villavibe/features/host/presentation/screens/onboarding/steps/step_basics.dart';
import 'package:villavibe/features/host/presentation/screens/onboarding/steps/step_finish.dart';
import 'package:villavibe/features/host/presentation/screens/onboarding/steps/step_vibe.dart';

import 'package:villavibe/features/host/presentation/providers/host_onboarding_provider.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class HostOnboardingScreen extends ConsumerStatefulWidget {
  final Property? initialProperty;

  const HostOnboardingScreen({super.key, this.initialProperty});

  @override
  ConsumerState<HostOnboardingScreen> createState() =>
      _HostOnboardingScreenState();
}

class _HostOnboardingScreenState extends ConsumerState<HostOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProperty != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(hostOnboardingNotifierProvider.notifier).initializeFromProperty(widget.initialProperty!);
      });
    }
  }

  final List<Widget> _steps = const [
    StepBasics(),
    StepVibe(),
    StepFinish(),
  ];

  Future<void> _nextPage() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Publish or Update Listing
      try {
        final notifier = ref.read(hostOnboardingNotifierProvider.notifier);
        final state = ref.read(hostOnboardingNotifierProvider);
        
        if (state.propertyId != null) {
          await notifier.updateListing();
        } else {
          await notifier.publishListing();
        }
        
        // Trigger celebration
        if (mounted) {
          setState(() {
            _showCelebration = true;
          });
        }

        // Delay before finishing
        Future.delayed(const Duration(seconds: 3), () {
          ref.read(hostModeProvider.notifier).state = true;
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to ${ref.read(hostOnboardingNotifierProvider).propertyId != null ? 'update' : 'publish'}: $e')),
          );
        }
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostOnboardingNotifierProvider);
    final isEditing = state.propertyId != null;

    return Stack(
      children: [
        Scaffold(
          // ... (appBar remains same) ...
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: _previousPage,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Save and exit
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Save & Exit',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              // ... (progress bar remains same) ...
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: List.generate(_steps.length, (index) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? Colors.black87
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: _steps,
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _previousPage,
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black87,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: state.isPublishing ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE31C5F), // Airbnb-ish Red/Pink
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isPublishing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentPage == _steps.length - 1 
                                  ? (isEditing ? 'Update' : 'Publish') 
                                  : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showCelebration) _buildCelebrationOverlay(isEditing),
      ],
    );
  }

  Widget _buildCelebrationOverlay(bool isEditing) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withOpacity(0.8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 80)
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.elasticOut)
                    .then()
                    .shake(),
                const SizedBox(height: 24),
                Text(
                  isEditing ? 'Updated!' : 'Published!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Your listing has been updated.' : 'Your listing is now live.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
          // Confetti particles (simulated with random icons)
          ...List.generate(20, (index) {
            final random = Random(index);
            final dx = (random.nextDouble() - 0.5) * 300;
            final dy = (random.nextDouble() - 0.5) * 300;
            return Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.star,
                color: Colors.primaries[index % Colors.primaries.length],
                size: 10 + random.nextDouble() * 20,
              )
                  .animate()
                  .move(
                      begin: const Offset(0, 0),
                      end: Offset(dx, dy),
                      duration: 1.seconds,
                      curve: Curves.easeOut)
                  .fadeOut(delay: 500.ms),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms),
    );
  }
}
