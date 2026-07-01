import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import 'prayer_time_controller.dart';
import '../settings/settings_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _MapTheme {
  _MapTheme._();
  static const Color emerald = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark = Color(0xFF0D3B1E);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C97A);
  static const Color goldSoft = Color(0xFFFFF8E7);
  static const Color darkSurface = Color(0xFF141420);
  static const Color darkCard = Color(0xFF1E1E2E);
  static const Color lightSurface = Color(0xFFFAF8F5);
  static const Color lightCard = Color(0xFFFFFFFF);
}

class LocationMapView extends StatefulWidget {
  const LocationMapView({super.key});

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> with TickerProviderStateMixin {
  final PrayerTimeController _controller = Get.find<PrayerTimeController>();
  final SettingsController _settings = Get.find<SettingsController>();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late final Rx<LatLng> selectedPoint;
  late final RxString geocodedAddress;
  final RxBool isSearching = false.obs;
  final RxBool isLocating = false.obs;

  @override
  void initState() {
    super.initState();
    selectedPoint = LatLng(_controller.latitude, _controller.longitude).obs;
    geocodedAddress = _controller.locationName.value.obs;
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(
        parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
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
        _animatedMapMove(latLng, 14.0);

        // Reverse geocode to get city name
        try {
          List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            final city = pm.locality ??
                pm.subAdministrativeArea ??
                pm.administrativeArea ??
                '';
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
            ? 'স্থানটি খুঁজে পাওয়া যায়নি। অনুগ্রহ করে অন্য নাম চেষ্টা করুন।'
            : 'Could not find the location. Please try a different query.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> _locateCurrentPosition() async {
    if (isLocating.value) return;
    isLocating.value = true;
    try {
      // 1) Is device GPS/location service even on?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          _settings.isBangla ? 'জিপিএস বন্ধ' : 'GPS Disabled',
          _settings.isBangla
              ? 'অনুগ্রহ করে আপনার ফোনের জিপিএস চালু করুন।'
              : 'Please enable GPS location service.',
          backgroundColor: Colors.amber.shade900,
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: Text(
              _settings.isBangla ? 'সেটিংস' : 'Settings',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }

      // 2) Check + request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          _settings.isBangla ? 'অনুমতি স্থায়ীভাবে বন্ধ' : 'Permission Permanently Denied',
          _settings.isBangla
              ? 'অ্যাপ সেটিংস থেকে লোকেশন পারমিশন চালু করুন।'
              : 'Location permission is permanently denied. Please enable it from app settings.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: Text(
              _settings.isBangla ? 'সেটিংস' : 'Settings',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        Get.snackbar(
          _settings.isBangla ? 'অনুমতি নেই' : 'Permission Denied',
          _settings.isBangla
              ? 'অবস্থান নির্ধারণের অনুমতি পাওয়া যায়নি।'
              : 'Location permission was denied.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      // 3) Permission granted (always / whileInUse) → fetch position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);
      selectedPoint.value = latLng;

      // Make sure the map has finished laying out before moving it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _animatedMapMove(latLng, 15.0);
        } catch (_) {
          // Map not attached yet — safe to ignore, marker position is already updated
        }
      });

      geocodedAddress.value =
      _settings.isBangla ? 'ঠিকানা লোড হচ্ছে...' : 'Loading address...';
      try {
        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final pm = placemarks.first;
          final city = pm.locality ??
              pm.subAdministrativeArea ??
              pm.administrativeArea ??
              '';
          final country = pm.country ?? '';
          if (city.isNotEmpty) {
            geocodedAddress.value = '$city, $country';
          } else {
            geocodedAddress.value =
            _settings.isBangla ? 'চিহ্নিত স্থান' : 'Current Location';
          }
        }
      } catch (_) {
        geocodedAddress.value =
        'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      }
    } on LocationServiceDisabledException {
      Get.snackbar(
        _settings.isBangla ? 'জিপিএস বন্ধ' : 'GPS Disabled',
        _settings.isBangla
            ? 'অনুগ্রহ করে আপনার ফোনের জিপিএস চালু করুন।'
            : 'Please enable GPS location service.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
    } on TimeoutException {
      Get.snackbar(
        _settings.isBangla ? 'সময় শেষ' : 'Timed Out',
        _settings.isBangla
            ? 'লোকেশন খুঁজে পেতে বেশি সময় লাগছে। আবার চেষ্টা করুন।'
            : 'Fetching location took too long. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.log('Locating user failed: $e');
      Get.snackbar(
        _settings.isBangla ? 'সমস্যা হয়েছে' : 'Something Went Wrong',
        _settings.isBangla
            ? 'আপনার অবস্থান নির্ধারণ করা যায়নি। আবার চেষ্টা করুন।'
            : 'Could not determine your location. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLocating.value = false;
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    selectedPoint.value = point;
    geocodedAddress.value =
    _settings.isBangla ? 'ঠিকানা লোড হচ্ছে...' : 'Loading address...';

    try {
      List<geo.Placemark> placemarks =
      await geo.placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final city = pm.locality ??
            pm.subAdministrativeArea ??
            pm.administrativeArea ??
            '';
        final country = pm.country ?? '';
        if (city.isNotEmpty) {
          geocodedAddress.value = '$city, $country';
        } else if (pm.name != null) {
          geocodedAddress.value = '${pm.name}, $country';
        } else {
          geocodedAddress.value =
          _settings.isBangla ? 'চিহ্নিত স্থান' : 'Custom Location';
        }
      }
    } catch (_) {
      geocodedAddress.value =
      'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
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
              colors: [
                _MapTheme.emeraldDark,
                _MapTheme.emerald,
                _MapTheme.emeraldLight
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border:
            Border(bottom: BorderSide(color: _MapTheme.gold, width: 1.5)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                  opacity: 0.05,
                  child: CustomPaint(painter: _StarPatternPainter())),
            ],
          ),
        ),
        title: Text(
          bn ? 'ম্যাপে অবস্থান নির্বাচন' : 'Select Location on Map',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── FlutterMap ─────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedPoint.value,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.quranapp.quran_app',
                tileBuilder: isDark
                    ? (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1.0, 0.0, 0.0, 0.0, 255.0, // R
                      0.0, -1.0, 0.0, 0.0, 255.0, // G
                      0.0, 0.0, -1.0, 0.0, 255.0, // B
                      0.0, 0.0, 0.0, 1.0, 0.0, // A
                    ]),
                    child: tileWidget,
                  );
                }
                    : null,
              ),
              Obx(() => MarkerLayer(
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
              )),
            ],
          ),

          // ── Search Bar ─────────────────────────────────────────────────────
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark ? _MapTheme.darkCard : _MapTheme.lightCard)
                        .withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? _MapTheme.emerald.withOpacity(0.15)
                          : _MapTheme.emerald.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
                                ? 'শহর বা জায়গার নাম খুঁজুন...'
                                : 'Search city or place name...',
                            hintStyle: const TextStyle(
                                color: AppColors.textGrey, fontSize: 13),
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
                            borderRadius:
                            BorderRadius.all(Radius.circular(2)),
                            child: LinearProgressIndicator(
                              color: _MapTheme.emerald,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                      )
                          : IconButton(
                        icon: const Icon(Icons.search_rounded,
                            color: _MapTheme.emerald),
                        onPressed: () =>
                            _performSearch(_searchController.text),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── GPS Floating Button ────────────────────────────────────────────
          Positioned(
            bottom: 232, // Positioned right above the confirmation panel
            right: 16,
            child: Obx(() => FloatingActionButton(
              heroTag: 'gps_fab',
              mini: true,
              backgroundColor:
              isDark ? _MapTheme.darkCard : _MapTheme.lightCard,
              foregroundColor: _MapTheme.emerald,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark
                      ? _MapTheme.emerald.withOpacity(0.15)
                      : _MapTheme.emerald.withOpacity(0.06),
                  width: 1,
                ),
              ),
              onPressed: isLocating.value ? null : _locateCurrentPosition,
              child: isLocating.value
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _MapTheme.emerald,
                ),
              )
                  : const Icon(Icons.gps_fixed_rounded, size: 20),
            )),
          ),

          // ── Bottom Location Confirmation Card ──────────────────────────────
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: (isDark ? _MapTheme.darkCard : _MapTheme.lightCard)
                        .withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? _MapTheme.emerald.withOpacity(0.2)
                          : _MapTheme.emerald.withOpacity(0.08),
                      width: 1.2,
                    ),
                  ),
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
                              border: Border.all(
                                  color: _MapTheme.gold.withOpacity(0.5),
                                  width: 1),
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
                                  bn
                                      ? 'নির্বাচিত অবস্থান'
                                      : 'Selected Location',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColors.textGrey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                  geocodedAddress.value,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textDark,
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
                          elevation: 2,
                          shadowColor: _MapTheme.emerald.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(
                                color: _MapTheme.gold, width: 1),
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
                            bn ? 'অবস্থান আপডেট করা হয়েছে' : 'Location Updated',
                            bn
                                ? 'আপনার নতুন অবস্থানটি সফলভাবে সেট করা হয়েছে।'
                                : 'Your new location has been set successfully.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: _MapTheme.emerald.withOpacity(0.9),
                            colorText: Colors.white,
                          );
                        },
                        child: Text(
                          bn ? 'অবস্থান নিশ্চিত করুন' : 'Confirm Location',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
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
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
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