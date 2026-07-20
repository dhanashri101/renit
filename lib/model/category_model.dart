import 'package:rentit24/config/api_config.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sortOrder,
    required this.isActive,
    this.parentId,
    this.iconUrl = '',
  });

  final int id;
  final String name;
  final int? parentId;
  final String iconUrl;
  final String type;
  final int sortOrder;
  final bool isActive;

  bool get isTopLevel => parentId == null;
  bool get isService => type.toLowerCase() == 'service';

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _toInt(json['id'] ?? json['category_id'] ?? json['categoryId']),
      name: _toString(json['name'] ?? json['category_name'] ?? json['categoryName']),
      parentId: _toNullableInt(json['parent_id'] ?? json['parentId']),
      iconUrl: ApiConfig.resolveMediaUrl(
        _toString(json['icon_url'] ?? json['iconUrl']),
      ),
      type: _toString(json['type'] ?? json['category_type'] ?? json['categoryType']),
      sortOrder: _toInt(json['sort_order'] ?? json['sortOrder']),
      isActive: _toBool(json['is_active'] ?? json['isActive'] ?? json['active'], fallback: true),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return _toInt(value);
  }

  static String _toString(dynamic value) => value?.toString().trim() ?? '';

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().trim().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes' || text == 'active';
  }
}
