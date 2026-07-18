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
  late final TabController _mainTabController;

  int _selectedFilterIndex = 0;
  int _currentMainTabIndex = 0;

  final List<String> _filters = const [
    'All',
    'Active Ads',
    'Inactive Ads',
    'Pending Ads',
    'Moderated Ads',
  ];

  final List<AdModel> _allAds = const [
    AdModel(
      title: 'Physio Therapy',
      category: 'Doctor',
      date: '28 Mar 2026',
      price: '₹700/Visit',
      views: 0,
      saves: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400',
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
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400',
      status: AdStatus.rejected,
      rejectionReason:
          'Remove phone number or unrelated text from AD Description that does not match the product or service.',
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
          'https://images.unsplash.com/photo-1584982751601-97dcc096659c?w=400',
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
          'https://images.unsplash.com/photo-1581090122319-8fab9528eaaa?w=400',
      status: AdStatus.inactive,
      type: AdType.product,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _mainTabController.addListener(_handleMainTabChange);
  }

  void _handleMainTabChange() {
    if (_currentMainTabIndex == _mainTabController.index) return;

    setState(() {
      _currentMainTabIndex = _mainTabController.index;
    });
  }

  @override
  void dispose() {
    _mainTabController
      ..removeListener(_handleMainTabChange)
      ..dispose();
    super.dispose();
  }

  List<AdModel> _getFilteredAds(int mainTabIndex, int filterIndex) {
    Iterable<AdModel> filtered = _allAds;

    if (mainTabIndex == 1) {
      filtered = filtered.where((ad) => ad.type == AdType.product);
    } else if (mainTabIndex == 2) {
      filtered = filtered.where((ad) => ad.type == AdType.service);
    }

    switch (filterIndex) {
      case 1:
        filtered = filtered.where((ad) => ad.status == AdStatus.approved);
        break;
      case 2:
        filtered = filtered.where((ad) => ad.status == AdStatus.inactive);
        break;
      case 3:
        filtered = filtered.where((ad) => ad.status == AdStatus.pending);
        break;
      case 4:
        filtered = filtered.where((ad) => ad.status == AdStatus.rejected);
        break;
    }

    return filtered.toList();
  }

  int _filterCount(int filterIndex) {
    return _getFilteredAds(_currentMainTabIndex, filterIndex).length;
  }

  void _goBack() {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const NavigationWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _goBack,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: Text(
          'My Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: AppTypography.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              TabBar(
                controller: _mainTabController,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 4,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                ),
                labelColor: colorScheme.onSurface,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppTypography.semibold,
                ),
                unselectedLabelStyle: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppTypography.medium,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Products'),
                  Tab(text: 'Services'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedFilterIndex == index;

                    return ChoiceChip(
                      showCheckmark: false,
                      selected: isSelected,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _selectedFilterIndex = index);
                      },
                      label: Text('${_filters[index]} (${_filterCount(index)})'),
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? AppTypography.semibold
                            : AppTypography.medium,
                      ),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primary,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          _buildAdList(mainTabIndex: 0),
          _buildAdList(mainTabIndex: 1),
          _buildAdList(mainTabIndex: 2),
        ],
      ),
    );
  }

  Widget _buildAdList({required int mainTabIndex}) {
    final theme = Theme.of(context);
    final ads = _getFilteredAds(mainTabIndex, _selectedFilterIndex);

    if (ads.isEmpty) {
      return Center(
        child: Text(
          'No ads found',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ads.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => AdCard(ad: ads[index]),
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

  const AdModel({
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

  const AdCard({
    super.key,
    required this.ad,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.cardTheme.color ?? colorScheme.surface,
      elevation: theme.cardTheme.elevation ?? 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(context),
                const SizedBox(width: 10),
                Expanded(child: _buildDetails(context)),
              ],
            ),
            if (ad.status == AdStatus.rejected &&
                ad.rejectionReason != null) ...[
              const SizedBox(height: 12),
              _buildRejectionSection(context, ad.rejectionReason!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 100,
        height: 120,
        child: Image.network(
          ad.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return ColoredBox(
              color: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Posted on ${ad.date}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: AppTypography.light,
                ),
              ),
            ),
            _buildMenuButton(context),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            _buildStatusBadge(context, ad.status),
            if (ad.status == AdStatus.inactive)
              _buildInactiveBadge(context),
          ],
        ),
        const SizedBox(height: 8),
        if (ad.category.isNotEmpty) ...[
          Text(
            ad.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: AppTypography.light,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          ad.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: AppTypography.regular,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ad.price,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: AppTypography.semibold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildMetric(
              context,
              icon: Icons.star_rounded,
              iconColor: AppColors.warning500,
              label: '${ad.rating ?? 0} (${ad.saves})',
            ),
            _buildMetric(
              context,
              icon: Icons.visibility_outlined,
              label: 'Views (${ad.views})',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: iconColor ?? colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: AppTypography.regular,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, AdStatus status) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    late final Color backgroundColor;
    late final Color textColor;
    late final String text;

    switch (status) {
      case AdStatus.pending:
        backgroundColor = isDark
            ? AppColors.warning900.withValues(alpha: 0.65)
            : ActivityColors.pendingBg;
        textColor = isDark
            ? AppColors.warning200
            : ActivityColors.pendingText;
        text = 'Pending';
        break;
      case AdStatus.approved:
      case AdStatus.inactive:
        backgroundColor = isDark
            ? AppColors.success900.withValues(alpha: 0.65)
            : ActivityColors.approvedBg;
        textColor = isDark
            ? AppColors.success200
            : ActivityColors.approvedText;
        text = 'Approved';
        break;
      case AdStatus.rejected:
        backgroundColor = isDark
            ? AppColors.error900.withValues(alpha: 0.65)
            : ActivityColors.rejectedBg;
        textColor = isDark
            ? AppColors.error200
            : ActivityColors.rejectedText;
        text = 'Rejected';
        break;
    }

    return _badge(
      context,
      text: text,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }

  Widget _buildInactiveBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _badge(
      context,
      text: 'Inactive',
      backgroundColor: isDark
          ? AppColors.neutral800
          : ActivityColors.inactiveBg,
      textColor: isDark
          ? AppColors.neutral100
          : ActivityColors.inactiveText,
    );
  }

  Widget _badge(
    BuildContext context, {
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: AppTypography.medium,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: 28,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        tooltip: 'Ad options',
        icon: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onSelected: (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$value selected for ${ad.title}')),
          );
        },
        itemBuilder: (_) => const [
          PopupMenuItem<String>(
            value: 'Edit',
            child: Text('Edit'),
          ),
          PopupMenuItem<String>(
            value: 'Inactive',
            child: Text('Inactive'),
          ),
          PopupMenuItem<String>(
            value: 'Remove',
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionSection(BuildContext context, String reason) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.error900.withValues(alpha: 0.55)
                : AppColors.error50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            reason,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.error200 : colorScheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {},
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Edit Now'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
