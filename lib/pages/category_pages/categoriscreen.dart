import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/category_pages/category_ad_list_screen.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/services/category_services.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});
  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  int _selectedMainCategory = 0;
  final CategoryService _categoryService = CategoryService();

  final List<Map<String, dynamic>> _mainCategories = <Map<String, dynamic>>[];
  final Map<int, List<Map<String, dynamic>>> _allSubCategories =
      <int, List<Map<String, dynamic>>>{};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getCategories();
      if (!mounted) return;

      setState(() {
        _mainCategories
          ..clear()
          ..addAll(
            categories.map(
              (category) => <String, dynamic>{
                'id': category.id,
                'icon': _assetForCategory(category.name),
                'name': category.name,
              },
            ),
          );
        _selectedMainCategory = 0;
      });

      if (categories.isNotEmpty) {
        await _loadSubcategories(0);
      }
    } catch (error, stackTrace) {
      debugPrint('Category list error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _loadSubcategories(int index) async {
    if (index < 0 || index >= _mainCategories.length) return;

    setState(() => _selectedMainCategory = index);
    final parentId = _mainCategories[index]['id'] as int;

    try {
      final children = await _categoryService.getSubcategories(parentId);
      if (!mounted) return;
      setState(() {
        _allSubCategories[index] = children
            .map(
              (category) => <String, dynamic>{
                'id': category.id,
                'icon': _iconForCategory(category.name),
                'name': category.name,
              },
            )
            .toList();
      });
    } catch (error, stackTrace) {
      debugPrint('Subcategory error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _allSubCategories[index] = <Map<String, dynamic>>[]);
    }
  }

  String _assetForCategory(String name) {
    final value = name.toLowerCase();
    if (value.contains('baby') || value.contains('kids')) {
      return 'assets/images/categories/baby-kids.png';
    }
    if (value.contains('electronic')) {
      return 'assets/images/categories/electronics.png';
    }
    if (value.contains('furniture')) {
      return 'assets/images/categories/furniture.png';
    }
    if (value.contains('event')) {
      return 'assets/images/categories/event-professionals.png';
    }
    if (value.contains('tool') || value.contains('machinery')) {
      return 'assets/images/categories/tools-machinery.png';
    }
    return 'assets/images/categories/electronics.png';
  }

  IconData _iconForCategory(String name) {
    final value = name.toLowerCase();
    if (value.contains('laptop')) return Icons.laptop;
    if (value.contains('mobile')) return Icons.smartphone;
    if (value.contains('tablet')) return Icons.tablet_mac;
    if (value == 'tv' || value.contains('television')) return Icons.tv;
    if (value.contains('projector')) return Icons.videocam;
    if (value.contains('camera')) return Icons.camera_alt;
    if (value.contains('chair')) return Icons.chair_alt;
    if (value.contains('bed')) return Icons.bed;
    if (value.contains('table')) return Icons.table_restaurant;
    if (value.contains('plumb')) return Icons.plumbing;
    if (value.contains('carpent') || value.contains('wood')) return Icons.carpenter;
    if (value.contains('doctor')) return Icons.medical_services_outlined;
    if (value.contains('car') || value.contains('vehicle')) return Icons.directions_car_outlined;
    return Icons.category_outlined;
  }

  // Luminance-based grayscale matrix from your updated design
  static const List<double> _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Theme Colors
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final surfaceColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final primaryColor = theme.primaryColor; // Or AppTheme.primaryBlue if you prefer
    
    // Category Bar Colors
    final barBgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final selectedBgColor = isDark ? primaryColor.withOpacity(0.15) : const Color(0xFFF0F4FF);

    final currentSubCategories = _allSubCategories[_selectedMainCategory] ?? [];

    return Scaffold(
      backgroundColor: bgColor,
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
      body: Column(
        children: [
          // NEW:  Main Category Bar
          Container(
            height: 95,
            width: double.infinity,
            color: barBgColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _mainCategories.length,
              itemBuilder: (context, index) {
                final isActive = _selectedMainCategory == index;
                final cat = _mainCategories[index];
                
                final icon = Image.asset(
                  cat['icon'],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.category_outlined,
                    size: 24,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                );

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _loadSubcategories(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 85,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive ? selectedBgColor : Colors.transparent,
                      // borderRadius: BorderRadius.circular(12), 
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 32,
                          width: 32,
                          child: isActive
                              ? icon
                              : ColorFiltered(
                                  colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: icon,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? (isDark ? Colors.white : const Color(0xFF2C3E50))
                                : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Indicator Pill
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
          ),
          const SizedBox(height: 24),
          
          // Sub-category Grid (Remains Unchanged)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: currentSubCategories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            CategoryAdListScreen(
                              categoryId: currentSubCategories[index]['id'] as int?,
                              categoryName: currentSubCategories[index]['name'] as String? ?? 'Listings',
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          currentSubCategories[index]['icon'],
                          color: primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currentSubCategories[index]['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}