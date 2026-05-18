import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import '../../../../core/logging/app_logger.dart';
import 'package:serviq/features/matching/domain/models/service_response.dart';

abstract class ServiceRepository {
  Future<ServiceResponse> requestService(
    String query, {
    double? lat,
    double? lng,
  });
}

class ServiceApiException implements Exception {
  final Map<String, dynamic> data;

  ServiceApiException(this.data);

  String get message =>
      data['message']?.toString() ?? 'Something went wrong';

  String get hint =>
      data['hint']?.toString() ?? 'Please try again';

  String get error =>
      data['error']?.toString() ?? 'UNKNOWN_ERROR';

  @override
  String toString() => message;
}

class ServiceRepositoryImpl implements ServiceRepository {
  final Dio _dio;
  final bool _useMock;

  ServiceRepositoryImpl(
    this._dio, {
    bool useMock = false,
  }) : _useMock = useMock;

  @override
  Future<ServiceResponse> requestService(
    String query, {
    double? lat,
    double? lng,
  }) async {
    if (_useMock) {
      throw ServiceApiException({
        'message': 'Mock mode enabled',
        'hint': 'Disable mock mode',
      });
    }

    try {
      final response = await _dio.post(
        '/webhook/service-request',
        data: {
          'query': query,
          'test': false,
          'longitude': lng,
          'latitude': lat,
        },
      );

      appLogger.debug("STATUS: ${response.statusCode}");
      appLogger.debug("DATA: ${response.data}");

      final Map<String, dynamic> data =
          _extractData(response.data);

      // IMPORTANT FIX
      if (data['success'] == false) {
        throw ServiceApiException(data);
      }

      return ServiceResponse.fromJson(data);
    } on ServiceApiException {
      rethrow;
    } on DioException catch (e) {
      appLogger.handle(e, e.stackTrace, "DIO ERROR: ${e.response?.data}");

      final Map<String, dynamic> data =
          _extractData(e.response?.data);

      throw ServiceApiException(data);
    } catch (e, stack) {
      appLogger.handle(e, stack, "UNKNOWN ERROR: $e");

      throw ServiceApiException({
        'message': 'Something went wrong',
        'hint': 'Please try again',
      });
    }
  }

  Map<String, dynamic> _extractData(dynamic raw) {
    if (raw == null) return {};

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;

      if (first is Map<String, dynamic>) {
        return first;
      }
    }

    return {
      'message': raw.toString(),
      'hint': 'Please try again',
    };
  }
}

final dioProvider = Provider(
  (ref) => Dio(
    BaseOptions(
      baseUrl: 'https://n8n-production-b9127.up.railway.app',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      TalkerDioLogger(
        talker: appLogger,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    ),
);

final serviceRepositoryProvider =
    Provider<ServiceRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ServiceRepositoryImpl(
    dio,
    useMock: false,
  );
});
