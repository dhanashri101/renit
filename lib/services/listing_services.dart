import 'package:dio/dio.dart';
import 'package:rentit24/core/network/api_endpoints.dart';
import 'package:rentit24/core/network/api_exception.dart';
import 'package:rentit24/core/network/api_response.dart';
import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/services/api_services.dart';

class ListingService {
  ListingService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<ListingModel>> getFeed({
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response<dynamic> response = await _apiService.dio.get<dynamic>(
        ApiEndpoints.listingFeed,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      final ApiEnvelope envelope = ApiEnvelope.fromDynamic(response.data);
      envelope.requireJsonResult();
      final dynamic result = envelope.result;

      if (result is! List) {
        throw ApiParsingException(
          'Expected listing/feed to return a list in res. Pagination cannot be implemented until the backend response schema is supplied.',
        );
      }

      return result
          .whereType<Map>()
          .map(
            (Map<dynamic, dynamic> item) =>
                ListingModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiParsingException('Unable to parse listing feed: $error');
    }
  }

  Future<ListingModel> getListingById(
    Object listingId, {
    CancelToken? cancelToken,
  }) async {
    final String id = listingId.toString().trim();
    if (id.isEmpty) {
      throw ArgumentError.value(listingId, 'listingId', 'Must not be empty.');
    }

    try {
      final Response<dynamic> response = await _apiService.dio.get<dynamic>(
        ApiEndpoints.listingDetails(id),
        cancelToken: cancelToken,
      );

      final ApiEnvelope envelope = ApiEnvelope.fromDynamic(response.data);
      envelope.requireJsonResult();
      final dynamic result = envelope.result;

      if (result is! Map) {
        throw const ApiParsingException(
          'Expected the listing details result to be a JSON object.',
        );
      }

      return ListingModel.fromJson(Map<String, dynamic>.from(result));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiParsingException('Unable to parse listing details: $error');
    }
  }
}
