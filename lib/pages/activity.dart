import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/wrapper/navbar.dart';

class MyActivityPage extends StatefulWidget {
  const MyActivityPage({super.key});

  @override
  State<MyActivityPage> createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'All',
    'Active Ads',
    'Inactive Ads',
    'Pending Ads',
    'Moderated Ads',
  ];
  final List<int> _filterCounts = [4, 1, 1, 1, 1];

  final List<AdModel> _allAds = [
    AdModel(
      title: 'Physio Therapy',
      category: 'Doctor',
      date: '28 Mar 2026',
      price: '₹700/Visit',
      views: 0,
      saves: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=200',
      status: AdStatus.pending,
      type: AdType.service,
    ),
    AdModel(
      title: 'Treadmill on rent',
      category: '',
      date: '15 Mar 2026',
      price: '₹200/day',
      views: 0,
      saves: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
      status: AdStatus.rejected,
      rejectionReason:
          'Remove phone number or unrelated text from AD Description that doesn\'t match the product or service',
      type: AdType.product,
    ),
    AdModel(
      title: 'Emergency treatment visit',
      category: 'Doctor',
      date: '10 Oct 2025',
      price: '₹500/visit',
      views: 542,
      saves: 122,
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=200',
      status: AdStatus.approved,
      type: AdType.service,
    ),
    AdModel(
      title: 'Wheelchair for rent',
      category: '',
      date: '21 Sept 2025',
      price: '₹200/day',
      views: 440,
      saves: 52,
      rating: 4.2,
      imageUrl:
          'https://images.unsplash.com/photo-1581090122319-8fab9528eaaa?w=200',
      status: AdStatus.inactive,
      type: AdType.product,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  List<AdModel> _getFilteredAds(int mainTabIndex, int subFilterIndex) {
    List<AdModel> filtered = _allAds;

    if (mainTabIndex == 1) {
      filtered = filtered.where((ad) => ad.type == AdType.product).toList();
    } else if (mainTabIndex == 2) {
      filtered = filtered.where((ad) => ad.type == AdType.service).toList();
    }

    switch (subFilterIndex) {
      case 1:
        filtered = filtered
            .where((ad) => ad.status == AdStatus.approved)
            .toList();
        break;
      case 2:
        filtered = filtered
            .where((ad) => ad.status == AdStatus.inactive)
            .toList();
        break;
      case 3:
        filtered = filtered
            .where((ad) => ad.status == AdStatus.pending)
            .toList();
        break;
      case 4:
        filtered = filtered
            .where((ad) => ad.status == AdStatus.rejected)
            .toList();
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.darkSurface
            : const Color(0xFFEFF6FF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(
   
  ),
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationWrapper()),
            (route) => false,
          );
        },
      ),
        titleSpacing: 0,
        title: Text(
          'My Activity',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TabBar(
                  controller: _mainTabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 4.0,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  labelColor: isDark ? Colors.white : const Color(0xFF1F2937),
                  unselectedLabelColor: isDark
                      ? Colors.grey[500]
                      : const Color(0xFF9CA3AF),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text('All'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text('Products'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text('Services'),
                      ),
                    ),
                  ],
                  onTap: (index) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Text(
                          '${_filters[index]} (${_filterCounts[index]})',
                          style: TextStyle(
                            color: isSelected ? Colors.white : textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFilterIndex = index);
                          }
                        },
                        backgroundColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.transparent,
                        selectedColor: AppTheme.primaryBlue,
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : (isDark
                                  ? Colors.transparent
                                  : const Color(0xFFE5E7EB)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _buildAdList(context, isDark, 0),
          _buildAdList(context, isDark, 1),
          _buildAdList(context, isDark, 2),
        ],
      ),
    );
  }

  Widget _buildAdList(BuildContext context, bool isDark, int mainTabIndex) {
    final ads = _getFilteredAds(mainTabIndex, _selectedFilterIndex);

    if (ads.isEmpty) {
      return Center(
        child: Text(
          'No ads found',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        return AdCard(ad: ads[index], isDark: isDark);
      },
    );
  }
}

enum AdStatus { pending, approved, rejected, inactive }

enum AdType { product, service }

class AdModel {
  final String title;
  final String category;
  final String date;
  final String price;
  final int views;
  final int saves;
  final double? rating;
  final String imageUrl;
  final AdStatus status;
  final String? rejectionReason;
  final AdType type;

  AdModel({
    required this.title,
    required this.category,
    required this.date,
    required this.price,
    required this.views,
    required this.saves,
    this.rating,
    required this.imageUrl,
    required this.status,
    this.rejectionReason,
    required this.type,
  });
}

class AdCard extends StatelessWidget {
  final AdModel ad;
  final bool isDark;

  const AdCard({super.key, required this.ad, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFBAB9B9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Image.network(
                  ad.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Posted on ${ad.date}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : const Color(0xFF090726),
                              fontSize: 10,
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w300,
                              height: 1.20,
                              letterSpacing: 0.20,
                            ),
                          ),
                          _buildMenuButton(context, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusBadge(ad.status),
                          if (ad.status == AdStatus.inactive) ...[
                            const SizedBox(width: 4),
                            _buildInactiveBadge(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (ad.category.isNotEmpty)
                      SizedBox(
                        width: 196,
                        child: Text(
                          ad.category,
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey[500]
                                : const Color(0x66090726),
                            fontSize: 10,
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w300,
                            height: 1.20,
                            letterSpacing: 0.20,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 196,
                      child: Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF2F314D),
                          fontSize: 12,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w400,
                          height: 1.42,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 196,
                      child: Text(
                        ad.price,
                        style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF090726),
                          fontSize: 14,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          height: 1.43,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFF59E0B),
                                size: 10,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${ad.rating ?? 0}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : const Color(0xFF2F314D),
                                  fontSize: 11,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  height: 1.18,
                                ),
                              ),
                              Text(
                                ' (${ad.saves})',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : const Color(0x66090726),
                                  fontSize: 10,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: 0.20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 10,
                                color: isDark
                                    ? Colors.grey[400]
                                    : const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Views',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : const Color(0xFF2F314D),
                                  fontSize: 11,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  height: 1.18,
                                ),
                              ),
                              Text(
                                ' (${ad.views})',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[500]
                                      : const Color(0x66090726),
                                  fontSize: 10,
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                  letterSpacing: 0.20,
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
            ],
          ),
          if (ad.status == AdStatus.rejected && ad.rejectionReason != null)
            _buildRejectionSection(ad.rejectionReason!, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AdStatus status) {
    Color statusBgColor;
    String statusText;

    switch (status) {
      case AdStatus.pending:
        statusBgColor = const Color(0xFFEF6C00);
        statusText = 'Pending';
        break;
      case AdStatus.approved:
        statusBgColor = const Color(0xFF2E7D32);
        statusText = 'Approved';
        break;
      case AdStatus.rejected:
        statusBgColor = const Color(0xFFD32F2F);
        statusText = 'Rejected';
        break;
      case AdStatus.inactive:
        statusBgColor = const Color(0xFF2E7D32);
        statusText = 'Approved';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: ShapeDecoration(
        color: statusBgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          height: 1.20,
          letterSpacing: 0.20,
        ),
      ),
    );
  }

  Widget _buildInactiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFF8E8E93),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
      child: const Text(
        'Inactive',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w400,
          height: 1.20,
          letterSpacing: 0.20,
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: 16,
      height: 16,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.grey[600]! : const Color(0xFF090726),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.more_horiz,
              size: 10,
              color: isDark ? Colors.grey[400] : const Color(0xFF090726),
            ),
          ),
        ),
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'edit',
            child: Text('Edit', style: TextStyle(fontSize: 14)),
          ),
          const PopupMenuItem<String>(
            value: 'inactive',
            child: Text('Inactive', style: TextStyle(fontSize: 14)),
          ),
          const PopupMenuItem<String>(
            value: 'remove',
            child: Text('Remove', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionSection(String reason, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFCE8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reason,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFF374151),
                fontSize: 11,
                fontFamily: 'Outfit',
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edit Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
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