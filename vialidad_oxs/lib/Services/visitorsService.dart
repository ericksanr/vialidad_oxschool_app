import 'package:dio/dio.dart';
import 'package:vialidad_oxs/config/temp/temp_data.dart';
import '../Models/visitor_event.dart';
import 'api_service.dart';

/// Service class for handling visitor-related API operations
/// This service manages visitor registration, updates, and retrieval
class VisitorsService {
  static final VisitorsService _instance = VisitorsService._internal();
  factory VisitorsService() => _instance;
  VisitorsService._internal() {
    _apiService = ApiService();
    _apiService.initialize();
  }

  late final ApiService _apiService;

  /// Get the Dio instance from ApiService
  Dio get _dio => _apiService.dio;

  // VISITOR MANAGEMENT METHODS

  /// Register a new visitor
  /// POST /visitor/create/
  Future<VisitorEventResponse> registerVisitor(
    VisitorEvent visitorEvent,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.productionBaseUrl}/visitor/create/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': tempUser!.token,
          },
        ),
        data: visitorEvent.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al registrar visitante: ${response.statusCode}',
        );
      }
    } on DioException {
      // Let the error handler deal with DioExceptions
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al registrar visitante: $e');
    }
  }

  /// Get visitor by ID
  /// GET /visitor/{id}/
  Future<VisitorEventResponse> getVisitor(int visitorId) async {
    try {
      final response = await _dio.get('/visitor/$visitorId/');

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al obtener visitante: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al obtener visitante: $e');
    }
  }

  /// Update visitor information
  /// PUT /visitor/{id}/
  Future<VisitorEventResponse> updateVisitor(
    int visitorId,
    VisitorEvent visitorEvent,
  ) async {
    try {
      final response = await _dio.put(
        '/visitor/$visitorId/',
        data: visitorEvent.toJson(),
      );

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al actualizar visitante: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al actualizar visitante: $e');
    }
  }

  /// Get all visitors (with optional filtering)
  /// GET /visitor/
  Future<VisitorEventResponse> getAllVisitors({
    int? limit,
    int? offset,
    String? status,
    String? campus,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (limit != null) queryParameters['limit'] = limit;
      if (offset != null) queryParameters['offset'] = offset;
      if (status != null) queryParameters['status'] = status;
      if (campus != null) queryParameters['campus'] = campus;
      if (fromDate != null) {
        queryParameters['from_date'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParameters['to_date'] = toDate.toIso8601String();
      }

      final response = await _dio.get(
        '/visitor/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al obtener visitantes: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al obtener visitantes: $e');
    }
  }

  /// Register visitor departure/checkout
  /// PATCH /visitor/{id}/checkout/
  Future<VisitorEventResponse> checkoutVisitor(
    int visitorId, {
    String? observations,
  }) async {
    try {
      final data = <String, dynamic>{
        'leaveDate': DateTime.now().toIso8601String(),
        'status': 4, // Salida registrada
      };

      if (observations != null) {
        data['observations'] = observations;
      }

      final response = await _dio.patch(
        '/visitor/$visitorId/checkout/',
        data: data,
      );

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException('Error al registrar salida: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al registrar salida: $e');
    }
  }

  /// Search visitors by name or identification
  /// GET /visitor/search/
  Future<VisitorEventResponse> searchVisitors({
    String? name,
    String? identification,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (name != null) queryParameters['name'] = name;
      if (identification != null)
        queryParameters['identification'] = identification;
      if (limit != null) queryParameters['limit'] = limit;

      final response = await _dio.get(
        '/visitor/search/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al buscar visitantes: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al buscar visitantes: $e');
    }
  }

  /// Get today's visitors
  /// GET /visitor/today/
  Future<VisitorEventResponse> getTodayVisitors() async {
    try {
      final response = await _dio.get('/visitor/today/');

      if (response.statusCode == 200) {
        return VisitorEventResponse.fromJson(response.data);
      } else {
        throw ApiException(
          'Error al obtener visitantes del día: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al obtener visitantes del día: $e');
    }
  }

  /// Get visitor statistics
  /// GET /visitor/stats/
  Future<Map<String, dynamic>> getVisitorStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? campus,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (fromDate != null) {
        queryParameters['from_date'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParameters['to_date'] = toDate.toIso8601String();
      }
      if (campus != null) {
        queryParameters['campus'] = campus;
      }

      final response = await _dio.get(
        '/visitor/stats/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException(
          'Error al obtener estadísticas: ${response.statusCode}',
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al obtener estadísticas: $e');
    }
  }
}
