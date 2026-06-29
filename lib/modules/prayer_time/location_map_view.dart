import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import 'prayer_time_controller.dart';
import '../settings/settings_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _MapTheme {
  _MapTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color goldSoft     = Color(0xFFFFF8E7);
  static const Color darkSurface  = Color(0xFF141420);
  static const Color darkCard     = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard    = Color(0xFFFFFFFF);
}

class LocationMapView extends StatefulWidget {
  const LocationMapView({super.key});

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {
  final PrayerTimeController _controller = Get.find<PrayerTimeController>();
  final SettingsController _settings = Get.find<SettingsController>();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late final Rx<LatLng> selectedPoint;
  late final RxString geocodedAddress;
  final RxBool isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    selectedPoint = LatLng(_controller.latitude, _controller.longitude).obs;
    geocodedAddress = _controller.locationName.value.obs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    isSearching.value = true;
    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        selectedPoint.value = latLng;
        _mapController.move(latLng, 14.0);

        // Reverse geocode to get city name
        try {
          List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            final city = pm.locality ?? pm.subAdministrativeArea ?? pm.administrativeArea ?? '';
            final country = pm.country ?? '';
            if (city.isNotEmpty) {
              geocodedAddress.value = '$city, $country';
            } else {
              geocodedAddress.value = query;
            }
          }
        } catch (_) {
          geocodedAddress.value = query;
        }
      }
    } catch (e) {
      Get.snackbar(
        _settings.isBangla ? 'অনুসন্ধান ব্যর্থ' : 'Search Failed',
        _settings.isBangla
            ? 'স্থানটি খুঁজে পাওয়া যায়নি। অনুগ্রহ করে অন্য নাম চেষ্টা করুন।'
            : 'Could not find the location. Please try a different query.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    selectedPoint.value = point;
    geocodedAddress.value = _settings.isBangla ? 'ঠিকানা লোড হচ্ছে...' : 'Loading address...';

    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final city = pm.locality ?? pm.subAdministrativeArea ?? pm.administrativeArea ?? '';
        final country = pm.country ?? '';
        if (city.isNotEmpty) {
          geocodedAddress.value = '$city, $country';
        } else if (pm.name != null) {
          geocodedAddress.value = '${pm.name}, $country';
        } else {
          geocodedAddress.value = _settings.isBangla ? 'চিহ্নিত স্থান' : 'Custom Location';
        }
      }
    } catch (_) {
      geocodedAddress.value = 'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bn = _settings.isBangla;
    final isDark = _settings.isDark;

    return Scaffold(
      backgroundColor: isDark ? _MapTheme.darkSurface : _MapTheme.lightSurface,
      appBar: AppBar(
        leading: const AppBackButton(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_MapTheme.emeraldDark, _MapTheme.emerald, _MapTheme.emeraldLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: _MapTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(opacity: 0.05, child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          bn ? 'ম্যাপে অবস্থান নির্বাচন' : 'Select Location on Map',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── FlutterMap ─────────────────────────────────────────────────────
          Obx(() => FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selectedPoint.value,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) => _onMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.quranapp.quran_app',
                    tileBuilder: isDark
                        ? (context, tileWidget, tile) {
                            return ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1.0, 0.0, 0.0, 0.0, 255.0, // R
                                0.0, -1.0, 0.0, 0.0, 255.0, // G
                                0.0, 0.0, -1.0, 0.0, 255.0, // B
                                0.0, 0.0, 0.0, 1.0, 0.0,   // A
                                                      ]),
                              child: tileWidget,
                            );
                          }
                        : null,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedPoint.value,
                        width: 50,
                        height: 50,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: _MapTheme.gold,
                          size: 45,
                        ),
                      ),
                    ],
                  ),
                ],
              )),

          // ── Search Bar ─────────────────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: isDark ? _MapTheme.darkCard : _MapTheme.lightCard,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? _MapTheme.emerald.withOpacity(0.15) : _MapTheme.emerald.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textDark,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: bn
                              ? 'শহর বা জায়গার নাম খুঁজুন...'
                              : 'Search city or place name...',
                          hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                        ),
                        onSubmitted: _performSearch,
                      ),
                    ),
                    Obx(() => isSearching.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: 24,
                              height: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(2)),
                                child: LinearProgressIndicator(
                                  color: _MapTheme.emerald,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search_rounded, color: _MapTheme.emerald),
                            onPressed: () => _performSearch(_searchController.text),
                          )),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Location Confirmation Card ──────────────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              color: isDark ? _MapTheme.darkCard : _MapTheme.lightCard,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark ? _MapTheme.emerald.withOpacity(0.15) : _MapTheme.emerald.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _MapTheme.emerald.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: _MapTheme.gold.withOpacity(0.5), width: 1),
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: _MapTheme.emerald,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bn ? 'নির্বাচিত অবস্থান' : 'Selected Location',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    geocodedAddress.value,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : AppColors.textDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _MapTheme.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: _MapTheme.gold, width: 1),
                        ),
                      ),
                      onPressed: () {
                        _controller.updateLocation(
                          selectedPoint.value.latitude,
                          selectedPoint.value.longitude,
                          geocodedAddress.value,
                        );
                        Get.back();
                        Get.snackbar(
                          bn ? 'অবস্থান আপডেট করা হয়েছে' : 'Location Updated',
                          bn
                              ? 'আপনার নতুন অবস্থানটি সফলভাবে সেট করা হয়েছে।'
                              : 'Your new location has been set successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: _MapTheme.emerald.withOpacity(0.9),
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        bn ? 'অবস্থান নিশ্চিত করুন' : 'Confirm Location',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Islamic Star / Geometric Pattern Painter ──────────────────────────────────
class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const step = 32.0;

    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        _drawStar6(canvas, paint, Offset(x, y), 9);
      }
    }
  }

  void _drawStar6(Canvas canvas, Paint paint, Offset center, double r) {
    final path = ui.Path();
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (3.14159 / 180);
      final radius = i.isEven ? r : r * 0.45;
      final point = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );
      i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double rad) => rad == 0
      ? 1
      : (rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120);
  double _sin(double rad) =>
      rad - (rad * rad * rad) / 6 + (rad * rad * rad * rad * rad) / 120;

  @override
  bool shouldRepaint(_StarPatternPainter old) => false;
}
