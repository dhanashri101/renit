import 'package:flutter/material.dart';
import 'package:rentit24/core/network/api_exception.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/pages/category_pages/category_ad_list_screen.dart';
import 'package:rentit24/services/category_services.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService _categoryService = CategoryService();
  late Future<List<CategoryModel>> _categoriesFuture;
  int _selectedMainCategory = 0;

  /// Existing UI-only subcategory data is retained because no verified
  /// subcategory endpoint/schema is available in the supplied contract.
  static const Map<String, List<_SubCategoryData>> _existingSubCategories =
      <String, List<_SubCategoryData>>{
    'baby kids': <_SubCategoryData>[
      _SubCategoryData(Icons.toys, 'Toys'),
      _SubCategoryData(Icons.child_friendly, 'Strollers'),
      _SubCategoryData(Icons.crib, 'Cribs'),
    ],
    'electronics': <_SubCategoryData>[
      _SubCategoryData(Icons.laptop, 'Laptop'),
      _SubCategoryData(Icons.smartphone, 'Mobile'),
      _SubCategoryData(Icons.tablet_mac, 'Tablet'),
      _SubCategoryData(Icons.tv, 'TV'),
      _SubCategoryData(Icons.videocam, 'Projector'),
      _SubCategoryData(Icons.camera_alt, 'Camera'),
    ],
    'furniture': <_SubCategoryData>[
      _SubCategoryData(Icons.chair_alt, 'Chairs'),
      _SubCategoryData(Icons.bed, 'Beds'),
      _SubCategoryData(Icons.table_restaurant, 'Tables'),
    ],
    'event professionals': <_SubCategoryData>[
      _SubCategoryData(Icons.camera_front, 'Photographers'),
      _SubCategoryData(Icons.music_note, 'DJs'),
    ],
    'tools machinery': <_SubCategoryData>[
      _SubCategoryData(Icons.plumbing, 'Plumbing'),
      _SubCategoryData(Icons.carpenter, 'Woodwork'),
    ],
    'tools & machinery': <_SubCategoryData>[
      _SubCategoryData(Icons.plumbing, 'Plumbing'),
      _SubCategoryData(Icons.carpenter, 'Woodwork'),
    ],
  };

  static const List<double> _grayscaleMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  void _retry() {
    setState(() {
      _selectedMainCategory = 0;
      _categoriesFuture = _categoryService.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final Color surfaceColor =
        isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Category List',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<CategoryModel>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final Object error = snapshot.error!;
            final String message = error is ApiException
                ? error.userMessage
                : 'Unable to load categories. Please retry.';
            return _CategoryErrorState(message: message, onRetry: _retry);
          }

          final List<CategoryModel> categories =
              (snapshot.data ?? <CategoryModel>[])
                  .where((CategoryModel item) => item.isActive != false)
                  .toList(growable: false);

          if (categories.isEmpty) {
            return _CategoryErrorState(
              message: 'No categories are available.',
              onRetry: _retry,
            );
          }

          if (_selectedMainCategory >= categories.length) {
            _selectedMainCategory = 0;
          }

          final CategoryModel selectedCategory =
              categories[_selectedMainCategory];
          final List<_SubCategoryData> subCategories =
              _existingSubCategories[
                    selectedCategory.name.trim().toLowerCase()
                  ] ??
                  const <_SubCategoryData>[];

          return Column(
            children: <Widget>[
              _buildMainCategoryBar(
                context: context,
                categories: categories,
                isDark: isDark,
                primaryColor: theme.primaryColor,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: subCategories.isEmpty
                    ? _buildSubcategoryAwaitingState(isDark)
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: subCategories.length,
                        itemBuilder: (BuildContext context, int index) {
                          final _SubCategoryData item = subCategories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder<void>(
                                  pageBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                  ) => const CategoryAdListScreen(),
                                  transitionsBuilder: (
                                    BuildContext context,
                                    Animation<double> animation,
                                    Animation<double> secondaryAnimation,
                                    Widget child,
                                  ) => FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    item.icon,
                                    color: theme.primaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainCategoryBar({
    required BuildContext context,
    required List<CategoryModel> categories,
    required bool isDark,
    required Color primaryColor,
  }) {
    final Color barBackground =
        isDark ? const Color(0xFF121212) : Colors.white;
    final Color selectedBackground = isDark
        ? primaryColor.withOpacity(0.15)
        : const Color(0xFFF0F4FF);

    return Container(
      height: 95,
      width: double.infinity,
      color: barBackground,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final CategoryModel category = categories[index];
          final bool isActive = _selectedMainCategory == index;
          final String assetPath =
              'assets/images/categories/${_assetSlug(category.name)}.png';

          final Widget icon = Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) => Icon(
              Icons.category_outlined,
              size: 24,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedMainCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 85,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: isActive ? selectedBackground : Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 32,
                    width: 32,
                    child: isActive
                        ? icon
                        : ColorFiltered(
                            colorFilter:
                                const ColorFilter.matrix(_grayscaleMatrix),
                            child: Opacity(opacity: 0.7, child: icon),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? (isDark
                              ? Colors.white
                              : const Color(0xFF2C3E50))
                          : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryAwaitingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.account_tree_outlined, size: 42),
            const SizedBox(height: 12),
            Text(
              'No verified subcategory API data is available for this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _assetSlug(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', '')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}

class _SubCategoryData {
  const _SubCategoryData(this.icon, this.name);

  final IconData icon;
  final String name;
}

class _CategoryErrorState extends StatelessWidget {
  const _CategoryErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
