class JsonConverters {
  JsonConverters._();

  static String? stringValue(dynamic value) {
    if (value == null) return null;
    final String converted = value.toString().trim();
    return converted.isEmpty ? null : converted;
  }

  static int? intValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  static double? doubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  static bool? boolValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    switch (value.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'y':
      case 'active':
        return true;
      case 'false':
      case '0':
      case 'no':
      case 'n':
      case 'inactive':
        return false;
      default:
        return null;
    }
  }

  static DateTime? dateTimeValue(dynamic value) {
    final String? converted = stringValue(value);
    return converted == null ? null : DateTime.tryParse(converted);
  }
}
