import 'package:flutter/material.dart';
import 'package:rentit24/pages/chat_screens/chat_list.dart';
import 'package:rentit24/pages/form/product_listing_form.dart';
import 'package:rentit24/pages/homescreen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int currentIndex = 0;

  final pages = [
    const HomeScreen(),
    const ChatListScreen(),
    const ProductListingFlow(),
    const HomeScreen(),
    const HomeScreen(),
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

  static const _items = [
    (icon: Icons.home_filled, label: 'HOME'),
    (icon: Icons.chat_bubble_outline, label: 'CHATS'),
    (icon: Icons.add, label: 'RENT IT'),
    (icon: Icons.assignment_outlined, label: 'ACTIVITY'),
    (icon: Icons.person_outline, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: index == 2
                          ? Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : Icon(
                              item.icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white70,
                              size: 22,
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}