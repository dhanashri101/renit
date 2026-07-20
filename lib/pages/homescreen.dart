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
import 'package:rentit24/pages/wishlist_screen.dart';
import 'package:rentit24/pages/notifications_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:rentit24/services/category_services.dart';
import 'package:rentit24/services/banner_service.dart';
import 'package:rentit24/services/dashboard_service.dart';
import 'package:rentit24/services/listing_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 1000);
  Timer? _timer;
  Timer? _hintTimer;
  int _currentPage = 0;
  final CategoryService _categoryService = CategoryService();
  final ListingService _listingService = ListingService();
  final BannerService _bannerService = BannerService();
  final DashboardService _dashboardService = DashboardService();
  String _currentLocationText = 'Getting location...';
  bool _isLoadingLocation = false;
  bool _isLoadingHomeData = true;

  late final AnimationController _skeletonController;
  late final Animation<double> _skeletonAnimation;

  final Geocoding _geocoding = Geocoding();
  late Future<List<CategoryModel>> _categoriesFuture;
  Position? _currentPosition;

  final Map<String, Future<String>> _professionalDistanceCache = {};
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

  final List<AdItem> _adsData = <AdItem>[];
  final List<AdItem> _professionalsData = <AdItem>[];

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

  Future<void> _loadHomeData({bool showSkeleton = true}) async {
    if (showSkeleton && mounted) {
      setState(() {
        _isLoadingHomeData = true;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        _listingService.getFeed(),
        _bannerService.getHomeBanners(),
        _dashboardService.getTopProfessionals(limit: 10),
      ]);

      if (!mounted) return;

      final listings = results[0] as List<dynamic>;
      final banners = results[1] as List<dynamic>;
      final professionals = results[2] as List<dynamic>;

      setState(() {
        _adsData
          ..clear()
          ..addAll(listings.map((item) => AdItem.fromListing(item)));
        _professionalsData
          ..clear()
          ..addAll(professionals.map((item) => AdItem.fromListing(item)));

        if (banners.isNotEmpty) {
          _bannerData
            ..clear()
            ..addAll(
              banners.map<Map<String, String>>(
                (item) => <String, String>{
                  'title': item.title,
                  'subtitle': item.subtitle,
                  'image': item.imageUrl,
                },
              ),
            );
        }
        _currentPage = 0;
      });
    } catch (error, stackTrace) {
      debugPrint('Home data error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (showSkeleton && mounted) {
        setState(() {
          _isLoadingHomeData = false;
        });
      }
    }
  }

  Future<void> _loadCurrentLocation() async {
    if (_isLoadingLocation) return;

    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
        _currentLocationText = 'Getting location...';
      });
    }

    try {
      // Step 1: Check whether phone location/GPS is enabled.
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      debugPrint('LOCATION SERVICE ENABLED: $serviceEnabled');

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          _currentLocationText = 'Turn on location';
        });

        return;
      }

      // Step 2: Check permission.
      LocationPermission permission = await Geolocator.checkPermission();

      debugPrint('LOCATION PERMISSION BEFORE: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      debugPrint('LOCATION PERMISSION AFTER: $permission');

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        setState(() {
          _currentLocationText = 'Location permission denied';
        });

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          _currentLocationText = 'Enable location permission';
        });

        return;
      }

      // Step 3: Try last known position first.
      Position? position = await Geolocator.getLastKnownPosition();

      debugPrint('LAST KNOWN POSITION: $position');

      // Step 4: Get fresh position if no saved position exists.
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      debugPrint(
        'CURRENT POSITION: '
        '${position.latitude}, ${position.longitude}',
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;

          _professionalDistanceCache.clear();
        });
      }
      try {
        final List<Placemark> placemarks = await _geocoding
            .placemarkFromCoordinates(
              position.latitude,
              position.longitude,
              locale: const Locale('en', 'IN'),
            );

        if (placemarks.isEmpty) {
          throw Exception('No address found');
        }

        final Placemark place = placemarks.first;

        debugPrint('NAME: ${place.name}');
        debugPrint('SUB LOCALITY: ${place.subLocality}');
        debugPrint('LOCALITY: ${place.locality}');
        debugPrint('SUB ADMINISTRATIVE AREA: ${place.subAdministrativeArea}');

        final String area = _firstNonEmpty([place.subLocality, place.name]);

        final String city = _firstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
        ]);

        final List<String> locationParts = [];

        if (area.isNotEmpty) {
          locationParts.add(area);
        }

        if (city.isNotEmpty && city.toLowerCase() != area.toLowerCase()) {
          locationParts.add(city);
        }

        if (!mounted) return;

        setState(() {
          _currentLocationText = locationParts.isEmpty
              ? 'Current location'
              : locationParts.join(', ');
        });
      } catch (geocodingError, stackTrace) {
        debugPrint('GEOCODING ERROR: $geocodingError');
        debugPrintStack(stackTrace: stackTrace);

        if (!mounted) return;

        // GPS worked, but address conversion failed.
        setState(() {
          _currentLocationText = 'Current location';
        });
      }
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('LOCATION TIMEOUT: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _currentLocationText = 'Location timed out';
      });
    } catch (error, stackTrace) {
      debugPrint('LOCATION ERROR TYPE: ${error.runtimeType}');
      debugPrint('LOCATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _currentLocationText = 'Location unavailable';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  String _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final String text = value?.trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  String _prepareProfessionalAddress(String address) {
    final String cleanedAddress = address.trim();
    final String lowerAddress = cleanedAddress.toLowerCase();

    if (lowerAddress.contains('india')) {
      return cleanedAddress;
    }

    return '$cleanedAddress, India';
  }

  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m away';
    }

    final double distanceInKilometers = distanceInMeters / 1000;

    if (distanceInKilometers < 10) {
      return '${distanceInKilometers.toStringAsFixed(1)} km away';
    }

    return '${distanceInKilometers.round()} km away';
  }

  Future<String> _calculateProfessionalDistance(String professionalLocation) {
    final Position? userPosition = _currentPosition;
    final String locationText = professionalLocation.trim();

    if (userPosition == null) {
      return Future<String>.value('Getting distance...');
    }

    if (locationText.isEmpty) {
      return Future<String>.value('Distance unavailable');
    }

    final String cacheKey = locationText.toLowerCase();

    return _professionalDistanceCache.putIfAbsent(cacheKey, () async {
      try {
        final String searchableAddress = _prepareProfessionalAddress(
          locationText,
        );

        debugPrint(
          'Finding coordinates for professional: '
          '$searchableAddress',
        );

        final List<Location> locations = await _geocoding.locationFromAddress(
          searchableAddress,
          locale: const Locale('en', 'IN'),
        );

        if (locations.isEmpty) {
          return locationText;
        }

        final Location professionalPosition = locations.first;

        debugPrint(
          'Professional coordinates: '
          '${professionalPosition.latitude}, '
          '${professionalPosition.longitude}',
        );

        final double distanceInMeters = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          professionalPosition.latitude,
          professionalPosition.longitude,
        );

        return _formatDistance(distanceInMeters);
      } catch (error, stackTrace) {
        debugPrint(
          'Professional distance calculation error '
          'for "$locationText": $error',
        );
        debugPrintStack(stackTrace: stackTrace);

        // Show the original location when distance cannot be calculated.
        return locationText;
      }
    });
  }


  Future<void> _refreshCategories() async {
    final Future<List<CategoryModel>> refreshedFuture =
        _categoryService.getCategories();

    if (mounted) {
      setState(() {
        _categoriesFuture = refreshedFuture;
      });
    }

    try {
      await refreshedFuture;
    } catch (error, stackTrace) {
      debugPrint('Category refresh error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _refreshHomeScreen() async {
    await Future.wait<void>([
      _loadHomeData(showSkeleton: false),
      _refreshCategories(),
      _loadCurrentLocation(),
    ]);
  }

  @override
  void initState() {
    super.initState();

    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _skeletonAnimation = CurvedAnimation(
      parent: _skeletonController,
      curve: Curves.easeInOut,
    );

    _categoriesFuture = _categoryService.getCategories();

    _loadCurrentLocation();
    _loadHomeData();

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients && _bannerData.isNotEmpty) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });

    _hintTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (!mounted) return;

      setState(() {
        _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hintTimer?.cancel();
    _skeletonController.dispose();
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
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth > 900 ? 900 : double.infinity,
                ),
                child: _buildCustomAppBar(theme, isDark, maxWidth, scale),
              ),
            ),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth > 900 ? 900 : double.infinity,
                  ),
                  child: RefreshIndicator(
                    onRefresh: _refreshHomeScreen,
                    color: theme.primaryColor,
                    backgroundColor: theme.colorScheme.surface,
                    displacement: 42 * scale,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          _buildProfessionalList(
                            theme,
                            context,
                            maxWidth,
                            scale,
                          ),
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
            ),
          ],
        ),
      ),
    );
  }

  void _retryCategories() {
    setState(() {
      _categoriesFuture = _categoryService.getCategories();
    });
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
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
                child: Image.asset(
                  'assets/images/rentit-logo.png',
                  height: 28,
                  width: 84,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (_currentLocationText == 'Enable location permission') {
                      await Geolocator.openAppSettings();
                      return;
                    }

                    if (_currentLocationText == 'Turn on location') {
                      await Geolocator.openLocationSettings();
                      return;
                    }

                    await _loadCurrentLocation();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          _currentLocationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyExtraSmall(
                            AppTypography.regular,
                            AppColors.baseWhite.withOpacity(0.7),
                          ).copyWith(fontSize: AppTypography.bodySM * scale),
                        ),
                      ),
                      SizedBox(width: 4 * scale),
                      Container(
                        padding: EdgeInsets.all(4 * scale),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.baseWhite.withOpacity(0.2),
                        ),
                        child: _isLoadingLocation
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: AppColors.baseWhite,
                                ),
                              )
                            : Icon(
                                Icons.location_on_outlined,
                                color: AppColors.baseWhite,
                                size: 16 * scale,
                              ),
                      ),
                    ],
                  ),
                ),
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
              _buildAppBarIcon(
                Icons.favorite_border,
                theme,
                isDark,
                scale,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                ),
              ),
              SizedBox(width: 12 * scale),
              _buildAppBarIcon(
                Icons.notifications_none,
                theme,
                isDark,
                scale,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
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


  Widget _buildSkeletonBox({
    required ThemeData theme,
    required double width,
    required double height,
    double borderRadius = 12,
  }) {
    final bool isDark = theme.brightness == Brightness.dark;
    final Color baseColor = isDark
        ? AppColors.neutral800
        : const Color(0xFFE3E8F0);
    final Color highlightColor = isDark
        ? AppColors.neutral700
        : const Color(0xFFF4F6FA);

    return AnimatedBuilder(
      animation: _skeletonAnimation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color.lerp(
              baseColor,
              highlightColor,
              _skeletonAnimation.value,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildBannerSkeleton(
    ThemeData theme,
    double width,
    double scale,
  ) {
    final double bannerHeight = (width * 0.46).clamp(150.0, 220.0);

    return Column(
      children: [
        Container(
          height: bannerHeight,
          margin: EdgeInsets.symmetric(horizontal: 16 * scale),
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24 * scale),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(
                      theme: theme,
                      width: 150 * scale,
                      height: 20 * scale,
                      borderRadius: 6 * scale,
                    ),
                    SizedBox(height: 10 * scale),
                    _buildSkeletonBox(
                      theme: theme,
                      width: 115 * scale,
                      height: 20 * scale,
                      borderRadius: 6 * scale,
                    ),
                    SizedBox(height: 16 * scale),
                    _buildSkeletonBox(
                      theme: theme,
                      width: 135 * scale,
                      height: 10 * scale,
                      borderRadius: 5 * scale,
                    ),
                    SizedBox(height: 8 * scale),
                    _buildSkeletonBox(
                      theme: theme,
                      width: 105 * scale,
                      height: 10 * scale,
                      borderRadius: 5 * scale,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                flex: 4,
                child: _buildSkeletonBox(
                  theme: theme,
                  width: double.infinity,
                  height: bannerHeight - (40 * scale),
                  borderRadius: 18 * scale,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            3,
            (int index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: _buildSkeletonBox(
                theme: theme,
                width: (index == 0 ? 24 : 8) * scale,
                height: 8 * scale,
                borderRadius: 4 * scale,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSkeleton(ThemeData theme, double scale) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
      itemBuilder: (_, __) {
        return SizedBox(
          width: 76 * scale,
          child: Column(
            children: [
              _buildSkeletonBox(
                theme: theme,
                width: 64 * scale,
                height: 64 * scale,
                borderRadius: 16 * scale,
              ),
              SizedBox(height: 9 * scale),
              _buildSkeletonBox(
                theme: theme,
                width: 58 * scale,
                height: 9 * scale,
                borderRadius: 5 * scale,
              ),
              SizedBox(height: 6 * scale),
              _buildSkeletonBox(
                theme: theme,
                width: 38 * scale,
                height: 8 * scale,
                borderRadius: 4 * scale,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionalSkeleton(ThemeData theme, double scale) {
    final double cardWidth = 320 * scale;
    final double cardHeight = 176 * scale;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: 2,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (_, __) {
          return Container(
            width: cardWidth,
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24 * scale),
            ),
            child: Row(
              children: [
                _buildSkeletonBox(
                  theme: theme,
                  width: 105 * scale,
                  height: double.infinity,
                  borderRadius: 16 * scale,
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonBox(
                        theme: theme,
                        width: 72 * scale,
                        height: 11 * scale,
                        borderRadius: 5 * scale,
                      ),
                      Row(
                        children: [
                          _buildSkeletonBox(
                            theme: theme,
                            width: 52 * scale,
                            height: 17 * scale,
                            borderRadius: 4 * scale,
                          ),
                          SizedBox(width: 8 * scale),
                          _buildSkeletonBox(
                            theme: theme,
                            width: 64 * scale,
                            height: 17 * scale,
                            borderRadius: 4 * scale,
                          ),
                        ],
                      ),
                      _buildSkeletonBox(
                        theme: theme,
                        width: 118 * scale,
                        height: 12 * scale,
                        borderRadius: 5 * scale,
                      ),
                      _buildSkeletonBox(
                        theme: theme,
                        width: 82 * scale,
                        height: 10 * scale,
                        borderRadius: 5 * scale,
                      ),
                      _buildSkeletonBox(
                        theme: theme,
                        width: 142 * scale,
                        height: 12 * scale,
                        borderRadius: 5 * scale,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyAdsSkeleton(
    ThemeData theme,
    double width,
    double scale,
  ) {
    final int columns = _gridColumns(width);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: columns * 2,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12 * scale,
          mainAxisSpacing: 14 * scale,
          childAspectRatio: 160 / 260,
        ),
        itemBuilder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16 * scale),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: _buildSkeletonBox(
                    theme: theme,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 16 * scale,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSkeletonBox(
                          theme: theme,
                          width: 66 * scale,
                          height: 9 * scale,
                          borderRadius: 4 * scale,
                        ),
                        _buildSkeletonBox(
                          theme: theme,
                          width: double.infinity,
                          height: 11 * scale,
                          borderRadius: 5 * scale,
                        ),
                        _buildSkeletonBox(
                          theme: theme,
                          width: 74 * scale,
                          height: 13 * scale,
                          borderRadius: 5 * scale,
                        ),
                        _buildSkeletonBox(
                          theme: theme,
                          width: 96 * scale,
                          height: 10 * scale,
                          borderRadius: 5 * scale,
                        ),
                        _buildSkeletonBox(
                          theme: theme,
                          width: 58 * scale,
                          height: 9 * scale,
                          borderRadius: 4 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerCarousel(
    ThemeData theme,
    bool isDark,
    double width,
    double scale,
  ) {
    if (_isLoadingHomeData) {
      return _buildBannerSkeleton(theme, width, scale);
    }

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
            child: _buildMediaImage(
              data['image'] ?? 'assets/images/slide1-illustration.png',
              fit: BoxFit.contain,
            ),
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
    final bool isDark = theme.brightness == Brightness.dark;

    final double itemWidth = 76.0 * scale;

    return SizedBox(
      height: 125 * scale,
      child: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<CategoryModel>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildCategoriesSkeleton(theme, scale);
              }

              if (snapshot.hasError) {
                final String errorMessage = snapshot.error
                    .toString()
                    .replaceFirst('Exception: ', '');

                debugPrint('FutureBuilder category error: $errorMessage');

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                          size: 22 * scale,
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11 * scale,
                            color: isDark
                                ? AppColors.baseWhite
                                : AppColors.neutral700,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _categoriesFuture = _categoryService
                                  .getCategories();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<CategoryModel> categories =
                  (snapshot.data ?? <CategoryModel>[])
                      .where(
                        (CategoryModel category) =>
                            category.isActive &&
                            category.name.trim().isNotEmpty,
                      )
                      .toList();

              if (categories.isEmpty) {
                return Center(
                  child: Text(
                    'No active categories available',
                    style: AppTypography.bodySmall(
                      AppTypography.medium,
                      isDark
                          ? AppColors.baseWhite.withOpacity(0.7)
                          : AppColors.neutral600,
                    ).copyWith(fontSize: 13 * scale),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                itemCount: categories.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(width: 8 * scale);
                },
                itemBuilder: (BuildContext context, int index) {
                  final CategoryModel category = categories[index];

                  return SizedBox(
                    width: itemWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16 * scale),
                      onTap: () {
                        debugPrint(
                          'Selected category: '
                          '${category.id} - ${category.name}',
                        );

                        // Add category navigation here.
                      },
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
                                    isDark ? 0.30 : 0.04,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: 40 * scale,
                              height: 40 * scale,
                              child: Icon(
                                _getCategoryIcon(category.type),
                                color: AppColors.primary500,
                                size: 26 * scale,
                              ),
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            category.name,
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
                    ),
                  );
                },
              );
            },
      ),
    );
  }

  IconData _getCategoryIcon(String type) {
    switch (type.trim().toLowerCase()) {
      case 'service':
      case 'professional':
        return Icons.home_repair_service_outlined;

      case 'product':
      case 'item':
      case 'rental':
        return Icons.inventory_2_outlined;

      case 'vehicle':
      case 'transport':
        return Icons.directions_car_outlined;

      case 'property':
      case 'real estate':
        return Icons.apartment_outlined;

      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildProfessionalList(
    ThemeData theme,
    BuildContext context,
    double width,
    double scale,
  ) {
    if (_isLoadingHomeData) {
      return _buildProfessionalSkeleton(theme, scale);
    }

    final isDark = theme.brightness == Brightness.dark;

    final double cardWidth = 320.0 * scale;
    final double cardHeight = 176.0 * scale;
    final double padding = 12.0 * scale;

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: _professionalsData.length,
        separatorBuilder: (context, index) =>
            SizedBox(width: 16 * scale), // Slightly wider gap
        itemBuilder: (context, index) {
          final ad = _professionalsData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsScreen(adData: ad),
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
                    child: SizedBox(
                      width: 105 * scale,
                      height: double.infinity,
                      child: _buildMediaImage(ad.image, fit: BoxFit.cover),
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
                                  ad.rating.toStringAsFixed(1),
                                  style: AppTypography.bodySmall(
                                    AppTypography.bold,
                                    isDark
                                        ? AppColors.baseWhite
                                        : AppColors.neutral900,
                                  ).copyWith(fontSize: 13 * scale),
                                ),
                                SizedBox(width: 4 * scale),
                                Text(
                                  '(${ad.reviews})',
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
                              backgroundColor: AppColors.neutral200,
                              backgroundImage: ad.ownerAvatar.startsWith('http')
                                  ? NetworkImage(ad.ownerAvatar)
                                  : null,
                              child: ad.ownerAvatar.isEmpty
                                  ? Icon(Icons.person, size: 12 * scale)
                                  : null,
                            ),
                            SizedBox(width: 8 * scale),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      ad.owner,
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
                          ad.category.isEmpty ? ad.listingType : ad.category,
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
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: isDark
                                        ? AppColors.baseWhite.withOpacity(0.5)
                                        : AppColors.neutral500,
                                    size: 14 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Flexible(
                                    child: _buildProfessionalDistance(
                                      professionalLocation: ad.distance,
                                      isDark: isDark,
                                      scale: scale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              ad.price,
                              style: AppTypography.headingStyle(
                                AppTypography.h6,
                                isDark
                                    ? AppColors.baseWhite
                                    : AppColors.neutral900,
                              ).copyWith(fontSize: 16 * scale, height: 1),
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
    if (_isLoadingHomeData) {
      return _buildNearbyAdsSkeleton(theme, width, scale);
    }

    final filteredAds = _adsData.where((ad) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Featured') return ad.isFeatured;
      if (_selectedFilter == 'Top Choice') return ad.isTopChoice;
      if (_selectedFilter == 'Verified') return ad.isVerified;
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
              ad.isVerified,
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
            aspectRatio: 1.15,
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
                      child: _buildMediaImage(imgUrl, fit: BoxFit.cover),
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
                        backgroundImage: avatarUrl.startsWith('http')
                            ? NetworkImage(avatarUrl)
                            : null,
                        child: avatarUrl.isEmpty
                            ? Icon(Icons.person, size: 12 * scale)
                            : null,
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

  Widget _buildMediaImage(String source, {BoxFit fit = BoxFit.cover}) {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.neutral400,
          ),
        ),
      );
    }

    return Image.asset(
      source.isEmpty ? 'assets/images/carpainter.jpg' : source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.neutral400,
        ),
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

  Widget _buildProfessionalDistance({
    required String professionalLocation,
    required bool isDark,
    required double scale,
  }) {
    if (_currentPosition == null) {
      return Text(
        _isLoadingLocation ? 'Getting distance...' : professionalLocation,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall(
          AppTypography.regular,
          isDark ? AppColors.baseWhite.withOpacity(0.5) : AppColors.neutral500,
        ).copyWith(fontSize: 12 * scale),
      );
    }

    return FutureBuilder<String>(
      future: _calculateProfessionalDistance(professionalLocation),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        String distanceText = professionalLocation;

        if (snapshot.connectionState == ConnectionState.waiting) {
          distanceText = 'Calculating...';
        } else if (snapshot.hasData) {
          distanceText = snapshot.data!;
        }

        return Text(
          distanceText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall(
            AppTypography.regular,
            isDark
                ? AppColors.baseWhite.withOpacity(0.5)
                : AppColors.neutral500,
          ).copyWith(fontSize: 12 * scale),
        );
      },
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
