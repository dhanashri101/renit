import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/main.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/model/listing_model.dart'; // Added ListingModel
import 'package:rentit24/pages/category_pages/categoriscreen.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:rentit24/pages/product_details_screen.dart';
import 'package:rentit24/pages/searchscreen.dart';
import 'package:rentit24/services/category_services.dart';
import 'package:rentit24/services/listing_services.dart'; // Added ListingService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final PageController _pageController = PageController(initialPage: 1000);
  Timer? _timer;
  Timer? _hintTimer;
  int _currentPage = 0;

  final CategoryService _categoryService = CategoryService();
  final ListingService _listingService =
      ListingService(); // Initialize ListingService

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<ListingModel>> _feedFuture; // Future for the feed

  int _currentHintIndex = 0;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Featured', 'Top Choice', 'Verified'];

  final List<String> _searchHints = [
    'Carpenter',
    'Wheelchair',
    'Camera',
    'Projector',
    'Guitar',
  ];

  final List<Map<String, String>> _bannerData = [
    {
      'title': 'Rent Anything\nRent Anytime',
      'subtitle': 'From furniture to bicycle\nrent it all..',
      'image': 'assets/images/slide1-illustration.png',
    },
    {
      'title': 'Need a cool\ndress?',
      'subtitle': 'From party wear to\nwedding wear find it all..',
      'image': 'assets/images/slide2-illustration.png',
    },
    {
      'title': 'Wanna be a\nguitarist?',
      'subtitle': 'From guitar to bongo\nfind it all..',
      'image': 'assets/images/slide3-illustration.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
    _feedFuture = _listingService.getFeed(); // Fetch live feed

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    _hintTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomAppBar(theme, isDark),
            const SizedBox(height: 20),
            _buildBannerCarousel(theme, isDark),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Browse Categories',
              'See all',
              theme,
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCategories(theme),
            const SizedBox(height: 24),

            // Replaced static lists with FutureBuilder to handle API data
            FutureBuilder<List<ListingModel>>(
              future: _feedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  // Print to the debug console for good measure
                  debugPrint('Feed Error: ${snapshot.error}');

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}', // <-- This will show the actual error on screen
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final allListings = snapshot.data ?? [];

                // Separate data into services and products based on listingType
                final services = allListings
                    .where((l) => l.listingType == 'Service')
                    .toList();
                final products = allListings
                    .where((l) => l.listingType == 'Product')
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Hire a Professional',
                      'See all',
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildProfessionalList(theme, context, services),

                    const SizedBox(height: 24),

                    _buildSectionHeader('Nearby Ads', '', theme),
                    const SizedBox(height: 16),
                    _buildFilterChips(theme),
                    const SizedBox(height: 16),
                    _buildNearbyAdsGrid(theme, products),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            _buildPromoBanner(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rentit24',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Mumbra, Maharashtra',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: theme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOutQuint,
                            switchOutCurve: Curves.easeInQuint,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.0, 0.4),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: Align(
                              key: ValueKey<int>(_currentHintIndex),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Hire a "${_searchHints[_currentHintIndex]}"',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildAppBarIcon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                theme,
                isDark,
                onTap: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              ),
              const SizedBox(width: 12),
              _buildAppBarIcon(Icons.favorite_border, theme, isDark),
              const SizedBox(width: 12),
              _buildAppBarIcon(Icons.notifications_none, theme, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(
    IconData icon,
    ThemeData theme,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.primaryColor),
      ),
    );
  }

  Widget _buildBannerCarousel(ThemeData theme, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index % _bannerData.length;
              });
            },
            itemBuilder: (context, index) {
              final dataIndex = index % _bannerData.length;
              return _buildBannerCard(_bannerData[dataIndex], theme, isDark);
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerData.length,
            (index) => _buildAnimatedDot(index == _currentPage, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(
    Map<String, String> data,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(left: 24, top: 20, bottom: 20, right: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data['title']!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2C),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data['subtitle']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Image.asset(data['image']!, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(bool isActive, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.primaryColor
            : theme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String action,
    ThemeData theme, {
    VoidCallback? onSeeAll,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2C),
            ),
          ),
          if (action.isNotEmpty)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      child: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load categories',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.red),
              ),
            );
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.category_outlined,
                          color: Color(0xFF2B58E4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF2D2D3A),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfessionalList(
    ThemeData theme,
    BuildContext context,
    List<ListingModel> services,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    if (services.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No professionals available right now.',
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];

          return GestureDetector(
            onTap: () {
              // Creating a fallback map since ProductDetailsScreen currently expects a Map
              final Map<String, dynamic> adDataMap = {
                'title': service.title,
                'price':
                    '₹${service.rentalPrice.toStringAsFixed(0)}/${service.priceUnit}',
                'rating': service.rating.toStringAsFixed(1),
                'reviews': service.reviewCount.toString(),
                'owner':
                    'User ${service.ownerId}', // Mapping ID to generic name for now
                'image': 'assets/images/carpainter.jpg', // Placeholder
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(adData: adDataMap),
                ),
              );
            },
            child: Container(
              width: 320,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/carpainter.jpg", // Replace with network image once model supports it
                      width: 120,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  '(${service.reviewCount})',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.favorite_border,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (service.isFeatured)
                              _buildTag(
                                'Featured',
                                theme.primaryColor,
                                Colors.white,
                              ),
                            if (service.isFeatured) const SizedBox(width: 6),
                            if (service.isTopChoice)
                              _buildTag(
                                'Top Choice',
                                isDark
                                    ? Colors.grey[800]!
                                    : const Color(0xFF1A1A2C),
                                Colors.white,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(
                                'https://ui-avatars.com/api/?name=User+${service.ownerId}&background=random',
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'User ${service.ownerId}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF090726),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  height: 1.20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (service.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.blue,
                                size: 12,
                              ),
                            ],
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                service.profession,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0x66090726),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  height: 1.20,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          service.title,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF2F314D),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.42,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.grey,
                                  size: 14,
                                ),
                                Text(
                                  '1.5 km', // Placeholder for actual distance logic
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : const Color(0x66090726),
                                    fontWeight: FontWeight.w300,
                                    height: 1.20,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹${service.rentalPrice.toStringAsFixed(0)}/${service.priceUnit.split(' ').last}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF090726),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFilterChips(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF2B58E4)
                    : (isDark ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.circular(30),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2B58E4).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : const Color(0xFF7A7A8C)),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyAdsGrid(ThemeData theme, List<ListingModel> products) {
    // Filter the API products based on the selected chip
    final filteredAds = products.where((ad) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Featured') return ad.isFeatured;
      if (_selectedFilter == 'Top Choice') return ad.isTopChoice;
      if (_selectedFilter == 'Verified') return ad.isVerified;
      return true;
    }).toList();

    if (filteredAds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No ads found for this filter.',
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: filteredAds.length,
        itemBuilder: (context, index) {
          final ad = filteredAds[index];

          return GestureDetector(
            onTap: () {
              // Creating a fallback map since ProductDetailsScreen currently expects a Map
              final Map<String, dynamic> adMap = {
                'title': ad.title,
                'price':
                    '₹${ad.rentalPrice.toStringAsFixed(0)}/${ad.priceUnit.split(' ').last}',
                'distance': '1.5 km',
                'owner': 'User ${ad.ownerId}',
                'ownerAvatar':
                    'https://ui-avatars.com/api/?name=User+${ad.ownerId}',
                'image': 'assets/images/camera.jpg', // Placeholder
                'rating': ad.rating.toStringAsFixed(1),
                'reviews': ad.reviewCount.toString(),
                'isFeatured': ad.isFeatured,
                'isTopChoice': ad.isTopChoice,
                'isVerified': ad.isVerified,
              };

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductDetailsScreen(adData: adMap),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        final tween = Tween(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeInOut));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
            },
            child: _buildAdCard(
              ad.title,
              '₹${ad.rentalPrice.toStringAsFixed(0)}/${ad.priceUnit.split(' ').last}',
              '1.5 km', // Placeholder for actual distance calculation
              'User ${ad.ownerId}',
              'assets/images/camera.jpg', // Placeholder
              'https://ui-avatars.com/api/?name=User+${ad.ownerId}&background=random',
              ad.rating.toStringAsFixed(1),
              ad.reviewCount.toString(),
              ad.isFeatured,
              ad.isTopChoice,
              ad.isVerified,
              theme,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdCard(
    String title,
    String price,
    String distance,
    String owner,
    String imgUrl,
    String avatarUrl,
    String rating,
    String reviews,
    bool isFeatured,
    bool isTopChoice,
    bool isVerified,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.asset(
                  imgUrl,
                  height: 104,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 104,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              if (isFeatured)
                Positioned(
                  top: 11,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF235BD6),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.20,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0x66090726),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[400],
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0x99090726),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      if (isTopChoice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]
                                : const Color(0xFF090726),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'Top Choice',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF2F314D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF090726),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          owner,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF090726),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 10,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        rating,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF2F314D),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($reviews)',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white54
                              : const Color(0x99090726),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.asset(
                'assets/images/pizza.jpg',
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFA0F0C29),
                  Color(0x00090726),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 150,
                  child: Text(
                    'Italian Pizza now in Mumbra!!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 150,
                  child: Text(
                    'The real taste of italian pizza is here..',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: const [
                    Text(
                      'Know more',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
