import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';

class MiniBoardingPass extends StatelessWidget {
  final Booking booking;
  final Property property;
  final VoidCallback onTap;

  const MiniBoardingPass({
    super.key,
    required this.booking,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'boarding_pass_${booking.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left: Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: property.images.first,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(LucideIcons.image, color: Colors.grey),
                    ),
                  ),
                ),
            
            // Right: Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d').format(booking.endDate)}',
                          style: GoogleFonts.outfit(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: _getStatusColor(booking.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(LucideIcons.chevronRight, color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Booking.statusPaid:
      case Booking.statusCompleted:
        return Colors.green;
      case Booking.statusPending:
        return Colors.orange;
      case Booking.statusCancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
