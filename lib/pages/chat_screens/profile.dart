import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';

class AdItem {
  final String image;
  final String title;
  final String price;
  final double rating;
  final String? badge;
  final String category; 

  AdItem({
    required this.image,
    required this.title,
    required this.price,
    required this.rating,
    this.badge,
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
    required this.userName,
    this.avatar = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    this.isVerified = true,
    this.joinedLabel = 'Joined March 2023',
    this.adsCount = 24,
    this.followersCount = 110,
    this.followingCount = 0,
    this.bio =
        'Discover our groundbreaking range of products and services designed specifically for the photography industry, elevating your creative potential and transforming your workflow.',
  });

  @override
  State<ProfileScreenchat> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenchat> {
  bool _isFollowing = false;
  String _selectedTab = 'All';

  final List<AdItem> _ads = [
    AdItem(
      image: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
      title: 'GoPro 12',
      price: '₹1500/day',
      rating: 3.5,
      badge: 'Featured',
      category: 'Products',
    ),
    AdItem(
      image: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=400',
      title: 'Canon EOS R6',
      price: '₹2000/day',
      rating: 4.9,
      badge: 'Top Choice',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block ${widget.userName}"),
        content: const Text("Blocked users won't be able to message you or view your ads."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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
    final primaryBlue = const Color(0xFF2563EB);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(children: [
                  Icon(Icons.ios_share, size: 18, color: textColor),
                  const SizedBox(width: 12),
                  Text('Share profile', style: TextStyle(color: textColor, fontSize: 14)),
                ]),
              ),
              PopupMenuItem(
                value: 'report',
                child: Row(children: [
                  Icon(Icons.flag_outlined, size: 18, color: textColor),
                  const SizedBox(width: 12),
                  Text('Report user', style: TextStyle(color: textColor, fontSize: 14)),
                ]),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(children: [
                  Icon(Icons.block, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Block user', style: TextStyle(color: Colors.red, fontSize: 14)),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(widget.avatar),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (widget.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, size: 18, color: Color(0xFF2563EB)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                widget.joinedLabel,
                style: TextStyle(color: subTextColor, fontSize: 12),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  widget.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
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
                      : primaryBlue,
                  foregroundColor: _isFollowing ? textColor : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                _buildTabChip('All', textColor, subTextColor, primaryBlue, isDark),
                const SizedBox(width: 8),
                _buildTabChip('Products', textColor, subTextColor, primaryBlue, isDark),
                const SizedBox(width: 8),
                _buildTabChip('Services', textColor, subTextColor, primaryBlue, isDark),
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
                    itemBuilder: (context, index) {
                      return _buildAdCard(_filteredAds[index], isDark, cardColor, textColor, subTextColor);
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, Color textColor, Color? subTextColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: subTextColor, fontSize: 12)),
      ],
    );
  }

  Widget _buildTabChip(String label, Color textColor, Color? subTextColor, Color primaryBlue, bool isDark) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : subTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(AdItem ad, bool isDark, Color cardColor, Color textColor, Color? subTextColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(ad.image, fit: BoxFit.cover),
                if (ad.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ad.badge!,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.title,
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ad.price,
                      style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(
                          ad.rating.toStringAsFixed(1),
                          style: TextStyle(color: subTextColor, fontSize: 11),
                        ),
                      ],
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
}