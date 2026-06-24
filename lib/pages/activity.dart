import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';

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

    final bgColor = theme.scaffoldBackgroundColor;
    final surfaceColor = theme.colorScheme.surface;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppTheme.darkSurface
            : AppTheme.lightBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
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
              Container(
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
                          if (selected)
                            setState(() => _selectedFilterIndex = index);
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
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textSecondary = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ad.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
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
                          Text(
                            'Posted on ${ad.date}',
                            style: TextStyle(
                              fontSize: 10,
                              color: textSecondary,
                            ),
                          ),
                          _buildMenuButton(context, isDark),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatusBadge(ad.status, isDark),
                          if (ad.status == AdStatus.inactive &&
                              ad.type == AdType.product) ...[
                            const SizedBox(width: 4),
                            _buildInactiveBadge(isDark),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (ad.category.isNotEmpty)
                        Text(
                          ad.category,
                          style: TextStyle(fontSize: 10, color: textSecondary),
                        ),
                      Text(
                        ad.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ad.price,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (ad.rating != null) ...[
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${ad.rating} ',
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '(${ad.saves})',
                              style: TextStyle(
                                fontSize: 10,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Icon(
                              Icons.star_border,
                              color: Colors.grey,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '0 ',
                              style: TextStyle(
                                fontSize: 10,
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '(0)',
                              style: TextStyle(
                                fontSize: 10,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Icon(
                            Icons.visibility_outlined,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Views ',
                            style: TextStyle(
                              fontSize: 10,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '(${ad.views})',
                            style: TextStyle(
                              fontSize: 10,
                              color: textSecondary,
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

          if (ad.status == AdStatus.rejected && ad.rejectionReason != null)
            _buildRejectionSection(ad.rejectionReason!, isDark),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AdStatus status, bool isDark) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case AdStatus.pending:
        bgColor = ActivityColors.pendingBg;
        textColor = ActivityColors.pendingText;
        text = 'Pending';
        break;
      case AdStatus.approved:
      case AdStatus.inactive:
        bgColor = ActivityColors.approvedBg;
        textColor = ActivityColors.approvedText;
        text = 'Approved';
        break;
      case AdStatus.rejected:
        bgColor = ActivityColors.rejectedBg;
        textColor = ActivityColors.rejectedText;
        text = 'Rejected';
        break;
    }

    if (isDark) bgColor = bgColor.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInactiveBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : ActivityColors.inactiveBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Inactive',
        style: TextStyle(
          color: isDark ? Colors.grey[300] : ActivityColors.inactiveText,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: 24,
      height: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz,
          size: 16,
          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isDark
              ? const Color(0xFF3F1D1D)
              : const Color(0xFFFEE2E2).withOpacity(0.5),
          child: Text(
            reason,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFFCA5A5)
                  : ActivityColors.rejectedText,
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
