import 'package:rentit24/core/utils/json_converters.dart';

class CategoryModel {
  const CategoryModel({
    required this.name,
    this.id,
    this.type,
    this.sortOrder,
    this.isActive,
  });

  final int? id;
  final String name;
  final String? type;
  final int? sortOrder;
  final bool? isActive;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final String? name = JsonConverters.stringValue(
      json['name'] ?? json['category_name'] ?? json['categoryName'],
    );

    if (name == null) {
      throw const FormatException('Category name is missing.');
    }

    return CategoryModel(
      id: JsonConverters.intValue(
        json['id'] ?? json['category_id'] ?? json['categoryId'],
      ),
      name: name,
      type: JsonConverters.stringValue(
        json['type'] ?? json['category_type'] ?? json['categoryType'],
      ),
      sortOrder: JsonConverters.intValue(
        json['sort_order'] ?? json['sortOrder'],
      ),
      isActive: JsonConverters.boolValue(
        json['is_active'] ?? json['isActive'] ?? json['active'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'name': name,
      if (type != null) 'type': type,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
