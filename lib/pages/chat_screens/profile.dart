import 'package:flutter/material.dart';
import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/model/user_profile_model.dart';
import 'package:rentit24/pages/product_details_screen.dart';
import 'package:rentit24/services/listing_services.dart';
import 'package:rentit24/services/user_profile_service.dart';

class AdItem {
  const AdItem({
    this.id = 0,
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
    this.isVerified = false,
    this.category = 'Products',
    this.listingType = 'product',
    this.description = '',
    this.address = '',
    this.phone = '',
  });

  final int id;
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
  final bool isVerified;
  final String category;
  final String listingType;
  final String description;
  final String address;
  final String phone;

  factory AdItem.fromListing(ListingModel listing) {
    String fallbackImage() {
      final String text =
          '${listing.title} ${listing.categoryName}'.toLowerCase();
      if (text.contains('wheelchair') || text.contains('medical')) {
        return 'assets/images/wheelchair.jpg';
      }
      if (text.contains('camera') || text.contains('electronics')) {
        return 'assets/images/camera.jpg';
      }
      return 'assets/images/carpainter.jpg';
    }

    return AdItem(
      id: listing.id,
      image: listing.imageUrl.isNotEmpty
          ? listing.imageUrl
          : fallbackImage(),
      title: listing.title,
      price: listing.displayPrice,
      rating: listing.rating,
      reviews: listing.reviewCount,
      distance: listing.distanceKm == null
          ? listing.address
          : '${listing.distanceKm!.toStringAsFixed(1)} km',
      owner: listing.ownerName.isEmpty
          ? 'RentIt24 User'
          : listing.ownerName,
      ownerAvatar: listing.ownerProfileUrl,
      isFeatured: listing.isFeatured,
      isTopChoice: listing.isTopChoice,
      isVerified: listing.isVerified,
      category: listing.categoryName.isEmpty
          ? listing.listingType
          : listing.categoryName,
      listingType: listing.listingType,
      description: listing.description,
      address: listing.address,
    );
  }
}

class ProfileScreenchat extends StatefulWidget {
  const ProfileScreenchat({
    super.key,
    this.ownerId = 0,
    this.userName = 'RentIt24 User',
    this.avatar = '',
    this.isVerified = false,
    this.joinedLabel = 'Joined RentIt24',
    this.adsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.bio = 'No profile description provided.',
  });

  final int ownerId;
  final String userName;
  final String avatar;
  final bool isVerified;
  final String joinedLabel;
  final int adsCount;
  final int followersCount;
  final int followingCount;
  final String bio;

  @override
  State<ProfileScreenchat> createState() => _ProfileScreenchatState();
}

class _ProfileScreenchatState extends State<ProfileScreenchat> {
  static const Color _primaryBlue = Color(0xFF2563EB);

  final ListingService _listingService = ListingService();
  final UserProfileService _profileService = UserProfileService();
  final List<AdItem> _ads = <AdItem>[];

  UserProfileModel? _profile;
  bool _isFollowing = false;
  bool _isLoading = false;
  String _selectedTab = 'All';

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    if (widget.ownerId <= 0) return;

    setState(() => _isLoading = true);

    try {
      final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
        _profileService.getProfile(userId: widget.ownerId),
        _listingService.getMyListings(ownerId: widget.ownerId, limit: 100),
      ]);

      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfileModel;
        _ads
          ..clear()
          ..addAll(
            List<ListingModel>.from(results[1] as List<dynamic>)
                .map(AdItem.fromListing),
          );
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Owner profile load error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String get _displayName => _profile?.username.isNotEmpty == true
      ? _profile!.username
      : widget.userName;

  String get _displayAvatar => _profile?.profileUrl.isNotEmpty == true
      ? _profile!.profileUrl
      : widget.avatar;

  bool get _displayVerified => _profile?.isVerified ?? widget.isVerified;

  int get _displayAdsCount => _ads.isNotEmpty ? _ads.length : widget.adsCount;

  int get _displayFollowers =>
      _profile?.followersCount ?? widget.followersCount;

  int get _displayFollowing =>
      _profile?.followingCount ?? widget.followingCount;

  String get _displayBio => _profile?.about.isNotEmpty == true
      ? _profile!.about
      : widget.bio;

  String get _displayJoinedLabel {
    final DateTime? joined = _profile?.joinedAt;
    if (joined == null) return widget.joinedLabel;
    return 'Joined in ${joined.month.toString().padLeft(2, '0')}/${joined.year}';
  }

  List<AdItem> get _filteredAds {
    if (_selectedTab == 'All') return _ads;

    return _ads.where((ad) {
      final String category = ad.category.toLowerCase();
      final String type = ad.listingType.toLowerCase();

      if (_selectedTab == 'Products') {
        return category.contains('product') || type.contains('product');
      }
      return category.contains('service') || type.contains('service');
    }).toList();
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        _showMessage('Profile link copied');
        break;
      case 'report':
        _showMessage('$_displayName reported');
        break;
      case 'block':
        _confirmBlockUser();
        break;
    }
  }

  Future<void> _confirmBlockUser() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text('Block $_displayName?'),
          content: const Text(
            "Blocked users won't be able to message you or view your ads.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showMessage('$_displayName blocked');
              },
              child: const Text(
                'Block',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FF);
    final Color textColor =
        isDark ? Colors.white : const Color(0xFF101828);
    final Color secondaryTextColor =
        isDark ? Colors.white60 : const Color(0xFF667085);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(
        isDark: isDark,
        backgroundColor: backgroundColor,
        textColor: textColor,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: _primaryBlue,
          onRefresh: _loadOwnerData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProfileHeader(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  backgroundColor: backgroundColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _displayBio,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 18),
                _buildStatsCard(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
                const SizedBox(height: 16),
                _buildFollowButton(
                  isDark: isDark,
                  textColor: textColor,
                ),
                const SizedBox(height: 26),
                Row(
                  children: <Widget>[
                    Text(
                      'Ads posted',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoading)
                      const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primaryBlue,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildCategoryTabs(isDark),
                const SizedBox(height: 16),
                _buildAdsSection(
                  isDark: isDark,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required bool isDark,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return AppBar(
      toolbarHeight: 58,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 48,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 19,
        ),
      ),
      actions: <Widget>[
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : const Color(0xFFE4E7EC),
            ),
          ),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            icon: Icon(
              Icons.more_horiz_rounded,
              color: textColor,
              size: 20,
            ),
            onSelected: _handleMenuSelection,
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              _profileMenuItem(
                value: 'share',
                icon: Icons.share_outlined,
                label: 'Share profile',
              ),
              _profileMenuItem(
                value: 'report',
                icon: Icons.flag_outlined,
                label: 'Report user',
              ),
              _profileMenuItem(
                value: 'block',
                icon: Icons.block_rounded,
                label: 'Block user',
                destructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _profileMenuItem({
    required String value,
    required IconData icon,
    required String label,
    bool destructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 19,
            color: destructive ? Colors.red : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: destructive ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
    required Color backgroundColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _ProfileAvatar(
              imageUrl: _displayAvatar,
              isDark: isDark,
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
                  border: Border.all(color: backgroundColor, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (_displayVerified) ...<Widget>[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: _primaryBlue,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (_displayVerified)
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 14,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 5),
                Text(
                  _displayJoinedLabel,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D2945) : const Color(0xFFE7EDFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildStat(
              value: '$_displayAdsCount',
              label: 'Ads',
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ),
          _buildStatDivider(isDark),
          Expanded(
            child: _buildStat(
              value: '$_displayFollowers',
              label: 'Followers',
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ),
          _buildStatDivider(isDark),
          Expanded(
            child: _buildStat(
              value: '$_displayFollowing',
              label: 'Following',
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? Colors.white12 : _primaryBlue.withValues(alpha: 0.14),
    );
  }

  Widget _buildFollowButton({
    required bool isDark,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => setState(() => _isFollowing = !_isFollowing),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing
              ? (isDark ? const Color(0xFF262626) : const Color(0xFFE4E7EC))
              : _primaryBlue,
          foregroundColor: _isFollowing ? textColor : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Row(
            key: ValueKey<bool>(_isFollowing),
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _isFollowing
                    ? Icons.check_rounded
                    : Icons.person_add_alt_1_rounded,
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
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          _buildTabChip('All', isDark),
          const SizedBox(width: 8),
          _buildTabChip('Products', isDark),
          const SizedBox(width: 8),
          _buildTabChip('Services', isDark),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, bool isDark) {
    final bool isSelected = _selectedTab == label;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedTab = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? _primaryBlue
              : (isDark ? const Color(0xFF242424) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? _primaryBlue
                : (isDark ? Colors.white12 : const Color(0xFFE4E7EC)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white60 : const Color(0xFF667085)),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAdsSection({
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final List<AdItem> ads = _filteredAds;

    if (_isLoading && ads.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );
    }

    if (ads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Column(
            children: <Widget>[
              Icon(
                Icons.inventory_2_outlined,
                color: secondaryTextColor,
                size: 44,
              ),
              const SizedBox(height: 10),
              Text(
                'No ads in this category',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;
    const double pagePadding = 36;
    const double spacing = 12;
    final double cardWidth = (screenWidth - pagePadding - spacing) / 2;
    const double cardHeight = 242;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ads.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: cardWidth / cardHeight,
      ),
      itemBuilder: (_, index) {
        return _buildAdCard(
          ad: ads[index],
          isDark: isDark,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        );
      },
    );
  }

  Widget _buildAdCard({
    required AdItem ad,
    required bool isDark,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailsScreen(adData: ad),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 105,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _ListingImage(source: ad.image, isDark: isDark),
                  if (ad.isFeatured)
                    Positioned(
                      left: 0,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
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
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            ad.distance.isEmpty
                                ? ad.address
                                : ad.distance,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 9.5,
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
                              color: const Color(0xFF101828),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'Top Choice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
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
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        _OwnerAvatar(
                          imageUrl: ad.ownerAvatar,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            ad.owner,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 9.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
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
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${ad.reviews})',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 9.5,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage = imageUrl.startsWith('http');

    return CircleAvatar(
      radius: 37,
      backgroundColor:
          isDark ? Colors.grey.shade800 : const Color(0xFFE4E7EC),
      backgroundImage: hasNetworkImage ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: hasNetworkImage ? (_, __) {} : null,
      child: hasNetworkImage
          ? null
          : Icon(
              Icons.person_outline_rounded,
              color: isDark ? Colors.white60 : const Color(0xFF667085),
              size: 32,
            ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage = imageUrl.startsWith('http');

    return CircleAvatar(
      radius: 8,
      backgroundColor:
          isDark ? Colors.grey.shade800 : const Color(0xFFE4E7EC),
      backgroundImage: hasNetworkImage ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: hasNetworkImage ? (_, __) {} : null,
      child: hasNetworkImage
          ? null
          : const Icon(Icons.person_outline_rounded, size: 10),
    );
  }
}

class _ListingImage extends StatelessWidget {
  const _ListingImage({required this.source, required this.isDark});

  final String source;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = Container(
      color: isDark ? Colors.grey.shade800 : const Color(0xFFE4E7EC),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
      ),
    );

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: isDark ? Colors.grey.shade800 : const Color(0xFFE4E7EC),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
