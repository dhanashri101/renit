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
      category: 'Verified',
    ),
    AdItem(
      title: 'Canon EOS M50 Mark II',
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
    AdItem(
      title: 'Carpenter Tool Kit',
      price: '₹350/day',
      distance: '1.2 km',
      owner: 'Ravi Kumar',
      ownerAvatar: 'https://i.pravatar.cc/150?img=11',
      image: 'assets/images/carpainter.jpg',
      rating: 4.5,
      reviews: 122,
      isFeatured: true,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Manual Wheelchair - Foldable',
      price: '₹180/day',
      distance: '0.8 km',
      owner: 'Priya Shah',
      ownerAvatar: 'https://i.pravatar.cc/150?img=5',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.1,
      reviews: 34,
      isFeatured: false,
      isTopChoice: true,
    ),
    AdItem(
      title: 'DSLR Camera Kit with Lens',
      price: '₹1200/day',
      distance: '3.4 km',
      owner: 'Aditya Rao',
      ownerAvatar: 'https://i.pravatar.cc/150?img=8',
      image: 'assets/images/camera.jpg',
      rating: 4.7,
      reviews: 88,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Professional Wood Carving Set',
      price: '₹450/day',
      distance: '2.1 km',
      owner: 'Imran Sheikh',
      ownerAvatar: 'https://i.pravatar.cc/150?img=12',
      image: 'assets/images/carpainter.jpg',
      rating: 3.9,
      reviews: 21,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Electric Wheelchair',
      price: '₹500/day',
      distance: '1.9 km',
      owner: 'Neha Joshi',
      ownerAvatar: 'https://i.pravatar.cc/150?img=15',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.4,
      reviews: 60,
      isFeatured: true,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Mirrorless Camera - Sony A6400',
      price: '₹1800/day',
      distance: '4.0 km',
      owner: 'Farhan Khan',
      ownerAvatar: 'https://i.pravatar.cc/150?img=18',
      image: 'assets/images/camera.jpg',
      rating: 4.3,
      reviews: 45,
      isFeatured: false,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Carpentry Power Tools',
      price: '₹600/day',
      distance: '2.7 km',
      owner: 'Suresh Patil',
      ownerAvatar: 'https://i.pravatar.cc/150?img=20',
      image: 'assets/images/carpainter.jpg',
      rating: 4.0,
      reviews: 15,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Lightweight Travel Wheelchair',
      price: '₹220/day',
      distance: '1.1 km',
      owner: 'Kavita Nair',
      ownerAvatar: 'https://i.pravatar.cc/150?img=22',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.6,
      reviews: 77,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Action Camera - GoPro Hero 11',
      price: '₹700/day',
      distance: '2.3 km',
      owner: 'Rohit Verma',
      ownerAvatar: 'https://i.pravatar.cc/150?img=25',
      image: 'assets/images/camera.jpg',
      rating: 4.2,
      reviews: 33,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Custom Furniture Carving Service',
      price: '₹900/day',
      distance: '3.1 km',
      owner: 'Manoj Deshmukh',
      ownerAvatar: 'https://i.pravatar.cc/150?img=28',
      image: 'assets/images/carpainter.jpg',
      rating: 4.8,
      reviews: 102,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Pediatric Wheelchair',
      price: '₹250/day',
      distance: '0.9 km',
      owner: 'Anjali Mehta',
      ownerAvatar: 'https://i.pravatar.cc/150?img=30',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.0,
      reviews: 19,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Camera Tripod & Lighting Kit',
      price: '₹300/day',
      distance: '1.6 km',
      owner: 'Vikram Singh',
      ownerAvatar: 'https://i.pravatar.cc/150?img=32',
      image: 'assets/images/camera.jpg',
      rating: 3.8,
      reviews: 12,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Wood Furniture Repair Toolkit',
      price: '₹400/day',
      distance: '2.5 km',
      owner: 'Ganesh Yadav',
      ownerAvatar: 'https://i.pravatar.cc/150?img=35',
      image: 'assets/images/carpainter.jpg',
      rating: 4.3,
      reviews: 40,
      isFeatured: true,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Heavy Duty Wheelchair',
      price: '₹280/day',
      distance: '1.4 km',
      owner: 'Sunita Rane',
      ownerAvatar: 'https://i.pravatar.cc/150?img=38',
      image: 'assets/images/wheelchair.jpg',
      rating: 4.5,
      reviews: 55,
      isFeatured: false,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Canon 90D DSLR Bundle',
      price: '₹1600/day',
      distance: '3.8 km',
      owner: 'Arjun Malhotra',
      ownerAvatar: 'https://i.pravatar.cc/150?img=40',
      image: 'assets/images/camera.jpg',
      rating: 4.6,
      reviews: 66,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Wooden Handicraft Making Kit',
      price: '₹500/day',
      distance: '2.9 km',
      owner: 'Deepak Chavan',
      ownerAvatar: 'https://i.pravatar.cc/150?img=42',
      image: 'assets/images/carpainter.jpg',
      rating: 4.1,
      reviews: 28,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Compact Folding Wheelchair',
      price: '₹190/day',
      distance: '0.6 km',
      owner: 'Meera Iyer',
      ownerAvatar: 'https://i.pravatar.cc/150?img=45',
      image: 'assets/images/wheelchair.jpg',
      rating: 3.9,
      reviews: 9,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Studio Camera & Backdrop Set',
      price: '₹1300/day',
      distance: '3.3 km',
      owner: 'Sameer Qureshi',
      ownerAvatar: 'https://i.pravatar.cc/150?img=48',
      image: 'assets/images/camera.jpg',
      rating: 4.4,
      reviews: 51,
      isFeatured: true,
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
      'title': 'Easy Rentals\nQuick & Simple',
      'subtitle': 'Browse book and enjoy\nHassle-free experience',
      'image': 'assets/images/slide2-illustration.png',
    },
    {
      'title': 'Flexible Options\nyour',
      'subtitle': 'Daily,weekly,or monthly\nRent on your terms',
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
        child: Column(
          children: [
            // Fixed app bar — stays pinned, not part of scroll view
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth > 900 ? 900 : double.infinity,
                ),
                child: _buildCustomAppBar(theme, isDark, maxWidth, scale),
              ),
            ),

            // Scrollable content below the app bar
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth > 900 ? 900 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                builder: (context) =>
                                    const CategoryListScreen(),
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
          ],
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
                    isDark ? AppColors.baseWhite : AppColors.neutral700,
                  ).copyWith(fontSize: AppTypography.h4 * scale, height: 1.2),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  data['subtitle']!,
                  style:
                      AppTypography.bodySmall(
                        AppTypography.regular,
                        AppColors.neutral300,
                      ).copyWith(
                        fontSize: AppTypography.bodyMD * scale,
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
                            ? AppColors.darkSurface
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

    final double cardWidth = 320.0 * scale;
    final double cardHeight =
        176.0 * scale; // Taller card so rows aren't cramped
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
                color: isDark ? AppColors.darkSurface : AppColors.baseWhite,
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
                      height: double.infinity,
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
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: const Color(0xFFFFB800),
                                  size: 16 * scale,
                                ),
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
                                    : AppColors.baseWhite,
                                size: 16 * scale,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            _buildTag(
                              'Featured',
                              const Color(0xFF3B82F6),
                              AppColors.baseWhite,
                              scale,
                            ),
                            SizedBox(width: 8 * scale),
                            _buildTag(
                              'Top Choice',
                              const Color(0xFF1E1B4B),
                              AppColors.baseWhite,
                              scale,
                            ),
                          ],
                        ),

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
                          ],
                        ),

                        Text(
                          'Plumber',
                          style: AppTypography.bodyMedium(
                            AppTypography.medium,
                            isDark
                                ? AppColors.baseWhite.withOpacity(0.6)
                                : AppColors.neutral500,
                          ).copyWith(fontSize: 13 * scale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

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
                     AppTypography.medium,
                    isActive
                        ? AppColors.baseWhite
                        : (isDark
                              ? AppColors.neutral300
                              : AppColors.neutral300),
                  ).copyWith(fontSize: AppTypography.bodyMD * scale),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyAdsGrid(ThemeData theme, double width, double scale) {
    final filteredAds = _adsData.where((ad) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Featured') return ad.isFeatured;
      if (_selectedFilter == 'Top Choice') return ad.isTopChoice;
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
          crossAxisSpacing: 12 * scale,
          mainAxisSpacing: 14 * scale,
          childAspectRatio: 160 / 260,
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
                        ).chain(CurveTween(curve: Curves.easeOutCubic));
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
              false,
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
        color: isDark ? AppColors.darkSurface : AppColors.baseWhite,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseBlack.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio:
                1.15, 
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16 * scale),
                      topRight: Radius.circular(16 * scale),
                    ),
                    child: Container(
                      color: isDark
                          ? AppColors.neutral800
                          : AppColors.neutral100,
                      child: Image.asset(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.neutral400,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                if (isFeatured)
                  Positioned(
                    top: 12 * scale,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 3 * scale,
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
                          AppTypography.regular,
                          AppColors.baseWhite,
                        ).copyWith(fontSize: 11 * scale, letterSpacing: 0.3),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10 * scale,
                  right: 10 * scale,
                  child: Container(
                    padding: EdgeInsets.all(6 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.neutral900.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: AppColors.baseWhite,
                      size: 16 * scale,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                10 * scale,
                12 * scale,
                12 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Distance + Top Choice badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: isDark
                                ? AppColors.neutral400
                                : AppColors.neutral400,
                            size: 11 * scale,
                          ),
                          SizedBox(width: 3 * scale),
                          Text(
                            distance,
                            style: AppTypography.bodyExtraSmall(
                              AppTypography.light,
                              isDark
                                  ? AppColors.baseWhite.withOpacity(0.6)
                                  : AppColors.neutral500,
                            ).copyWith(fontSize: 12 * scale),
                          ),
                        ],
                      ),
                      if (isTopChoice)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3 * scale,
                            vertical: 1.5 * scale,
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
                              AppTypography.semibold,
                              AppColors.baseWhite,
                            ).copyWith(fontSize: 9.5 * scale),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8 * scale),

                  // Title
                  Text(
                    title,
                    style: AppTypography.bodyMedium(
                      AppTypography.medium,
                      isDark ? AppColors.baseWhite : AppColors.neutral700,
                    ).copyWith(fontSize: 12 * scale, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5 * scale),

                  // Price — bold, standout like the reference
                  Text(
                    price,
                    style: AppTypography.bodyLarge(
                      AppTypography.bold,
                      isDark ? AppColors.baseWhite : AppColors.neutral900,
                    ).copyWith(fontSize: 14 * scale, height: 1.0),
                  ),
                  SizedBox(height: 5 * scale),

                  // Owner
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11 * scale,
                        backgroundImage: NetworkImage(avatarUrl),
                      ),
                      SizedBox(width: 5 * scale),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                owner,
                                style: AppTypography.bodyExtraSmall(
                                  AppTypography.medium,
                                  isDark
                                      ? AppColors.baseWhite
                                      : AppColors.neutral900,
                                ).copyWith(fontSize: 12.5 * scale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isVerified) ...[
                              SizedBox(width: 4 * scale),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 12 * scale,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5 * scale),

                  // Rating
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: const Color(0xFFFFB800),
                        size: 11 * scale,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        rating,
                        style: AppTypography.bodyExtraSmall(
                          AppTypography.semibold,
                          isDark
                              ? AppColors.baseWhite.withOpacity(0.9)
                              : AppColors.neutral700,
                        ).copyWith(fontSize: 11 * scale),
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        '($reviews)',
                        style: AppTypography.bodyExtraSmall(
                          AppTypography.regular,
                          isDark
                              ? AppColors.baseWhite.withOpacity(0.5)
                              : AppColors.neutral400,
                        ).copyWith(fontSize: 11 * scale),
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
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 1 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4 * scale),
      ),
      child: Text(
        text,
        style: AppTypography.bodyExtraSmall(AppTypography.regular, textColor),
      ),
    );
  }
}
