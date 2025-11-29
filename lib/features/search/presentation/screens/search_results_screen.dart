import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/domain/models/property.dart';
import 'package:villavibe/features/properties/presentation/widgets/villa_compact_card.dart';
import 'package:villavibe/features/search/presentation/widgets/map_price_marker.dart';
import 'package:villavibe/features/search/presentation/providers/search_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String? _selectedPropertyId;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadMarkers(List properties) async {
    final Set<Marker> markers = {};

    for (var property in properties) {
      final isSelected = property.id == _selectedPropertyId;
      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      final icon = await MapMarkerHelper.createPriceMarker(
        currencyFormat.format(property.pricePerNight),
        isSelected,
      );

      markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(
            property.location.latitude,
            property.location.longitude,
          ),
          icon: icon,
          onTap: () {
            setState(() {
              _selectedPropertyId = property.id;
            });
            _loadMarkers(properties); // Reload to update colors
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
      
      // Update camera position to fit markers
      final searchState = ref.read(searchNotifierProvider);
      _updateCameraPosition(properties.cast<Property>(), searchState);
    }
  }

  void _updateCameraPosition(List<Property> properties, SearchState searchState) {
    if (_mapController == null) return;

    if (searchState.isSearchingNearby && searchState.userLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              searchState.userLocation!.latitude,
              searchState.userLocation!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    } else if (properties.isNotEmpty) {
      if (properties.length == 1) {
        // If only one result, zoom to it with a comfortable level
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                properties.first.location.latitude,
                properties.first.location.longitude,
              ),
              zoom: 15,
            ),
          ),
        );
      } else {
        double minLat = properties.first.location.latitude;
        double maxLat = properties.first.location.latitude;
        double minLng = properties.first.location.longitude;
        double maxLng = properties.first.location.longitude;

        for (var property in properties) {
          if (property.location.latitude < minLat) minLat = property.location.latitude;
          if (property.location.latitude > maxLat) maxLat = property.location.latitude;
          if (property.location.longitude < minLng) minLng = property.location.longitude;
          if (property.location.longitude > maxLng) maxLng = property.location.longitude;
        }

        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            100, // padding
          ),
        );
      }
    }
  }



  String _buildSearchLabel(SearchState state) {
    final List<String> parts = [];

    // Location
    if (state.location != null && state.location!.isNotEmpty) {
      parts.add(state.location!);
    } else {
      parts.add('Anywhere');
    }

    // Dates
    // Dates
    if (state.startDate != null) {
      final start = DateFormat('d MMM').format(state.startDate!);
      if (state.endDate != null) {
        final end = DateFormat('d MMM').format(state.endDate!);
        parts.add('$start - $end');
      } else {
        parts.add(start);
      }
    } else {
      parts.add('Any week');
    }

    // Guests
    if (state.totalGuests > 0) {
      parts.add('${state.totalGuests} guests');
    } else {
      parts.add('Add guests');
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allPropertiesProvider);
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          propertiesAsync.when(
            data: (properties) {
              // Filter properties based on search location
              final filteredProperties = properties.where((property) {
                if (searchState.isSearchingNearby && searchState.userLocation != null) {
                  final distance = Geolocator.distanceBetween(
                    searchState.userLocation!.latitude,
                    searchState.userLocation!.longitude,
                    property.location.latitude,
                    property.location.longitude,
                  );
                  return distance < 50000; // 50km radius
                }

                if (searchState.location == null || searchState.location!.isEmpty) {
                  return true;
                }
                final query = searchState.location!.toLowerCase();
                final matchesCity = property.city.toLowerCase().contains(query);
                final matchesAddress = property.address.toLowerCase().contains(query);
                final matchesName = property.name.toLowerCase().contains(query);
                
                return matchesCity || matchesAddress || matchesName;
              }).toList();

              // Check if markers need to be updated
              final newIds = filteredProperties.map((p) => p.id).toSet();
              final currentIds = _markers.map((m) => m.markerId.value).toSet();
              
              if (newIds.length != currentIds.length || !newIds.containsAll(currentIds)) {
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadMarkers(filteredProperties);
                 });
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-8.409518, 115.188919), // Bali
                  zoom: 11,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _updateCameraPosition(filteredProperties, searchState);
                },
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/search', extra: {'isEditing': true}),
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _buildSearchLabel(searchState),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(LucideIcons.slidersHorizontal, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Bottom List
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    propertiesAsync.when(
                      data: (properties) {
                        final filteredProperties = properties.where((property) {
                          if (searchState.location == null ||
                              searchState.location!.isEmpty) {
                            return true;
                          }
                          final query = searchState.location!.toLowerCase();
                          return property.city.toLowerCase().contains(query) ||
                              property.address.toLowerCase().contains(query) ||
                              property.name.toLowerCase().contains(query);
                        }).toList();

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${filteredProperties.length} ${filteredProperties.length == 1 ? 'home' : 'homes'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              }

                              final property = filteredProperties[index - 1];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                        horizontal: 24)
                                    .copyWith(bottom: 32),
                                child: VillaCompactCard(
                                  property: property,
                                  heroTagPrefix: 'search_result_',
                                  onTap: () {
                                    context.push(
                                      '/property/${property.id}',
                                      extra: {
                                        'property': property,
                                        'heroTagPrefix': 'search_result_',
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: filteredProperties.length + 1,
                          ),
                        );
                      },
                      loading: () => SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      error: (e, s) => SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text('Error: $e'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

