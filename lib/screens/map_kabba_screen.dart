import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class MapKabbaScreen extends StatefulWidget {
  final double userLat;
  final double userLng;

  const MapKabbaScreen({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<MapKabbaScreen> createState() => _MapKabbaScreenState();
}

class _MapKabbaScreenState extends State<MapKabbaScreen> {
  GoogleMapController? _mapController;
  final LatLng _kaabaLocation = const LatLng(21.4225, 39.8262);
  
  late LatLng _currentUserLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _currentUserLocation = LatLng(widget.userLat, widget.userLng);
    _initMarkers();
    _initPolylines();
  }

  void _initMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('user'),
        position: _currentUserLocation,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _currentUserLocation = newPosition;
            _initMarkers();
            _initPolylines();
          });
        },
        infoWindow: const InfoWindow(
          title: 'Lokasi Anda (Geser untuk Koreksi)',
          snippet: 'Tahan dan geser titik biru ini',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('kaaba'),
        position: _kaabaLocation,
        infoWindow: const InfoWindow(title: 'Kaaba, Makkah'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    };
  }

  void _initPolylines() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('qiblaRoute'),
        points: [
          _currentUserLocation,
          _kaabaLocation,
        ],
        color: Colors.greenAccent,
        width: 4,
        geodesic: true,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black54 : Colors.white70,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'VISUAL QIBLA MAP',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentUserLocation,
              zoom: 15,
            ),
            mapType: MapType.satellite,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              if (mounted) {
                setState(() {
                  _mapController = controller;
                  _isMapReady = true;
                });
                Future.delayed(const Duration(milliseconds: 300), () {
                  _fitBounds();
                });
              }
            },
          ),
          if (!_isMapReady)
            Container(
              color: isDark ? Colors.black : Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.greenAccent),
                    const SizedBox(height: 24),
                    Text(
                      'MENYIAPKAN PETA...',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 2,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Instruction hint
          if (_isMapReady)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_rounded, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Geser titik BIRU jika posisi kurang pas untuk koreksi Kiblat',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.my_location,
                  label: 'LOKASI ANDA',
                  onTap: () => _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentUserLocation, 18),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.mosque_rounded,
                  label: 'KAABAH',
                  onTap: () => _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_kaabaLocation, 18),
                  ),
                ),
                _buildActionButton(
                  icon: Icons.unfold_more_rounded,
                  label: 'SEMUA',
                  onTap: _fitBounds,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.black87 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null) return;
    
    double minLat = math.min(_currentUserLocation.latitude, _kaabaLocation.latitude);
    double maxLat = math.max(_currentUserLocation.latitude, _kaabaLocation.latitude);
    double minLng = math.min(_currentUserLocation.longitude, _kaabaLocation.longitude);
    double maxLng = math.max(_currentUserLocation.longitude, _kaabaLocation.longitude);

    _mapController?.animateCamera(
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
