import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../logging/app_logger.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      return position;
    } catch (e, stack) {
      appLogger.handle(e, stack, 'Error getting location');
      return null;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
