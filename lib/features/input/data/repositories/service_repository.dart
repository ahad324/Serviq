import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviq/features/common/domain/models/booking_model.dart' as models;
import 'package:serviq/features/matching/domain/models/service_response.dart';
import 'package:serviq/features/common/data/mock_data.dart';
import 'package:serviq/core/services/location_service.dart';

abstract class ServiceRepository {
  Future<ServiceResponse> requestService(String query, {double? lat, double? lng});
}

class ServiceRepositoryImpl implements ServiceRepository {
  final Dio _dio;
  final bool _useMock;

  ServiceRepositoryImpl(this._dio, {bool useMock = true}) : _useMock = useMock;

  @override
  Future<ServiceResponse> requestService(String query, {double? lat, double? lng}) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 2));
      // In a real app, you'd map mock data to ServiceResponse
      throw UnimplementedError('Mock for ServiceResponse not implemented');
    }

    try {
      print('--- API REQUEST ---');
      final payload = {
        'query': query,
        'test': true,
        'longitude': lng,
        'latitude': lat,
      };
      print('Payload: $payload');

      final response = await _dio.post(
        '/service-request',
        data: payload,
      );
      
      print('--- API RESPONSE ---');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      // n8n webhooks often return an array [ { ... } ]
      final dynamic rawData = response.data;
      if (rawData is List && rawData.isNotEmpty) {
        return ServiceResponse.fromJson(rawData.first as Map<String, dynamic>);
      } else if (rawData is Map<String, dynamic>) {
        return ServiceResponse.fromJson(rawData);
      } else {
        throw Exception('Unexpected response format: $rawData');
      }
    } catch (e) {
      print('--- API ERROR ---');
      print('Error: $e');
      rethrow;
    }
  }
}

final dioProvider = Provider((ref) => Dio(
      BaseOptions(
        baseUrl: 'https://n8n-production-b9127.up.railway.app/webhook',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ));

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  // Set useMock to false for real API integration
  return ServiceRepositoryImpl(dio, useMock: false);
});
