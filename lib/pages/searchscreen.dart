import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();

  bool _isLocationFocused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    _locationFocusNode.addListener(() {
      setState(() {
        _isLocationFocused = _locationFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _searchFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A2C);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              color: bgColor,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus 
                            ? const Color(0xFF2B58E4) 
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Find Wheelchair, Speaker, Doctor...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        suffixIcon: Icon(Icons.search, color: theme.primaryColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _locationFocusNode.hasFocus 
                            ? const Color(0xFF2B58E4) 
                            : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: TextField(
                      controller: _locationController,
                      focusNode: _locationFocusNode,
                      style: TextStyle(color: textColor, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Mumbai, Maharashtra',
                        hintStyle: TextStyle(color: textColor, fontSize: 15),
                        prefixIcon: Icon(Icons.location_on_outlined, color: theme.primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.cancel_outlined, color: Colors.grey[400]),
                          onPressed: () {
                            _locationController.clear();
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLocationFocused
                  ? _buildLocationSuggestions(theme, isDark, textColor)
                  : _buildSearchSuggestions(theme, isDark, textColor, cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(ThemeData theme, bool isDark, Color textColor, Color? cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Clear all',
                  style: TextStyle(color: theme.primaryColor, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChip('car', isDark, cardColor),
            ],
          ),
          const SizedBox(height: 12),
          
         if (_searchController.text.isNotEmpty)
  _buildAutocompleteList(isDark, textColor)
else
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        'Popular Categories',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),


      _buildPopularCategoriesGrid(
        isDark,
        textColor,
        cardColor,
      ),
    ],
  ),
        ],
      ),
    );
  }

  Widget _buildAutocompleteList(bool isDark, Color textColor) {
    final query = _searchController.text.toLowerCase();
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search, color: Colors.grey[500]),
          ),
          title: Text(query, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          subtitle: Text('In all categories', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          onTap: () {},
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=100'),
          ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'kia ', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                TextSpan(text: query, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(text: 'ens', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          ),
          subtitle: Text('Cars', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLocationSuggestions(ThemeData theme, bool isDark, Color textColor) {
    final locations = [
      'Thane Station, Thane',
      'Kausa, Mumbra',
      'Andheri West, Mumbai',
      'Govandi, Mumbai',
      'Jogeshwari West, Mumbai',
      'Malad East, Mumbai',
      'Mira Road, Mumbai',
      'Kurla West, Mumbai',
      'Byculla, Mumbai'
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ListTile(
          leading: Icon(Icons.my_location, color: theme.primaryColor),
          title: Text('Use current location', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          subtitle: Text('Enable Location', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Text(
          'Popular Locations',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...locations.map((loc) => ListTile(
          leading: Icon(Icons.location_on_outlined, color: theme.primaryColor, size: 20),
          title: Text(loc, style: TextStyle(color: textColor, fontSize: 14)),
          onTap: () {
            setState(() {
              _locationController.text = loc;
              _locationFocusNode.unfocus();
              _searchFocusNode.requestFocus();
            });
          },
        )),
      ],
    );
  }

  Widget _buildPopularCategoriesGrid(bool isDark, Color textColor, Color? cardColor) {
    final List<Map<String, String>> popularCategories = [
      {'name': 'Vehicles', 'img': 'assets/images/categories/vehicles.png'},
      {'name': 'Transport\nServices', 'img': 'assets/images/categories/transportation-services.png'},
      {'name': 'Electronics', 'img': 'assets/images/categories/electronics.png'},
      {'name': 'Furniture', 'img': 'assets/images/categories/furniture.png'},
      {'name': 'Pets Care\nServices', 'img': 'assets/images/categories/pets-animals.png'},
      {'name': 'Beauty &\nGrooming', 'img': 'assets/images/categories/beauty-grooming.png'},
      {'name': 'Fashion\nServices', 'img': 'assets/images/categories/fashion-dress.png'},
      {'name': 'Professional\nServices', 'img': 'assets/images/categories/professional-services.png'},
      {'name': 'Medical\nEquipment', 'img': 'assets/images/categories/medical-equipment.png'},
      {'name': 'Real Estate', 'img': 'assets/images/categories/real-estate.png'},
      {'name': 'Tools\nMachinery', 'img': 'assets/images/categories/tools-machinery.png'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [         
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,      
              crossAxisSpacing: 12,  
              mainAxisSpacing: 12,   
              childAspectRatio: 0.65, 
            ),
            itemCount: popularCategories.length,
            itemBuilder: (context, index) {
              final category = popularCategories[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(category['img']!),
                          fit: BoxFit.contain, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF2F314D),
                      fontSize: 11,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                      height: 1.18,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildChip(String label, bool isDark, Color? cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}