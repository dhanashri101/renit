import 'package:dio/dio.dart';
import 'package:rentit24/core/network/api_endpoints.dart';
import 'package:rentit24/core/network/api_exception.dart';
import 'package:rentit24/core/network/api_response.dart';
import 'package:rentit24/core/storage/auth_storage.dart';
import 'package:rentit24/services/api_services.dart';

class AuthService {
  AuthService({
    ApiService? apiService,
    AuthStorage? authStorage,
  })  : _apiService = apiService ?? ApiService(),
        _authStorage = authStorage ?? AuthStorage();

  final ApiService _apiService;
  final AuthStorage _authStorage;

  /// Sends the exact backend fields documented for auth/getOTP.
  ///
  /// The caller must provide the already-prepared `req` and exact `reqType`.
  /// No encryption, phone formatting, or reqType value is guessed here.
  Future<ApiEnvelope> requestOtp({
    required String req,
    required Object reqType,
    CancelToken? cancelToken,
  }) async {
    return _postAuthRequest(
      endpoint: ApiEndpoints.requestOtp,
      req: req,
      reqType: reqType,
      cancelToken: cancelToken,
    );
  }

  /// Sends the exact backend fields documented for auth/login.
  /// Token extraction is deliberately not performed until the backend defines
  /// the response payload and Authorization header scheme.
  Future<ApiEnvelope> login({
    required String req,
    required Object reqType,
    CancelToken? cancelToken,
  }) async {
    return _postAuthRequest(
      endpoint: ApiEndpoints.login,
      req: req,
      reqType: reqType,
      cancelToken: cancelToken,
    );
  }

  Future<void> logoutLocal() => _authStorage.clear();

  Future<ApiEnvelope> _postAuthRequest({
    required String endpoint,
    required String req,
    required Object reqType,
    CancelToken? cancelToken,
  }) async {
    final String cleanReq = req.trim();
    if (cleanReq.isEmpty) {
      throw ArgumentError.value(req, 'req', 'Must not be empty.');
    }

    try {
      final Response<dynamic> response = await _apiService.dio.post<dynamic>(
        endpoint,
        data: <String, dynamic>{
          'req': cleanReq,
          'reqType': reqType,
        },
        cancelToken: cancelToken,
      );
      return ApiEnvelope.fromDynamic(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
