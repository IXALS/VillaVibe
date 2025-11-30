import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/bookings/domain/models/booking.dart';
import 'package:villavibe/features/host/presentation/providers/host_dashboard_provider.dart';
import 'package:villavibe/features/host/presentation/screens/dashboard/host_scanner_screen.dart';
import 'package:villavibe/features/bookings/data/repositories/booking_repository.dart';

class HostTodayTab extends ConsumerWidget {
  const HostTodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final dashboardAsync = ref.watch(hostDashboardProvider(user.uid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(hostDashboardProvider(user.uid).future);
          },
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dashboardAsync.when(
                  data: (data) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(user.displayName ?? 'Host', data.updatesCount),
                      const SizedBox(height: 32),

                      // Earnings Card
                        _buildEarningsCard(context, data),
                      const SizedBox(height: 32),

                      // Up Next Card
                      if (data.nextBooking != null) ...[
                        Text(
                          'UP NEXT',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUpNextCard(context, ref, data),
                        const SizedBox(height: 32),
                      ],

                      // Activity Section
                      if (data.checkIns.isNotEmpty)
                        _buildActivitySection(context, ref, 'Checking In Today', data.checkIns,
                            LucideIcons.logIn, Colors.green, data.propertyMap),
                      if (data.checkOuts.isNotEmpty)
                        _buildActivitySection(context, ref, 'Checking Out Today',
                            data.checkOuts, LucideIcons.logOut, Colors.orange, data.propertyMap),
                      if (data.currentlyHosting.isNotEmpty)
                        _buildActivitySection(context, ref, 'Currently Hosting',
                            data.currentlyHosting, LucideIcons.home, Colors.blue, data.propertyMap),

                      if (data.checkIns.isEmpty &&
                          data.checkOuts.isEmpty &&
                          data.currentlyHosting.isEmpty &&
                          data.nextBooking == null)
                        _buildEmptyState(),
                    ],
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                  loading: () => _buildLoadingState(),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HostScannerScreen()),
          );
        },
        backgroundColor: Colors.black,
        icon: const Icon(LucideIcons.scanLine, color: Colors.white),
        label: const Text('Scan', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(String name, int updatesCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            children: [
              const TextSpan(text: 'You have '),
              TextSpan(
                text: '$updatesCount updates',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const TextSpan(text: ' today.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpNextCard(BuildContext context, WidgetRef ref, HostDashboardData data) {
    final booking = data.nextBooking!;
    final guest = data.nextGuest;
    final property = data.nextProperty;
    final isToday = booking.startDate.day == DateTime.now().day;

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Options 🛠️',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(LucideIcons.xCircle, color: Colors.red),
                  title: const Text('Cancel Booking'),
                  subtitle: const Text('Free up dates immediately'),
                  onTap: () {
                    ref.read(bookingRepositoryProvider).cancelBooking(booking.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.checkCircle, color: Colors.green),
                  title: const Text('Complete Booking'),
                  subtitle: const Text('Mark as completed'),
                  onTap: () {
                    ref.read(bookingRepositoryProvider).completeBooking(booking.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image (Property)
              if (property != null && property.images.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: property.images.first,
                    fit: BoxFit.cover,
                  ),
                ),
              
              // Blur Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            isToday ? 'CHECKING IN TODAY' : 'UPCOMING',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        if (property != null)
                          Text(
                            property.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: guest?.photoUrl != null &&
                                  guest!.photoUrl.isNotEmpty
                              ? NetworkImage(guest.photoUrl)
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: guest?.photoUrl == null ||
                                  guest!.photoUrl.isEmpty
                              ? Text(
                                  guest?.displayName[0].toUpperCase() ?? 'G',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guest?.displayName ?? 'Guest',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${booking.guestCount} guests • ${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d').format(booking.endDate)}',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(LucideIcons.messageSquare, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection(
      BuildContext context, WidgetRef ref, String title, List<Booking> bookings, IconData icon, Color color, Map<String, dynamic> propertyMap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...bookings.map((booking) => _buildActivityItem(context, ref, booking, propertyMap)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, WidgetRef ref, Booking booking, Map<String, dynamic> propertyMap) {
    final property = propertyMap[booking.propertyId];
    final propertyName = property?.name ?? 'Booking #${booking.id.substring(0, 5)}';

    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Options 🛠️',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(LucideIcons.checkCircle, color: Colors.green),
                  title: const Text('Complete Booking'),
                  subtitle: const Text('Mark as completed (Ends stay)'),
                  onTap: () {
                    ref.read(bookingRepositoryProvider).completeBooking(booking.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.xCircle, color: Colors.red),
                  title: const Text('Cancel Booking'),
                  subtitle: const Text('Free up dates immediately'),
                  onTap: () {
                    ref.read(bookingRepositoryProvider).cancelBooking(booking.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.rotateCcw, color: Colors.orange),
                  title: const Text('Reset Check-in'),
                  subtitle: const Text('Set isCheckedIn = false'),
                  onTap: () {
                    ref.read(bookingRepositoryProvider).updateCheckInStatus(booking.id, false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.user, size: 20, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${DateFormat('MMM d').format(booking.startDate)} - ${DateFormat('MMM d').format(booking.endDate)}',
                    style: GoogleFonts.outfit(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(LucideIcons.calendarCheck, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            Text(
              'No updates for today.',
              style: GoogleFonts.outfit(
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(24),
          ),
        ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 1200.ms, color: Colors.white),
        const SizedBox(height: 32),
        ...List.generate(
          3,
          (index) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 1200.ms, color: Colors.white),
        ),
      ],
    );
  }
  Widget _buildEarningsCard(BuildContext context, HostDashboardData data) {
    final percentage = data.earningsChangePercentage ?? 0.0;
    final isPositive = percentage >= 0;
    final percentageString = '${isPositive ? '+' : ''}${percentage.toStringAsFixed(1)}%';
    final trendColor = isPositive ? Colors.greenAccent : Colors.redAccent;
    final trendIcon = isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown;

    return GestureDetector(
      onTap: () => _showEarningsBreakdown(context, data),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF000000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("MMMM 'Earnings'").format(DateTime.now()),
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(trendIcon, color: trendColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        percentageString,
                        style: GoogleFonts.outfit(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(data.monthlyEarnings),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .tint(color: const Color(0xFFE31C5F), duration: 300.ms),
            const SizedBox(height: 24),
            // Simple visual representation of a chart
            SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final height = [20.0, 35.0, 25.0, 40.0, 30.0, 45.0, 38.0][index];
                  return Container(
                    width: 8,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().scaleY(
                      begin: 0,
                      end: 1,
                      delay: (100 * index).ms,
                      duration: 500.ms,
                      curve: Curves.easeOut);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEarningsBreakdown(BuildContext context, HostDashboardData data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Earnings Breakdown 💰',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Income by property for ${DateFormat('MMMM').format(DateTime.now())}',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              if (data.earningsByProperty == null || data.earningsByProperty!.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No earnings details available.'),
                  ),
                )
              else
                ListView.separated(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: data.earningsByProperty!.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final propertyId = data.earningsByProperty!.keys.elementAt(index);
                    final amount = data.earningsByProperty![propertyId]!;
                    final property = data.propertyMap[propertyId];
                    final propertyName = property?.name ?? 'Unknown Property';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: property?.images.isNotEmpty == true
                              ? DecorationImage(
                                  image: NetworkImage(property!.images.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[200],
                        ),
                        child: property?.images.isEmpty == true
                            ? const Icon(LucideIcons.home, color: Colors.grey)
                            : null,
                      ),
                      title: Text(
                        propertyName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                            .format(amount),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
