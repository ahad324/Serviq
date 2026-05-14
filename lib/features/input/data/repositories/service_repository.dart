import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviq/features/common/domain/models/booking_model.dart' as models;
import 'package:serviq/features/common/data/mock_data.dart';

abstract class ServiceRepository {
  Future<models.Booking> requestService(String query);
}

class ServiceRepositoryImpl implements ServiceRepository {
  final Dio _dio;
  final bool _useMock;

  ServiceRepositoryImpl(this._dio, {bool useMock = true}) : _useMock = useMock;

  @override
  Future<models.Booking> requestService(String query) async {
    if (_useMock) {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      return MockData.mockBooking;
    }

    try {
      final response = await _dio.post(
        '/service-request',
        data: {'query': query},
      );
      return models.Booking.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

final dioProvider = Provider((ref) => Dio(
      BaseOptions(
        baseUrl: 'https://n8n-production-b9127.up.railway.app/webhook',
        connectTimeout: const Duration(seconds: 10),
      ),
    ));

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  // Set useMock to false when ready to integrate real API
  return ServiceRepositoryImpl(dio, useMock: true);
});
