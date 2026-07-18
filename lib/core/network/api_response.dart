import 'dart:convert';

import 'package:rentit24/core/network/api_exception.dart';

class ApiEnvelope {
  const ApiEnvelope({
    required this.raw,
    required this.result,
    required this.hasEnvelope,
    this.rescode,
    this.restype,
  });

  final dynamic raw;
  final dynamic result;
  final bool hasEnvelope;
  final dynamic rescode;
  final dynamic restype;

  factory ApiEnvelope.fromDynamic(dynamic value) {
    final dynamic decoded = _decodeJsonContainer(value);

    if (decoded is Map &&
        (decoded.containsKey('res') ||
            decoded.containsKey('rescode') ||
            decoded.containsKey('restype'))) {
      return ApiEnvelope(
        raw: decoded,
        result: _decodeJsonContainer(decoded['res']),
        hasEnvelope: true,
        rescode: decoded['rescode'],
        restype: decoded['restype'],
      );
    }

    return ApiEnvelope(
      raw: decoded,
      result: decoded,
      hasEnvelope: false,
    );
  }

  /// The backend meaning of rescode/restype is currently undocumented.
  /// This class deliberately does not treat any code as success or failure.
  void requireJsonResult() {
    if (result is String) {
      throw const ApiContractException(
        'The API returned a non-JSON res value. Its encoding/encryption contract must be provided by the backend before it can be processed safely.',
      );
    }
  }

  static dynamic _decodeJsonContainer(dynamic value) {
    if (value is! String) return value;

    final String trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final bool looksLikeJson =
        (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
    if (!looksLikeJson) return trimmed;

    try {
      return jsonDecode(trimmed);
    } on FormatException {
      return trimmed;
    }
  }
}
