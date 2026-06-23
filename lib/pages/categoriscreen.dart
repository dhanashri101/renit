import 'package:flutter/material.dart';
import 'package:rentit24/pages/category_ad_list_screen.dart'; 

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  int _selectedMainCategory = 1;

  final List<Map<String, dynamic>> _mainCategories = [
    {'icon': Icons.child_care, 'name': 'Baby Kids'},
    {'icon': Icons.devices, 'name': 'Electronics'},
    {'icon': Icons.chair, 'name': 'Furniture'},
    {'icon': Icons.event, 'name': 'Event\nProfessionals'},
    {'icon': Icons.handyman, 'name': 'Tools &\nMachinery'},
  ];

  // 1. Create a Map to hold different subcategories for each main tab index
  final Map<int, List<Map<String, dynamic>>> _allSubCategories = {
    0: [ // Baby Kids (Index 0)
      {'icon': Icons.toys, 'name': 'Toys'},
      {'icon': Icons.stroller, 'name': 'Strollers'},
      {'icon': Icons.crib, 'name': 'Cribs'},
    ],
    1: [ // Electronics (Index 1)
      {'icon': Icons.laptop, 'name': 'Laptop'},
      {'icon': Icons.smartphone, 'name': 'Mobile'},
      {'icon': Icons.tablet_mac, 'name': 'Tablet'},
      {'icon': Icons.tv, 'name': 'TV'},
      {'icon': Icons.videocam, 'name': 'Projector'},
      {'icon': Icons.camera_alt, 'name': 'Camera'},
    ],
    2: [ // Furniture (Index 2)
      {'icon': Icons.chair_alt, 'name': 'Chairs'},
      {'icon': Icons.bed, 'name': 'Beds'},
      {'icon': Icons.table_restaurant, 'name': 'Tables'},
    ],
    3: [ // Event Professionals (Index 3)
      {'icon': Icons.camera_front, 'name': 'Photographers'},
      {'icon': Icons.music_note, 'name': 'DJs'},
    ],
    4: [ // Tools & Machinery (Index 4)
      {'icon': Icons.plumbing, 'name': 'Plumbing'},
      {'icon': Icons.carpenter, 'name': 'Woodwork'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // 2. Fetch the correct list of subcategories based on the active top tab!
    // If it's empty or null, we just provide an empty list []
    final currentSubCategories = _allSubCategories[_selectedMainCategory] ?? [];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Category List',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Main Categories Tab Bar
          Container(
            color: surfaceColor,
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mainCategories.length,
              itemBuilder: (context, index) {
                final isActive = _selectedMainCategory == index;
                return GestureDetector(
                  // FIX APPLIED HERE: Makes the entire empty space clickable
                  behavior: HitTestBehavior.opaque, 
                  
                  onTap: () => setState(() => _selectedMainCategory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    margin: const EdgeInsets.only(right: 24, top: 10),
                    // Optional extra safeguard: giving the container a transparent background
                    color: Colors.transparent, 
                    child: Column(
                      children: [
                        Icon(
                          _mainCategories[index]['icon'],
                          color: isActive ? theme.primaryColor : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _mainCategories[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive 
                                ? (isDark ? Colors.white : Colors.black) 
                                : Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        if (isActive)
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Sub Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: currentSubCategories.length, // 3. Use dynamic length
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // 4. Removed the "if (isCamera)" restriction! Now ANY tap navigates.
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                            const CategoryAdListScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Removed hardcoded highlight
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          currentSubCategories[index]['icon'], // 5. Use dynamic icon
                          color: theme.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentSubCategories[index]['name'], // 6. Use dynamic name
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}