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

  AdItem({
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
        'Discover our groundbreaking range of products and services designed specifically for the photography industry, elevating your creative potential and transforming your workflow!',
  });

  @override
  State<ProfileScreenchat> createState() => _ProfileScreenchatState();
}

class _ProfileScreenchatState extends State<ProfileScreenchat> {
  bool _isFollowing = false;
  String _selectedTab = 'All';

  final List<AdItem> _ads = [
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
      isFeatured: false,
      isTopChoice: false,
      category: 'Products',
    ),
  ];

  List<AdItem> get _filteredAds {
    if (_selectedTab == 'All') return _ads;
    return _ads.where((a) => a.category == _selectedTab).toList();
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile link copied")),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${widget.userName} reported")),
        );
        break;
      case 'block':
        _confirmBlockUser();
        break;
    }
  }

  void _confirmBlockUser() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          "Block ${widget.userName}",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          "Blocked users won't be able to message you or view your ads.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Block", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBlue  = const Color(0xFF2563EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final Color primaryBlue = const Color(0xFF2563EB);
    final Color backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF3F4F6);
    final Color surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    final Color subTextColor =
        isDark ? Colors.white60 : const Color(0xFF6B7280);
    final Color statsBg =
        isDark ? const Color(0xFF1E2A4A) : const Color(0xFFE0E7FF);
    final Color dividerColor =
        isDark ? Colors.white24 : Colors.grey.withOpacity(0.3);
    final Color chipUnselectedBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color chipBorder =
        isDark ? Colors.white24 : Colors.grey.shade300;
    final Color chipUnselectedText =
        isDark ? Colors.white54 : const Color(0xFF9CA3AF);
    final Color followingBg =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);

    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 20.0;
    const gridSpacing = 12.0;
    final usableWidth = screenWidth - (horizontalPadding * 2);
    final cardWidth = (usableWidth - gridSpacing) / 2;

    const imageHeight = 104.0;
    const cardInfoHeight = 128.0;
    final cardHeight = imageHeight + cardInfoHeight;
    final childAspectRatio = cardWidth / cardHeight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                  width: 1),
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.more_horiz, color: textColor, size: 18),
              color: surfaceColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'share',
                  height: 44,
                  child: Text('Share profile',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                PopupMenuItem(
                  value: 'report',
                  height: 44,
                  child: Text('Report user',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
                PopupMenuItem(
                  value: 'block',
                  height: 44,
                  child: Text('Block user',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey.shade200,
                    backgroundImage: NetworkImage(widget.avatar),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.userName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (widget.isVerified)
                          Row(
                            children: [
                              Icon(Icons.workspace_premium,
                                  size: 14, color: textColor),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                    color: textColor.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          widget.joinedLabel,
                          style: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                widget.bio,
                style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: statsBg,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('${widget.adsCount}', 'Ads', textColor, subTextColor),
                _buildStat('${widget.followersCount}', 'Followers', textColor, subTextColor),
                _buildStat('${widget.followingCount}', 'Following', textColor, subTextColor),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => setState(() => _isFollowing = !_isFollowing),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB))
                      : primaryBlue ,
                  foregroundColor: _isFollowing ? textColor : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      setState(() => _isFollowing = !_isFollowing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFollowing ? followingBg : primaryBlue,
                    foregroundColor: _isFollowing ? textColor : Colors.white,
                    elevation: _isFollowing ? 0 : 4,
                    shadowColor: primaryBlue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    _isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ads posted',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTabChip('All', textColor, subTextColor, primaryBlue , isDark),
                const SizedBox(width: 8),
                _buildTabChip('Products', textColor, subTextColor, primaryBlue , isDark),
                const SizedBox(width: 8),
                _buildTabChip('Services', textColor, subTextColor, primaryBlue , isDark),
              ],
            ),
            const SizedBox(height: 16),
            _filteredAds.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No ads in this category', style: TextStyle(color: subTextColor)),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredAds.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
      String value, String label, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: subTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTabChip(String label, Color textColor, Color? subTextColor, Color primaryBlue , bool isDark) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue  : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : unselectedText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(AdItem ad, ThemeData theme, bool isDark) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF2F314D);
    final Color priceColor = isDark ? Colors.white : const Color(0xFF090726);
    final Color distanceColor =
        isDark ? Colors.white60 : const Color(0x99090726);
    final Color ratingCountColor =
        isDark ? Colors.white54 : const Color(0x99090726);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(adData: ad),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  child: Image.network(
                    ad.image,
                    height: 104,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 104,
                        width: double.infinity,
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 104,
                      width: double.infinity,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                if (ad.isFeatured)
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
                              color: isDark ? Colors.white38 : Colors.grey[400],
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ad.distance,
                              style: TextStyle(
                                color: distanceColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        if (ad.isTopChoice)
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
                      ad.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ad.price,
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
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey.shade200,
                          backgroundImage: NetworkImage(ad.ownerAvatar),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ad.owner,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          ad.rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${ad.reviews})',
                          style: TextStyle(
                            color: ratingCountColor,
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