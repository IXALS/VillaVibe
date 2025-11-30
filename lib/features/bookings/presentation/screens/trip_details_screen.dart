import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/bookings/presentation/widgets/hero_boarding_pass.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class TripDetailsScreen extends ConsumerWidget {
  final Booking booking;
  final Property property;

  const TripDetailsScreen({
    super.key,
    required this.booking,
    required this.property,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Trip Details',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Hero(
          tag: 'boarding_pass_${booking.id}',
          flightShuttleBuilder: (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            final Hero toHero = toHeroContext.widget as Hero;
            return Material(
              type: MaterialType.transparency,
              child: toHero.child,
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: HeroBoardingPass(
              booking: booking,
              property: property,
              isExpandedDefault: true,
            ),
          ),
        ),
      ),
    );
  }
}
