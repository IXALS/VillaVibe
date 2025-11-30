import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/host/presentation/widgets/host_listing_card.dart';

class HostListingsTab extends ConsumerStatefulWidget {
  const HostListingsTab({super.key});

  @override
  ConsumerState<HostListingsTab> createState() => _HostListingsTabState();
}

class _HostListingsTabState extends ConsumerState<HostListingsTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view your listings'));
    }

    final propertiesAsync = ref.watch(hostPropertiesProvider(user.uid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: Text(
          'Your Listings',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/host/onboarding'),
          ),
        ],
      ),
      body: propertiesAsync.when(
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.home, size: 48, color: Colors.grey)
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                              duration: 2000.ms,
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              curve: Curves.easeInOut)
                          .then()
                          .scale(
                              duration: 2000.ms,
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1, 1),
                              curve: Curves.easeInOut),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No listings yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start earning by listing your property on VillaVibe.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/host/onboarding'),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Create Your First Listing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Grid View for Tablet/Desktop
                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.85, // Adjust based on card content
                  ),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return HostListingCard(property: property)
                        .animate()
                        .fadeIn(delay: (100 * index).ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                );
              } else {
                // List View for Mobile
                // Filter Logic
                final filteredProperties = properties.where((p) {
                  final matchesSearch = p.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ||
                      p.city
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                  final matchesFilter = _filterStatus == 'All' ||
                      (_filterStatus == 'Live' && p.isListed) ||
                      (_filterStatus == 'Unlisted' && !p.isListed);
                  return matchesSearch && matchesFilter;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        textAlignVertical: TextAlignVertical.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search listings...',
                          hintStyle: GoogleFonts.outfit(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          icon: Icon(LucideIcons.search,
                              color: Colors.black87, size: 20),
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 16),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Live'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Unlisted'),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'YOUR PROPERTIES (${filteredProperties.length})',
                        style: GoogleFonts.outfit(
                          color: Colors.grey[500],
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideX(begin: -0.1, end: 0),
                    if (filteredProperties.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No listings found matching your search.',
                            style: GoogleFonts.outfit(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...filteredProperties.asMap().entries.map((entry) {
                        final index = entry.key;
                        final property = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: HostListingCard(property: property)
                              .animate()
                              .fadeIn(
                                  delay: (300 + (100 * index)).ms,
                                  duration: 500.ms)
                              .slideY(
                                  begin: 0.1, end: 0, curve: Curves.easeOutBack),
                        );
                      }),
                  ],
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
  Widget _buildFilterChip(String label) {
    final isSelected = _filterStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
