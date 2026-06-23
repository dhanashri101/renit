class CategoryModel {
  final int id;
  final String name;
  final String type;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sortOrder,
    required this.isActive,
  });
}