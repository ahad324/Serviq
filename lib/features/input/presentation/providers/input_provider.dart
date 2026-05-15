import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviq/features/input/data/repositories/service_repository.dart';
import 'package:serviq/features/common/domain/models/booking_model.dart' as models;
import 'package:serviq/features/matching/domain/models/service_response.dart';
import 'package:serviq/core/services/location_service.dart';

final serviceBookingProvider = AsyncNotifierProvider<ServiceBookingNotifier, ServiceResponse?>(() {
  return ServiceBookingNotifier();
});

class SelectedProviderNotifier extends Notifier<ServiceProvider?> {
  @override
  ServiceProvider? build() => null;
  
  void setProvider(ServiceProvider? provider) {
    state = provider;
  }
}

final selectedProviderProvider = NotifierProvider<SelectedProviderNotifier, ServiceProvider?>(() {
  return SelectedProviderNotifier();
});

class ServiceBookingNotifier extends AsyncNotifier<ServiceResponse?> {
  @override
  Future<ServiceResponse?> build() async {
    return null;
  }

  Future<void> submitQuery(String query) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(serviceRepositoryProvider);
      final locationService = ref.read(locationServiceProvider);
      
      // Mandatory live location for precise matching
      final position = await locationService.getCurrentLocation();
      
      if (position == null) {
        throw Exception('LOCATION_REQUIRED');
      }
      
      final result = await repository.requestService(
        query,
        lat: position.latitude,
        lng: position.longitude,
      );
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
