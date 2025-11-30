import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:villavibe/features/host/presentation/providers/host_onboarding_provider.dart';
import 'package:villavibe/features/host/presentation/widgets/price_histogram.dart';

class StepFinish extends ConsumerStatefulWidget {
  const StepFinish({super.key});

  @override
  ConsumerState<StepFinish> createState() => _StepFinishState();
}

class _StepFinishState extends ConsumerState<StepFinish> {
  late TextEditingController _priceController;
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final price = ref.read(hostOnboardingNotifierProvider).price;
    _priceController = TextEditingController(
      text: _currencyFormat.format(price).replaceAll('Rp ', ''),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged(String value) {
    // Remove non-digits
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanValue.isEmpty) return;

    final double newPrice = double.tryParse(cleanValue) ?? 0;
    
    // Update provider
    ref.read(hostOnboardingNotifierProvider.notifier).setPrice(newPrice);

    // Format and update text field cursor position
    final formatted = _currencyFormat.format(newPrice).replaceAll('Rp ', '');
    _priceController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hostOnboardingNotifierProvider);
    final notifier = ref.read(hostOnboardingNotifierProvider.notifier);

    // Sync controller if state changes externally (e.g. slider)
    // We check if the values match to avoid cursor jumping loops
    final currentTextValue = _priceController.text.replaceAll(RegExp(r'[^\d]'), '');
    final stateValue = state.price.round().toString();
    if (currentTextValue != stateValue && !_priceController.selection.isValid) {
       _priceController.text = _currencyFormat.format(state.price).replaceAll('Rp ', '');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Now, set your price')
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          const Text(
            'You can change it anytime.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'Rp ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        onChanged: _onPriceChanged,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms).scale(),
                const Text(
                  'per night',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Histogram
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: PriceHistogram(
              currentPrice: state.price,
              minPrice: 250000,
              maxPrice: 25000000,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.black87,
              inactiveTrackColor: Colors.grey[200],
              thumbColor: Colors.white,
              overlayColor: Colors.black.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 16,
                elevation: 4,
              ),
              trackHeight: 6,
            ),
            child: Slider(
              value: (log(state.price.clamp(250000, 25000000) / 250000) / log(25000000 / 250000)).clamp(0.0, 1.0),
              onChanged: (value) {
                // Logarithmic mapping: price = min * (max/min)^value
                final newPrice = 250000 * pow(25000000 / 250000, value);
                
                // Round to nearest 50k for cleaner numbers
                final roundedPrice = (newPrice / 50000).round() * 50000.0;
                
                if ((roundedPrice - state.price).abs() > 50000) {
                   HapticFeedback.selectionClick();
                }
                notifier.setPrice(roundedPrice);
                
                // Update controller text
                final formatted = _currencyFormat.format(roundedPrice).replaceAll('Rp ', '');
                _priceController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              },
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 48),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
