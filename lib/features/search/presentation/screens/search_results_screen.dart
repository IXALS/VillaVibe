import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:villavibe/features/properties/data/repositories/property_repository.dart';
import 'package:villavibe/features/properties/presentation/widgets/villa_compact_card.dart';
import 'package:villavibe/features/search/presentation/widgets/map_price_marker.dart';

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
      final icon = await MapMarkerHelper.createPriceMarker(
        '\$${property.pricePerNight}',
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
    }
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
                if (searchState.location == null || searchState.location!.isEmpty) {
                  return true;
                }
                final query = searchState.location!.toLowerCase();
                return property.city.toLowerCase().contains(query) ||
                    property.address.toLowerCase().contains(query) ||
                    property.name.toLowerCase().contains(query);
              }).toList();

              if (_markers.isEmpty && filteredProperties.isNotEmpty) {
                _loadMarkers(filteredProperties);
              } else if (filteredProperties.isEmpty && _markers.isNotEmpty) {
                 // Clear markers if no results
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _markers = {});
                 });
              }

              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-8.409518, 115.188919), // Bali
                  zoom: 11,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
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
                      child: const Text(
                        'Bali · Any week · Add guests',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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
                    const SizedBox(height: 12),
                    const Text(
                      'Over 1,000 homes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: propertiesAsync.when(
                        data: (properties) {
                          final filteredProperties = properties.where((property) {
                            if (searchState.location == null || searchState.location!.isEmpty) {
                              return true;
                            }
                            final query = searchState.location!.toLowerCase();
                            return property.city.toLowerCase().contains(query) ||
                                property.address.toLowerCase().contains(query) ||
                                property.name.toLowerCase().contains(query);
                          }).toList();

                          return ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: filteredProperties.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 32),
                            itemBuilder: (context, index) {
                              final property = filteredProperties[index];
                              return VillaCompactCard(
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
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, s) => const Center(child: Text('Error')),
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

