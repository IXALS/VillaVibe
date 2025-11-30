import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class LocationPickerModal extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerModal({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  late LatLng _currentPosition;
  bool _isLoading = true;
  MapType _currentMapType = MapType.normal;

  // Default to Bali coordinates if no location provided
  static const LatLng _defaultLocation = LatLng(-8.409518, 115.188919);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentPosition = LatLng(widget.initialLat!, widget.initialLng!);
      setState(() => _isLoading = false);
    } else {
      _currentPosition = _defaultLocation;
      setState(() => _isLoading = false);
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    final latLng = LatLng(position.latitude, position.longitude);

    _animateToLocation(latLng);
  }

  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) return;
    
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _animateToLocation(LatLng(loc.latitude, loc.longitude));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find location: $query')),
        );
      }
    }
  }

  Future<void> _animateToLocation(LatLng latLng) async {
    setState(() {
      _currentPosition = latLng;
    });
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  Widget _buildMapTypeButton(MapType type, IconData icon) {
    final isSelected = _currentMapType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _currentMapType = type);
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLocation() async {
    setState(() => _isLoading = true);
    try {
      HapticFeedback.mediumImpact();
      
      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      String address = '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Construct a readable address
        // e.g. "Jalan Raya, Ubud, Indonesia"
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.country
        ].where((e) => e != null && e.isNotEmpty).toSet().toList(); // toSet to remove duplicates
        
        address = parts.join(', ');
      }

      if (mounted) {
        Navigator.pop(context, {
          'latLng': _currentPosition,
          'address': address,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get address: $e')),
        );
        // Fallback: return coordinates only if geocoding fails, or let user retry
        // For now, we'll just pop with coordinates and empty address or handle in parent
         Navigator.pop(context, {
          'latLng': _currentPosition,
          'address': '${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}',
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pinpoint Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search address or villa name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _searchAddress,
            ),
          ),

          const Divider(height: 1),
          // Map Area
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15,
                  ),
                  mapType: _currentMapType,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraMove: (position) {
                    _currentPosition = position.target;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
                
                // Map Type Toggle
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMapTypeButton(MapType.normal, Icons.map_outlined),
                        Container(height: 1, width: 30, color: Colors.grey[200]),
                        _buildMapTypeButton(MapType.hybrid, Icons.satellite_outlined),
                      ],
                    ),
                  ),
                ),

                // Center Pin
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 35), // Adjust for pin tip
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ),

                // Current Location Button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _getCurrentLocation();
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
                
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
