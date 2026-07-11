import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/main.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/pages/category_pages/categoriscreen.dart';
import 'package:rentit24/pages/chat_screens/profile.dart';
import 'package:rentit24/wrapper/navbar.dart';
import 'package:rentit24/pages/product_details_screen.dart';
import 'package:rentit24/pages/searchscreen.dart';
import 'package:rentit24/services/category_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 1000);
  Timer? _timer;
  Timer? _hintTimer;
  int _currentPage = 0;
  final CategoryService _categoryService = CategoryService();

  late Future<List<CategoryModel>> _categoriesFuture;
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

  final List<AdItem> _adsData = [
    AdItem(
      title: 'Wheelchair',
      price: '₹200/day',
      distance: '0.5 km',
      owner: 'Sachin Jadhav',
      ownerAvatar:
          'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.2,
      reviews: 52,
      isFeatured: true,
      isTopChoice: true,
      category: 'Verified', // see note below re: isVerified
    ),
    AdItem(
      title: 'Canon EOS M50 Mark II...',
      price: '₹1500/day',
      distance: '2 km',
      owner: 'Hamza',
      ownerAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100',
      image: 'assets/images/camera.jpg',
      rating: 4.0,
      reviews: 10,
      isFeatured: false,
      isTopChoice: false,
    ),
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


  double _scale(double width) => (width / 390).clamp(0.85, 1.35);

 
  int _gridColumns(double width) {
    if (width >= 1100) return 5;
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }


  double _contentMaxWidth(double width) => width > 900 ? 900 : width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = _contentMaxWidth(width);
    final scale = _scale(maxWidth);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth > 900 ? 900 : double.infinity,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomAppBar(theme, isDark, maxWidth, scale),
                  SizedBox(height: 20 * scale),
                  _buildBannerCarousel(theme, isDark, maxWidth, scale),
                  SizedBox(height: 24 * scale),
                  _buildSectionHeader(
                    'Browse Categories',
                    'See all',
                    theme,
                    scale,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryListScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16 * scale),
                  _buildCategories(theme, maxWidth, scale),
                  SizedBox(height: 24 * scale),
                  _buildSectionHeader(
                    'Hire a Professional',
                    'See all',
                    theme,
                    scale,
                  ),
                  SizedBox(height: 16 * scale),
                  _buildProfessionalList(theme, context, maxWidth, scale),
                  SizedBox(height: 24 * scale),
                  _buildSectionHeader('Nearby Ads', '', theme, scale),
                  SizedBox(height: 16 * scale),
                  _buildFilterChips(theme, scale),
                  SizedBox(height: 16 * scale),
                  _buildNearbyAdsGrid(theme, maxWidth, scale),
                  SizedBox(height: 16 * scale),
                  _buildPromoBanner(theme, maxWidth, scale),
                  SizedBox(height: 30 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCustomAppBar(
    ThemeData theme,
    bool isDark,
    double width,
    double scale,
  ) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top > 0 ? 35 * scale : 75 * scale,
        left: 16 * scale,
        right: 16 * scale,
        bottom: 20 * scale,
      ),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24 * scale),
          bottomRight: Radius.circular(24 * scale),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rentit24',
                style: AppTypography.h5Style(
                  AppColors.baseWhite,
                ).copyWith(fontSize: AppTypography.h5 * scale),
              ),
              Row(
                children: [
                  Text(
                    'Mumbra, Maharashtra',
                    style: AppTypography.bodyExtraSmall(
                      AppTypography.regular,
                      AppColors.baseWhite.withOpacity(0.7),
                    ).copyWith(fontSize: AppTypography.bodySM * scale),
                  ),
                  SizedBox(width: 4 * scale),
                  Container(
                    padding: EdgeInsets.all(4 * scale),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: AppColors.baseWhite.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.baseWhite,
                      size: 16 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
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
                    height: 45 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neutral800
                          : AppColors.baseWhite,
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: theme.primaryColor,
                          size: 22 * scale,
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            switchInCurve: Curves.easeOutQuint,
                            switchOutCurve: Curves.easeInQuint,
                            transitionBuilder: (child, animation) {
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
                                style:
                                    AppTypography.bodyMedium(
                                      AppTypography.regular,
                                      AppColors.neutral400,
                                    ).copyWith(
                                      fontSize: AppTypography.bodyMD * scale,
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
              SizedBox(width: 12 * scale),
              // _buildAppBarIcon(
              //   isDark ? Icons.light_mode : Icons.dark_mode,
              //   theme,
              //   isDark,
              //   scale,
              //   onTap: () {
              //     themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              //   },
              // ),
              // SizedBox(width: 12 * scale),
              _buildAppBarIcon(Icons.favorite_border, theme, isDark, scale),
              SizedBox(width: 12 * scale),
              _buildAppBarIcon(Icons.notifications_none, theme, isDark, scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(
    IconData icon,
    ThemeData theme,
    bool isDark,
    double scale, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45 * scale,
        width: 45 * scale,
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : AppColors.baseWhite,
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 22 * scale),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // BANNER CAROUSEL
  // ---------------------------------------------------------------------

  Widget _buildBannerCarousel(
    ThemeData theme,
    bool isDark,
    double width,
    double scale,
  ) {
    final bannerHeight = (width * 0.46).clamp(150.0, 220.0);
    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index % _bannerData.length;
              });
            },
            itemBuilder: (context, index) {
              final dataIndex = index % _bannerData.length;
              return _buildBannerCard(
                _bannerData[dataIndex],
                theme,
                isDark,
                scale,
              );
            },
          ),
        ),
        SizedBox(height: 14 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerData.length,
            (index) => _buildAnimatedDot(index == _currentPage, theme, scale),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(
    Map<String, String> data,
    ThemeData theme,
    bool isDark,
    double scale,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale),
      padding: EdgeInsets.only(
        left: 24 * scale,
        top: 20 * scale,
        bottom: 20 * scale,
        right: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseBlack.withOpacity(isDark ? 0.2 : 0.06),
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
                  style: AppTypography.headingStyle(
                    AppTypography.h4,
                    isDark ? AppColors.baseWhite : AppColors.neutral900,
                  ).copyWith(fontSize: AppTypography.h4 * scale, height: 1.2),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  data['subtitle']!,
                  style:
                      AppTypography.bodySmall(
                        AppTypography.regular,
                        AppColors.neutral400,
                      ).copyWith(
                        fontSize: AppTypography.bodySM * scale,
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

  Widget _buildAnimatedDot(bool isActive, ThemeData theme, double scale) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(horizontal: 4 * scale),
      width: (isActive ? 24 : 8) * scale,
      height: 8 * scale,
      decoration: BoxDecoration(
        color: isActive
            ? theme.primaryColor
            : theme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SECTION HEADER
  // ---------------------------------------------------------------------

  Widget _buildSectionHeader(
    String title,
    String action,
    ThemeData theme,
    double scale, {
    VoidCallback? onSeeAll,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.headingStyle(
              AppTypography.h6,
              isDark ? AppColors.baseWhite : AppColors.neutral900,
            ).copyWith(fontSize: AppTypography.h6 * scale),
          ),
          if (action.isNotEmpty)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: AppTypography.bodySmall(
                  AppTypography.medium,
                  AppColors.neutral400,
                ).copyWith(fontSize: AppTypography.bodySM * scale),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories(ThemeData theme, double width, double scale) {
    final isDark = theme.brightness == Brightness.dark;

    final double itemWidth = 76.0 * scale;

    final List<Map<String, String>> fallbackCategories = [
      {
        'name': 'Agriculture & Farming',
        'image': 'assets/images/categories/agriculture-farming.png',
      },
      {
        'name': 'Appliances',
        'image': 'assets/images/categories/appliances.png',
      },
      {
        'name': 'Baby & Kids',
        'image': 'assets/images/categories/baby-kids.png',
      },
      {
        'name': 'Beauty & Grooming',
        'image': 'assets/images/categories/beauty-grooming.png',
      },
      {
        'name': 'Books & Stationery',
        'image': 'assets/images/categories/books-stationery.png',
      },
      {
        'name': 'Community & NGO',
        'image': 'assets/images/categories/community-ngo.png',
      },
      {
        'name': 'Construction',
        'image': 'assets/images/categories/construction-heavy-machinery.png',
      },
      {
        'name': 'Coworking',
        'image': 'assets/images/categories/coworking-business.png',
      },
      {
        'name': 'Delivery & Logistics',
        'image': 'assets/images/categories/delivery-logistics.png',
      },
      {
        'name': 'Digital & Tech',
        'image': 'assets/images/categories/digital-tech-services.png',
      },
      {'name': 'Education', 'image': 'assets/images/categories/education.png'},
      {
        'name': 'Electronics',
        'image': 'assets/images/categories/electronics.png',
      },
      {
        'name': 'Event Professionals',
        'image': 'assets/images/categories/event-professionals.png',
      },
      {
        'name': 'Events & Parties',
        'image': 'assets/images/categories/events-parties.png',
      },
      {
        'name': 'Fashion & Dress',
        'image': 'assets/images/categories/fashion-dress.png',
      },
      {
        'name': 'Fashion Services',
        'image': 'assets/images/categories/fashion-services.png',
      },
      {
        'name': 'Festivals',
        'image': 'assets/images/categories/festivals-celebrations.png',
      },
      {
        'name': 'Food & Catering',
        'image': 'assets/images/categories/food-catering.png',
      },
      {'name': 'Furniture', 'image': 'assets/images/categories/furniture.png'},
      {
        'name': 'Gaming Consoles',
        'image': 'assets/images/categories/gaming-consoles.png',
      },
      {
        'name': 'Gardening & Outdoor',
        'image': 'assets/images/categories/gardening-outdoor.png',
      },
      {
        'name': 'Health & Wellness',
        'image': 'assets/images/categories/health-wellness.png',
      },
      {
        'name': 'Household Items',
        'image': 'assets/images/categories/household-items.png',
      },
      {
        'name': 'Medical Equipment',
        'image': 'assets/images/categories/medical-equipment.png',
      },
      {
        'name': 'Miscellaneous',
        'image': 'assets/images/categories/miscellaneous.png',
      },
      {
        'name': 'Musical Instruments',
        'image': 'assets/images/categories/musical-instruments.png',
      },
      {
        'name': 'Office Equipment',
        'image': 'assets/images/categories/office-work-equipment.png',
      },
      {
        'name': 'Pets & Animals',
        'image': 'assets/images/categories/pets-animals.png',
      },
      {
        'name': 'Professional Services',
        'image': 'assets/images/categories/professional-services.png',
      },
      {
        'name': 'Real Estate',
        'image': 'assets/images/categories/real-estate.png',
      },
      {
        'name': 'Security Services',
        'image': 'assets/images/categories/security-services.png',
      },
      {
        'name': 'Seasonal Needs',
        'image': 'assets/images/categories/sesonal-needs.png',
      },
      {
        'name': 'Sports & Fitness',
        'image': 'assets/images/categories/sports-fitness.png',
      },
      {
        'name': 'Tools & Machinery',
        'image': 'assets/images/categories/tools-machinery.png',
      },
      {
        'name': 'Transportation',
        'image': 'assets/images/categories/transportation-services.png',
      },
      {
        'name': 'Travel & Hospitality',
        'image': 'assets/images/categories/travel-hospitality.png',
      },
      {
        'name': 'Travel & Outdoors',
        'image': 'assets/images/categories/travel-outdoors.png',
      },
      {'name': 'Vehicles', 'image': 'assets/images/categories/vehicles.png'},
      {
        'name': 'Wedding Photography',
        'image': 'assets/images/categories/wedding-photography.png',
      },
    ];

    return SizedBox(
      height: 120 * scale,
      child: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          final bool useFallback =
              snapshot.hasError || (snapshot.data?.isEmpty ?? true);
          final categories = snapshot.data ?? [];
          final int itemCount = useFallback
              ? fallbackCategories.length
              : categories.length;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(width: 8 * scale),
            itemBuilder: (context, index) {
              final String categoryName = useFallback
                  ? fallbackCategories[index]['name']!
                  : categories[index].name;

              final String? imageAssetPath = useFallback
                  ? fallbackCategories[index]['image']
                  : null;

              return SizedBox(
                width: itemWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: ShapeDecoration(
                        color: isDark
                            ? AppColors.neutral800
                            : AppColors.baseWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        shadows: [
                          BoxShadow(
                            color: AppColors.baseBlack.withOpacity(
                              isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 40 * scale,
                        height: 40 * scale,
                        child: imageAssetPath != null
                            ? Image.asset(imageAssetPath, fit: BoxFit.contain)
                            : Icon(
                                Icons.category_outlined,
                                color: AppColors.primary500,
                                size: 24 * scale,
                              ),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      categoryName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppTypography.bodyExtraSmall(
                            AppTypography.semibold,
                            isDark
                                ? AppColors.baseWhite.withOpacity(0.7)
                                : AppColors.neutral800,
                          ).copyWith(
                            fontSize: AppTypography.bodyXS * scale,
                            height: 1.2,
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
    double width,
    double scale,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    // Adjusted to match the larger, cleaner card in the WhatsApp image
    final double cardWidth = 320.0 * scale;
    final double cardHeight =
        160.0 * scale; // Taller card for portrait image and breathing room
    final double padding = 12.0 * scale;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: 2,
        separatorBuilder: (context, index) =>
            SizedBox(width: 16 * scale), // Slightly wider gap
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(
                    adData: const {
                      'title': 'Plumber',
                      'price': '₹1200/day',
                      'rating': '4.6',
                      'reviews': '189',
                      'owner': 'Sadiq Ahmed',
                      'image':
                          'assets/images/carpainter.jpg', // Replace with plumber image
                    },
                    adData: AdItem(
                      title: 'Wood craft and wood carving',
                      price: '₹800/day',
                      rating: 4.5,
                      reviews: 122,
                      owner: 'Ravi Kumar R.',
                      ownerAvatar: 'https://i.pravatar.cc/150?img=11',
                      image: 'assets/images/carpainter.jpg',
                      distance: '1.5 km',
                    ),
                  ),
                ),
              );
            },
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242426) : AppColors.baseWhite,
                borderRadius: BorderRadius.circular(24 * scale),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.baseBlack.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16 * scale),
                    child: Image.asset(
                      "assets/images/carpainter.jpg", 
                      width: 105 * scale,
                      height:
                          double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 105 * scale,
                        color: AppColors.neutral200,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16 * scale,
                  ), // Wider spacing between image and text
                  // Text Content Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Perfect vertical distribution
                      children: [
                        // 1. Rating & Heart Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: const Color(0xFFFFB800),
                                  size: 16 * scale,
                                ), // Brighter yellow
                                SizedBox(width: 6 * scale),
                                Text(
                                  '4.6',
                                  style: AppTypography.bodySmall(
                                    AppTypography.bold,
                                    isDark
                                        ? AppColors.baseWhite
                                        : AppColors.neutral900,
                                  ).copyWith(fontSize: 13 * scale),
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  '(189)',
                                  style: AppTypography.bodySmall(
                                    AppTypography.regular,
                                    isDark
                                        ? AppColors.baseWhite.withOpacity(0.5)
                                        : AppColors.neutral500,
                                  ).copyWith(fontSize: 12 * scale),
                                ),
                              ],
                            ),
                            // More pronounced circular background for the heart
                            Container(
                              padding: EdgeInsets.all(6 * scale),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF323236)
                                    : AppColors.neutral100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.favorite_border,
                                color: isDark
                                    ? AppColors.baseWhite
                                    : AppColors.neutral900,
                                size: 16 * scale,
                              ),
                            ),
                          ],
                        ),

                        // 2. Tags
                        Row(
                          children: [
                            _buildTag(
                              'Featured',
                              const Color(0xFF3B82F6),
                              AppColors.baseWhite,
                              scale,
                            ), // Bright blue
                            SizedBox(width: 8 * scale),
                            _buildTag(
                              'Top Choice',
                              const Color(0xFF1E1B4B),
                              AppColors.baseWhite,
                              scale,
                            ), // Deep navy
                          ],
                        ),

                        // 3. User Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10 * scale,
                              backgroundImage: const NetworkImage(
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100',
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Sadiq Ahmed',
                                      style: AppTypography.bodySmall(
                                        AppTypography.bold,
                                        isDark
                                            ? AppColors.baseWhite
                                            : AppColors.neutral900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Icon(
                                    Icons.workspace_premium,
                                    color: isDark
                                        ? AppColors.baseWhite
                                        : AppColors.neutral900,
                                    size: 14 * scale,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Plumber',
                              style: AppTypography.bodyExtraSmall(
                                AppTypography.medium,
                                isDark
                                    ? AppColors.baseWhite.withOpacity(0.5)
                                    : AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          'Plumber',
                          style: AppTypography.bodyLarge(
                            AppTypography.medium,
                            isDark ? AppColors.baseWhite : AppColors.neutral800,
                          ).copyWith(fontSize: 16 * scale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // 5. Bottom Row (Location & Price)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: isDark
                                      ? AppColors.baseWhite.withOpacity(0.5)
                                      : AppColors.neutral500,
                                  size: 14 * scale,
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  '4.2 km',
                                  style: AppTypography.bodySmall(
                                    AppTypography.regular,
                                    isDark
                                        ? AppColors.baseWhite.withOpacity(0.5)
                                        : AppColors.neutral500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '₹1200/day',
                              style: AppTypography.headingStyle(
                                AppTypography.h6,
                                isDark
                                    ? AppColors.baseWhite
                                    : AppColors.neutral900,
                              ).copyWith(fontSize: 16 * scale, height: 1.0),
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

  Widget _buildFilterChips(ThemeData theme, double scale) {
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      height: 38 * scale,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = filter == _selectedFilter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 12 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 22 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary500
                    : (isDark ? AppColors.neutral800 : AppColors.baseWhite),
                borderRadius: BorderRadius.circular(30 * scale),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary500.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.baseBlack.withOpacity(
                            isDark ? 0.1 : 0.03,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: AppTypography.bodyMedium(
                    isActive ? AppTypography.semibold : AppTypography.medium,
                    isActive
                        ? AppColors.baseWhite
                        : (isDark
                              ? AppColors.neutral300
                              : AppColors.neutral400),
                  ).copyWith(fontSize: AppTypography.bodyMD * scale),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // NEARBY ADS GRID
  // ---------------------------------------------------------------------

  Widget _buildNearbyAdsGrid(ThemeData theme, double width, double scale) {
    final filteredAds = _adsData.where((ad) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Featured') return ad.isFeatured;
      if (_selectedFilter == 'Top Choice') return ad.isTopChoice;
      // NOTE: AdItem has no isVerified field — see note below.
      if (_selectedFilter == 'Verified') return ad.isFeatured; // placeholder
      return true;
    }).toList();

    final columns = _gridColumns(width);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 16 * scale,
          mainAxisSpacing: 16 * scale,
          childAspectRatio: 0.68,
        ),
        itemCount: filteredAds.length,
        itemBuilder: (context, index) {
          final ad = filteredAds[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductDetailsScreen(adData: ad),
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
              ad.price,
              ad.distance,
              ad.owner,
              ad.image,
              ad.ownerAvatar,
              ad.rating.toStringAsFixed(1),
              ad.reviews.toString(),
              ad.isFeatured,
              ad.isTopChoice,
              false, // isVerified placeholder — see note below
              theme,
              scale,
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
    double scale,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : AppColors.baseWhite,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseBlack.withOpacity(isDark ? 0.3 : 0.06),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8 * scale),
                  topRight: Radius.circular(8 * scale),
                ),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: Image.asset(
                    imgUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      color: AppColors.neutral200,
                      child: const Icon(
                        Icons.image,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              ),
              if (isFeatured)
                Positioned(
                  top: 11 * scale,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(2 * scale),
                        bottomRight: Radius.circular(2 * scale),
                      ),
                    ),
                    child: Text(
                      'Featured',
                      style: AppTypography.bodyExtraSmall(
                        AppTypography.medium,
                        AppColors.baseWhite,
                      ).copyWith(letterSpacing: 0.20),
                    ),
                  ),
                ),
              Positioned(
                top: 8 * scale,
                right: 8 * scale,
                child: Container(
                  padding: EdgeInsets.all(6 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.neutral900.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: AppColors.baseWhite,
                    size: 14 * scale,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0 * scale),
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
                            color: AppColors.neutral300,
                            size: 10 * scale,
                          ),
                          SizedBox(width: 4 * scale),
                          Text(
                            distance,
                            style: AppTypography.bodyExtraSmall(
                              AppTypography.light,
                              isDark
                                  ? AppColors.baseWhite.withOpacity(0.6)
                                  : AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      if (isTopChoice)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4 * scale,
                            vertical: 2 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.neutral700
                                : AppColors.neutral900,
                            borderRadius: BorderRadius.circular(2 * scale),
                          ),
                          child: Text(
                            'Top Choice',
                            style: AppTypography.bodyExtraSmall(
                              AppTypography.regular,
                              AppColors.baseWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    title,
                    style: AppTypography.bodySmall(
                      AppTypography.medium,
                      isDark ? AppColors.baseWhite : AppColors.neutral700,
                    ).copyWith(height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    price,
                    style: AppTypography.bodyMedium(
                      AppTypography.bold,
                      isDark ? AppColors.baseWhite : AppColors.neutral900,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8 * scale,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      SizedBox(width: 6 * scale),
                      Expanded(
                        child: Text(
                          owner,
                          style: AppTypography.bodyExtraSmall(
                            AppTypography.medium,
                            isDark ? AppColors.baseWhite : AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        Icon(
                          Icons.verified,
                          color: AppColors.info500,
                          size: 10 * scale,
                        ),
                    ],
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.warning400,
                        size: 12 * scale,
                      ),
                      SizedBox(width: 2 * scale),
                      Text(
                        rating,
                        style: AppTypography.bodyExtraSmall(
                          AppTypography.medium,
                          isDark
                              ? AppColors.baseWhite.withOpacity(0.7)
                              : AppColors.neutral700,
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        '($reviews)',
                        style: AppTypography.bodyExtraSmall(
                          AppTypography.regular,
                          isDark
                              ? AppColors.baseWhite.withOpacity(0.6)
                              : AppColors.neutral500,
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

  // ---------------------------------------------------------------------
  // PROMO BANNER
  // ---------------------------------------------------------------------

  Widget _buildPromoBanner(ThemeData theme, double width, double scale) {
    final bannerHeight = (width * 0.31).clamp(100.0, 150.0);

    return Container(
      height: bannerHeight,
      margin: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseBlack.withOpacity(0.15),
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
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16 * scale),
                bottomRight: Radius.circular(16 * scale),
              ),
              child: Image.asset(
                'assets/images/pizza.jpg',
                width: width * 0.55,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scale),
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
            padding: EdgeInsets.symmetric(
              horizontal: 16.0 * scale,
              vertical: 16.0 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.4,
                  child: Text(
                    'Italian Pizza now in Mumbra!!',
                    style:
                        AppTypography.bodyLarge(
                          AppTypography.bold,
                          AppColors.baseWhite,
                        ).copyWith(
                          fontSize: AppTypography.bodyLG * scale,
                          height: 1.2,
                        ),
                  ),
                ),
                SizedBox(height: 6 * scale),
                SizedBox(
                  width: width * 0.4,
                  child: Text(
                    'The real taste of italian pizza is here..',
                    style: AppTypography.bodyExtraSmall(
                      AppTypography.light,
                      AppColors.baseWhite.withOpacity(0.7),
                    ).copyWith(height: 1.3),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Know more',
                      style: AppTypography.bodyExtraSmall(
                        AppTypography.medium,
                        AppColors.baseWhite,
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.baseWhite,
                      size: 10 * scale,
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

  Widget _buildTag(String text, Color bgColor, Color textColor, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 3 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        text,
        style: AppTypography.bodyExtraSmall(AppTypography.bold, textColor),
      ),
    );
  }
}
