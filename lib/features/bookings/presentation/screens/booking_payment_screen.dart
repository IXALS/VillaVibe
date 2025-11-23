import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/presentation/controllers/booking_controller.dart';
import 'package:villavibe/features/bookings/presentation/states/booking_state.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class BookingPaymentScreen extends ConsumerWidget {
  final Property property;

  const BookingPaymentScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingControllerProvider(property));
    final controller = ref.read(bookingControllerProvider(property).notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () {
            controller.previousStep();
            context.pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a payment method',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPaymentOption(
                    context,
                    title: 'Credit or debit card',
                    icon: LucideIcons.creditCard,
                    value: PaymentMethod.creditCard,
                    groupValue: bookingState.selectedPaymentMethod,
                    onChanged: (value) => controller.setPaymentMethod(value!),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Simple visual representation of card logos
                        Container(
                          width: 24,
                          height: 16,
                          color: Colors.blue[900],
                          margin: const EdgeInsets.only(right: 4),
                        ),
                        Container(
                          width: 24,
                          height: 16,
                          color: Colors.red[900],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildPaymentOption(
                    context,
                    title: 'GoPay',
                    icon: LucideIcons.wallet,
                    value: PaymentMethod.qris,
                    groupValue: bookingState.selectedPaymentMethod,
                    onChanged: (value) => controller.setPaymentMethod(value!),
                    trailing: const Icon(LucideIcons.qrCode, size: 20),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required PaymentMethod value,
    required PaymentMethod groupValue,
    required ValueChanged<PaymentMethod?> onChanged,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: 4),
                    trailing,
                  ],
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              controller.nextStep();
              context.push('/booking/message', extra: controller.property);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
