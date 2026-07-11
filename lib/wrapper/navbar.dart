import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/activity.dart';
import 'package:rentit24/pages/chat_screens/chat_list.dart';
import 'package:rentit24/pages/homescreen.dart';
import 'package:rentit24/pages/profile_screen.dart';
import 'package:rentit24/pages/rentit_page.dart';



class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ChatListScreen(),
    RentItScreen(),
    MyActivityPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color navigationColor = isDark
        ? AppColors.darkSurface
        : AppColors.primary500;

    final Color selectedColor = AppColors.baseWhite;
    final Color unselectedColor =
        AppColors.baseWhite.withValues(alpha: 0.65);

    return Container(
      decoration: BoxDecoration(
        color: navigationColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.baseBlack.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              onTap: onTap,

              backgroundColor: navigationColor,
              elevation: 0,

              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,

              selectedFontSize: AppTypography.bodyXS,
              unselectedFontSize: AppTypography.bodyXS,

              selectedLabelStyle: AppTypography.bodyExtraSmall(
                AppTypography.semibold,
                selectedColor,
              ).copyWith(
                height: 1.1,
              ),

              unselectedLabelStyle: AppTypography.bodyExtraSmall(
                AppTypography.regular,
                unselectedColor,
              ).copyWith(
                height: 1.1,
              ),

              showSelectedLabels: true,
              showUnselectedLabels: true,

              items: [
                _buildNavigationItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'HOME',
                ),
                _buildNavigationItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  selectedIcon: Icons.chat_bubble_rounded,
                  label: 'CHATS',
                ),
                BottomNavigationBarItem(
                  icon: _buildRentIcon(
                    isSelected: currentIndex == 2,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  activeIcon: _buildRentIcon(
                    isSelected: true,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  ),
                  
                  label: 'RENT IT',
                ),
                _buildNavigationItem(
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment_rounded,
                  label: 'ACTIVITY',
                ),
                _buildNavigationItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'PROFILE',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 7,
        ),
        child: Icon(
          icon,
          size: 20,
        ),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 4,
        ),
        child: Icon(
          selectedIcon,
          size: 20
        ),
      ),
      label: label,
    );
  }

  Widget _buildRentIcon({
    required bool isSelected,
    required Color selectedColor,
    required Color unselectedColor,
  }) {
    final Color iconColor =
        isSelected ? selectedColor : unselectedColor;

    return Padding(
      padding: const EdgeInsets.only(
        top: 6,
        bottom: 6,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? AppColors.baseWhite
              : Colors.transparent,
          border: Border.all(
            color: iconColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 19,
          color: isSelected
              ? AppColors.primary500
              : iconColor,
        ),
      ),
    );
  }
}