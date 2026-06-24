import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../core/theme/app_colors.dart';
import 'prayer_time_controller.dart';
import '../settings/settings_controller.dart';

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
      appBar: AppBar(
        title: Text(bn ? 'ম্যাপে অবস্থান নির্বাচন' : 'Select Location on Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
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
                          color: AppColors.primary,
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
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
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
                          color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                                  color: AppColors.primary,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
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
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.primary,
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    geocodedAddress.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? AppColors.textWhite : AppColors.textDark,
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                          backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                          colorText: isDark ? Colors.black : Colors.white,
                        );
                      },
                      child: Text(
                        bn ? 'অবস্থান নিশ্চিত করুন' : 'Confirm Location',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
