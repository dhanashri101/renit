import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/form/product_listing_form.dart';
import 'package:rentit24/pages/form/service_upload_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(theme, isDark),
            const SizedBox(height: 20),
            _buildUploadSection(theme, isDark),
            const SizedBox(height: 24),
            _buildMenuSection(theme, isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Background Curved App Bar
        Container(
          padding: const EdgeInsets.only(
            top: 60,
            left: 24,
            right: 24,
            bottom: 60,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // User Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=200',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sachin Jadhav',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'sachin.jadhav@rentit24.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ActivityColors.approvedBg.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.verified,
                              color: ActivityColors.approvedText,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified Member',
                              style: TextStyle(
                                color: ActivityColors.approvedText,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Overlapping Stats Card
        Positioned(
          bottom: -25,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('12', 'Active Ads', isDark),
                _buildDivider(isDark),
                _buildStatItem('45', 'Rented', isDark),
                _buildDivider(isDark),
                _buildStatItem('4.8', 'Rating', isDark, isRating: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    bool isDark, {
    bool isRating = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRating) const Icon(Icons.star, color: Colors.amber, size: 18),
            if (isRating) const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A2C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildUploadSection(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Ad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildUploadCard(
                  title: 'Upload Product',
                  subtitle: 'Items for rent',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF235BD6),
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductListingFlow()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUploadCard(
                  title: 'Upload Service',
                  subtitle: 'Hire out skills',
                  icon: Icons.handyman_rounded,
                  color: const Color(0xFF059669),
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ServiceUploadFlow()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.3 : 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.15 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A2C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(ThemeData theme, bool isDark) {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Edit Profile',
        'color': theme.primaryColor,
      },
      {
        'icon': Icons.format_list_bulleted,
        'title': 'My Ads',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'title': 'Payments & Earnings',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.favorite_border,
        'title': 'Saved Items',
        'color': const Color(0xFFF43F5E),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.logout,
        'title': 'Log Out',
        'color': const Color(0xFFDC2626),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2C),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                indent: 64,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];

                // Staggered Slide & Fade Animation for Menu Items
                final slideAnimation =
                    Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.1 * index,
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    );

                final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          0.1 * index,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      ),
                    );

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: _buildMenuItem(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      iconColor: item['color'] as Color,
                      isDark: isDark,
                      isLast: index == menuItems.length - 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required bool isDark,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isLast ? 20 : 0),
          bottomRight: Radius.circular(isLast ? 20 : 0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isLast
                        ? const Color(0xFFDC2626)
                        : (isDark ? Colors.white : const Color(0xFF2D2D3A)),
                  ),
                ),
              ),
              if (!isLast)
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
