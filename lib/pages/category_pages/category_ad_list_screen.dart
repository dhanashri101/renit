import 'package:flutter/material.dart';
import 'package:rentit24/pages/product_details_screen.dart';
import 'package:rentit24/pages/chat_screens/profile.dart'; // for AdItem

class CategoryAdListScreen extends StatefulWidget {
  const CategoryAdListScreen({super.key});

  @override
  State<CategoryAdListScreen> createState() => _CategoryAdListScreenState();
}

class _CategoryAdListScreenState extends State<CategoryAdListScreen> {
  String _selectedFilter = 'All';
  int _sortOption = 0;
  final List<String> _filters = ['All', 'Top rated', 'Featured', 'Top Choice'];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<AdItem> _adsData = [
    AdItem(
      title: 'Go Pro 12',
      price: '₹1300/day',
      distance: '2.5 km',
      owner: 'Wade Warren',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 3.5,
      reviews: 110,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Canon EOS R6',
      price: '₹2000/day',
      distance: '3 km',
      owner: 'Cody Fisher',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 5.0,
      reviews: 48,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Nikon DSLR with lense',
      price: '₹1200/day',
      distance: '0.5 km',
      owner: 'Robert Fox',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.0,
      reviews: 22,
      isFeatured: false,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Canon EOS M50 Mark II...',
      price: '₹1500/day',
      distance: '2 km',
      owner: 'Hamza',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.0,
      reviews: 10,
      isFeatured: false,
      isTopChoice: false,
    ),
    AdItem(
      title: 'Sony A7 III Body Only',
      price: '₹1800/day',
      distance: '1.2 km',
      owner: 'Arjun Mehta',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.8,
      reviews: 85,
      isFeatured: true,
      isTopChoice: false,
    ),
    AdItem(
      title: 'DJI Mavic 3 Drone',
      price: '₹3500/day',
      distance: '4.5 km',
      owner: 'Priya Singh',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.9,
      reviews: 132,
      isFeatured: true,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Insta360 X3 Action Cam',
      price: '₹900/day',
      distance: '0.8 km',
      owner: 'Rahul K',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.5,
      reviews: 41,
      isFeatured: false,
      isTopChoice: true,
    ),
    AdItem(
      title: 'Godox Studio Light Kit',
      price: '₹600/day',
      distance: '3.2 km',
      owner: 'Wade Warren',
      ownerAvatar: 'https://i.pravatar.cc/100',
      image: 'assets/images/camera.jpg',
      rating: 4.2,
      reviews: 18,
      isFeatured: false,
      isTopChoice: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdItem> get _filteredAds {
    if (_searchQuery.isEmpty) return _adsData;
    return _adsData
        .where((ad) => ad.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showSortBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [
      'Relevance',
      'Popularity',
      'Price -- Low to High',
      'Price -- High to Low',
      'Newest First',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Text(
                      'SORT BY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...List.generate(options.length, (index) {
                    return RadioListTile<int>(
                      activeColor: Theme.of(context).primaryColor,
                      title: Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: _sortOption == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      value: index,
                      groupValue: _sortOption,
                      onChanged: (int? value) {
                        setModalState(() => _sortOption = value!);
                        setState(() => _sortOption = value!.toInt());
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.pop(context);
                        });
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final currentAds = _filteredAds;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopSearch(theme, isDark),
            _buildFilterChips(theme, isDark),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: _searchQuery.isEmpty
                          ? 'Showing all results '
                          : 'Showing results for ',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14,
                      ),
                      children: [
                        if (_searchQuery.isNotEmpty)
                          TextSpan(
                            text: '"$_searchQuery"',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[850]
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${currentAds.length} ads',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: _buildGrid(currentAds, theme, isDark),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActions(theme, isDark),
    );
  }

  Widget _buildTopSearch(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                onPressed: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.search, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.primaryColor
                    : (isDark ? Colors.grey[850] : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  if (filter == 'Top rated') ...[
                    Icon(
                      Icons.star,
                      size: 14,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[700]),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
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

  Widget _buildGrid(
    List<AdItem> ads,
    ThemeData theme,
    bool isDark,
  ) {
    if (ads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No items found matching "$_searchQuery"',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          return _buildPremiumAdCard(ad, theme, isDark);
        },
      ),
    );
  }

  Widget _buildPremiumAdCard(
    AdItem ad,
    ThemeData theme,
    bool isDark,
  ) {
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  ad.image,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 110,
                    color: Colors.grey[800],
                    child: const Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                ),
              ),
              if (ad.isFeatured)
                Positioned(
                  top: 12,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B58E4),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
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
              padding: const EdgeInsets.all(10.0),
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
                            color: Colors.grey[500],
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ad.distance,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      if (ad.isTopChoice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]
                                : const Color(0xFF090726),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Top Choice',
                            style: TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ad.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ad.price,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: const NetworkImage(
                              'https://i.pravatar.cc/100',
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ad.owner,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        ad.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (${ad.reviews})',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBottomActions(ThemeData theme, bool isDark) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _showSortBottomSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort,
                    color: isDark ? Colors.white : Colors.black,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey[300]),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const FilterScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutQuart;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tune,
                    color: isDark ? Colors.white : Colors.black,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(500, 1500);
  String _selectedBrand = 'Canon';
  String _selectedColor = 'Black';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
          'Filters',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Price', isDark),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
              thumbColor: theme.primaryColor,
              overlayColor: theme.primaryColor.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: RangeSlider(
              values: _priceRange,
              min: 0,
              max: 5000,
              divisions: 50,
              onChanged: (RangeValues values) {
                setState(() => _priceRange = values);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${_priceRange.start.toInt()}',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                Text(
                  '₹${_priceRange.end.toInt()}',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Brand', isDark),
          const SizedBox(height: 12),
          _buildDropdownMenu(
            value: _selectedBrand,
            items: ['Canon', 'Nikon', 'Sony', 'GoPro'],
            isDark: isDark,
            onChanged: (val) => setState(() => _selectedBrand = val!),
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Color', isDark),
          const SizedBox(height: 12),
          _buildDropdownMenu(
            value: _selectedColor,
            items: ['Black', 'Silver', 'White', 'Red'],
            isDark: isDark,
            onChanged: (val) => setState(() => _selectedColor = val!),
          ),
          const SizedBox(height: 32),

          _buildSectionTitle('Availability', isDark),
          const SizedBox(height: 12),
          _buildProperCalendar(isDark, surfaceColor),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _priceRange = const RangeValues(0, 5000);
                    _selectedBrand = 'Canon';
                    _selectedColor = 'Black';
                    _selectedDate = DateTime.now();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildDropdownMenu({
    required String value,
    required List<String> items,
    required bool isDark,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildProperCalendar(bool isDark, Color surfaceColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[200]!,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: const Color(0xFF2A2A2A),
                  onSurface: Colors.white,
                )
              : ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
        ),
        child: CalendarDatePicker(
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onDateChanged: (DateTime newDate) {
            setState(() {
              _selectedDate = newDate;
            });
          },
        ),
      ),
    );
  }
}