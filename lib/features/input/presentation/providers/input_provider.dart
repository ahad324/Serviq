import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviq/features/input/data/repositories/service_repository.dart';
import 'package:serviq/features/common/domain/models/booking_model.dart' as models;

final serviceBookingProvider = AsyncNotifierProvider<ServiceBookingNotifier, models.Booking?>(() {
  return ServiceBookingNotifier();
});

class ServiceBookingNotifier extends AsyncNotifier<models.Booking?> {
  @override
  Future<models.Booking?> build() async {
    return null;
  }

  Future<void> submitQuery(String query) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(serviceRepositoryProvider);
      final result = await repository.requestService(query);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
