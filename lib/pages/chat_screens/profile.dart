import 'package:flutter/material.dart';
import 'package:rentit24/pages/product_details_screen.dart';

class AdItem {
  final String image;
  final String title;
  final String price;
  final double rating;
  final int reviews;
  final String distance;
  final String owner;
  final String ownerAvatar;
  final bool isFeatured;
  final bool isTopChoice;
  final String category;

  const AdItem({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.owner,
    required this.ownerAvatar,
    this.isFeatured = false,
    this.isTopChoice = false,
    this.category = 'Products',
  });
}

class ProfileScreenchat extends StatefulWidget {
  final String userName;
  final String avatar;
  final bool isVerified;
  final String joinedLabel;
  final int adsCount;
  final int followersCount;
  final int followingCount;
  final String bio;

  const ProfileScreenchat({
    super.key,
    this.userName = 'Floyd Miles',
    this.avatar =
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    this.isVerified = true,
    this.joinedLabel = 'Joined in Nov 2025',
    this.adsCount = 24,
    this.followersCount = 110,
    this.followingCount = 0,
    this.bio =
        'Discover our groundbreaking range of products and services designed '
        'specifically for the photography industry, elevating your creative '
        'potential and transforming your workflow!',
  });

  @override
  State<ProfileScreenchat> createState() => _ProfileScreenchatState();
}

class _ProfileScreenchatState extends State<ProfileScreenchat> {
  bool _isFollowing = false;
  String _selectedTab = 'All';

  final List<AdItem> _ads = const [
    AdItem(
      image:
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
      title: 'Go Pro 12',
      price: '₹1300/day',
      rating: 3.5,
      reviews: 110,
      distance: '2.5 km',
      owner: 'Floyd Miles',
      ownerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      isFeatured: true,
      isTopChoice: true,
      category: 'Products',
    ),
    AdItem(
      image:
          'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400',
      title: 'Canon EOS R6',
      price: '₹2000/day',
      rating: 5.0,
      reviews: 48,
      distance: '3 km',
      owner: 'Floyd Miles',
      ownerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      isFeatured: true,
      isTopChoice: true,
      category: 'Products',
    ),
    AdItem(
      image:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400',
      title: 'Sony Alpha A7 III',
      price: '₹1800/day',
      rating: 4.8,
      reviews: 89,
      distance: '4.1 km',
      owner: 'Floyd Miles',
      ownerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      isFeatured: false,
      isTopChoice: true,
      category: 'Products',
    ),
    AdItem(
      image:
          'https://images.unsplash.com/photo-1519183071298-a2962be96f83?w=400',
      title: 'Studio Light Kit',
      price: '₹900/day',
      rating: 4.2,
      reviews: 34,
      distance: '1.8 km',
      owner: 'Floyd Miles',
      ownerAvatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
      category: 'Services',
    ),
  ];

  List<AdItem> get _filteredAds {
    if (_selectedTab == 'All') {
      return _ads;
    }

    return _ads
        .where((ad) => ad.category == _selectedTab)
        .toList();
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile link copied'),
          ),
        );
        break;

      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.userName} reported'),
          ),
        );
        break;

      case 'block':
        _confirmBlockUser();
        break;
    }
  }

  void _confirmBlockUser() {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Block ${widget.userName}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "Blocked users won't be able to message you or view your ads.",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.userName} blocked'),
                  ),
                );
              },
              child: const Text(
                'Block',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    const Color primaryBlue = Color(0xFF2563EB);

    final Color backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);

    final Color surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final Color textColor =
        isDark ? Colors.white : const Color(0xFF111827);

    final Color subTextColor =
        isDark ? Colors.white60 : const Color(0xFF6B7280);

    final Color statsBackgroundColor =
        isDark ? const Color(0xFF1E2A4A) : const Color(0xFFE0E7FF);

    final Color followingBackgroundColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);

    final double screenWidth = MediaQuery.sizeOf(context).width;

    const double horizontalPadding = 20;
    const double gridSpacing = 12;

    final double usableWidth =
        screenWidth - (horizontalPadding * 2);

    final double cardWidth =
        (usableWidth - gridSpacing) / 2;

    const double imageHeight = 104;
    const double cardInformationHeight = 132;

    final double cardHeight =
        imageHeight + cardInformationHeight;

    final double childAspectRatio =
        cardWidth / cardHeight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            width: 34,
            height: 34,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white38
                    : Colors.grey.shade400,
              ),
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_horiz,
                color: textColor,
                size: 19,
              ),
              color: surfaceColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: _handleMenuSelection,
              itemBuilder: (context) {
                return [
                  PopupMenuItem<String>(
                    value: 'share',
                    height: 44,
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: textColor,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Share profile',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'report',
                    height: 44,
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          color: textColor,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Report user',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'block',
                    height: 44,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.block,
                          color: Colors.red,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Block user',
                          style: TextStyle(
                            color: isDark
                                ? Colors.red.shade300
                                : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(
                isDark: isDark,
                textColor: textColor,
                subTextColor: subTextColor,
              ),

              const SizedBox(height: 20),

              Text(
                widget.bio,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: statsBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        value: '${widget.adsCount}',
                        label: 'Ads',
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                    _buildVerticalDivider(isDark),
                    Expanded(
                      child: _buildStat(
                        value: '${widget.followersCount}',
                        label: 'Followers',
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                    _buildVerticalDivider(isDark),
                    Expanded(
                      child: _buildStat(
                        value: '${widget.followingCount}',
                        label: 'Following',
                        textColor: textColor,
                        subTextColor: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isFollowing = !_isFollowing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFollowing
                        ? followingBackgroundColor
                        : primaryBlue,
                    foregroundColor:
                        _isFollowing ? textColor : Colors.white,
                    elevation: _isFollowing ? 0 : 4,
                    shadowColor: primaryBlue.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Row(
                      key: ValueKey<bool>(_isFollowing),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFollowing
                              ? Icons.check
                              : Icons.person_add_alt_1,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Ads posted',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip(
                      label: 'All',
                      primaryBlue: primaryBlue,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      label: 'Products',
                      primaryBlue: primaryBlue,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildTabChip(
                      label: 'Services',
                      primaryBlue: primaryBlue,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_filteredAds.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: subTextColor,
                          size: 44,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No ads in this category',
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredAds.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final AdItem ad = _filteredAds[index];

                    return _buildAdCard(
                      ad: ad,
                      isDark: isDark,
                    );
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 38,
              backgroundColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              backgroundImage: NetworkImage(widget.avatar),
              onBackgroundImageError: (_, __) {},
            ),
            Positioned(
              right: 1,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF121212)
                        : const Color(0xFFF3F4F6),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF2563EB),
                        size: 19,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                if (widget.isVerified)
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 15,
                        color: textColor.withOpacity(0.75),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: textColor.withOpacity(0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 5),

                Text(
                  widget.joinedLabel,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 38,
      color: isDark
          ? Colors.white.withOpacity(0.15)
          : const Color(0xFF2563EB).withOpacity(0.16),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: subTextColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip({
    required String label,
    required Color primaryBlue,
    required bool isDark,
  }) {
    final bool isSelected = _selectedTab == label;

    final Color unselectedBackgroundColor =
        isDark ? const Color(0xFF242424) : Colors.white;

    final Color unselectedTextColor =
        isDark ? Colors.white60 : const Color(0xFF6B7280);

    final Color borderColor =
        isDark ? Colors.white24 : const Color(0xFFD1D5DB);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue
              : unselectedBackgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? primaryBlue : borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : unselectedTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard({
    required AdItem ad,
    required bool isDark,
  }) {
    final Color cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final Color textColor =
        isDark ? Colors.white : const Color(0xFF2F314D);

    final Color priceColor =
        isDark ? Colors.white : const Color(0xFF090726);

    final Color secondaryTextColor =
        isDark ? Colors.white60 : const Color(0x99090726);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return ProductDetailsScreen(
                adData: ad,
              );
            },
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                isDark ? 0.30 : 0.07,
              ),
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
                Image.network(
                  ad.image,
                  height: 104,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      height: 104,
                      width: double.infinity,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      height: 104,
                      width: double.infinity,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),

                if (ad.isFeatured)
                  Positioned(
                    top: 11,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF235BD6),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 29,
                    height: 29,
                    decoration: const BoxDecoration(
                      color: Color(0x66090726),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: secondaryTextColor,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            ad.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (ad.isTopChoice)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFF090726),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'Top Choice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      ad.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ad.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: priceColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          backgroundImage:
                              NetworkImage(ad.ownerAvatar),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ad.owner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          ad.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${ad.reviews})',
                          style: TextStyle(
                            color: secondaryTextColor,
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
      ),
    );
  }
}