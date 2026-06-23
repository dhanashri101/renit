import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> adData;

  const ProductDetailsScreen({super.key, required this.adData});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  DateTime _selectedDate = DateTime.now();
  bool _isDescriptionExpanded = false;

  final List<String> _images = [
    'assets/images/camera.jpg',
    'assets/images/camera.jpg',
    'assets/images/camera.jpg',
    'assets/images/camera.jpg',
    'assets/images/camera.jpg',
  ];

  final String _fullDescription =
      "The Canon EOS M50 Mark II is a versatile mirrorless camera ideal for photography enthusiasts and content creators alike. It boasts a 24.1 MP APS-C sensor for exceptional image quality and vibrant colors. Featuring a Dual Pixel autofocus system, it allows for effortless capture of sharp images and smooth video.";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ FIX 1: Use theme-aware colors instead of hardcoded dark values
    final surfaceColor = theme.colorScheme.surface;
    final primaryBlue = const Color(0xFF2B5BE4);
    final bgColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF2F5FF);
    final textColor =
        isDark ? Colors.white : const Color(0xFF1A1D26);
    final subtitleColor =
        isDark ? Colors.white54 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(primaryBlue, isDark),
      bottomNavigationBar: _buildBottomBar(primaryBlue, isDark),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 12),
            _buildHeaderInfo(textColor, subtitleColor, isDark, primaryBlue),
            _buildOwnerCard(isDark, textColor, subtitleColor),
            _buildDescription(textColor, subtitleColor, primaryBlue),
            _buildSpecifications(textColor, subtitleColor),
            _buildAvailabilityCalendar(isDark, textColor, primaryBlue),
            _buildReviews(
              surfaceColor,
              textColor,
              subtitleColor,
              isDark,
              theme,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryBlue, bool isDark) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : primaryBlue,
      elevation: 0,
      // ✅ FIX 2: Explicit back button with proper Navigator.pop
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        // ✅ FIX 3: GestureDetector instead of TextField so it doesn't
        //    steal focus or intercept the back gesture
        child: GestureDetector(
          onTap: () {
            // Optional: navigate to SearchScreen instead of pop
            Navigator.pop(context);
          },
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Rent a "Car"',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: _images.length,
            onPageChanged: (index) =>
                setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) {
              return Image.asset(
                widget.adData['image'] ?? _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.grey,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              _buildIconCircle(Icons.favorite_border),
              const SizedBox(width: 8),
              _buildIconCircle(Icons.share_outlined),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${_images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildHeaderInfo(
    Color textColor,
    Color subtitleColor,
    bool isDark,
    Color primaryBlue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? primaryBlue
                      : primaryBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Badges and Date/Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildBadge('Featured', primaryBlue),
                  const SizedBox(width: 8),
                  _buildBadge(
                    'Top Choice',
                    isDark
                        ? Colors.grey[800]!
                        : const Color(0xFF090726),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Posted on 04 AUG',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.adData['rating']} (${widget.adData['reviews']} reviews)',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            widget.adData['title'] ??
                'Canon EOS M50 Mark II with lenses',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          // Location
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: subtitleColor, size: 14),
              const SizedBox(width: 4),
              Text(
                'Kausa Tetavali, Mumbra',
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price
          Text(
            widget.adData['price'] ?? '₹1500/day',
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '+ Security Deposit ₹10,000 (Refundable) ',
                style: TextStyle(color: subtitleColor, fontSize: 11),
              ),
              Icon(Icons.chevron_right, color: subtitleColor, size: 14),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOwnerCard(
      bool isDark, Color textColor, Color subtitleColor) {
    final cardColor =
        isDark ? const Color(0x19235BD6) : const Color(0xFFDEE5F6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=11',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owner',
                    style:
                        TextStyle(color: subtitleColor, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        widget.adData['owner'] ?? 'Hamza',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.workspace_premium,
                        size: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subtitleColor),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(
    Color textColor,
    Color subtitleColor,
    Color primaryBlue,
  ) {
    final displayText = _isDescriptionExpanded
        ? _fullDescription
        : "${_fullDescription.substring(0, 195)}...";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: displayText),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded =
                              !_isDescriptionExpanded;
                        });
                      },
                      child: Text(
                        _isDescriptionExpanded
                            ? " Show less"
                            : " Read more",
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(Color textColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecRow('Brand', 'Canon', textColor, subtitleColor),
          _buildSpecRow('Model Name', 'EOS M50 Mark II', textColor,
              subtitleColor),
          _buildSpecRow('Color', 'Black', textColor, subtitleColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Additional',
                  style:
                      TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'With camera',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildBulletText(
                        'Memory card 64GB', textColor, subtitleColor),
                    _buildBulletText(
                        '75mm & 100mm lense', textColor, subtitleColor),
                    _buildBulletText(
                        'Camera bag', textColor, subtitleColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(
    String label,
    String value,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletText(
      String text, Color textColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: subtitleColor, fontSize: 12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: subtitleColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCalendar(
    bool isDark,
    Color textColor,
    Color primaryBlue,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Availability',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              // ✅ FIX 4: Theme-aware calendar card background
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? ColorScheme.dark(
                        primary: primaryBlue,
                        onPrimary: Colors.white,
                        surface: const Color(0xFF1E1E1E),
                        onSurface: Colors.white,
                      )
                    : ColorScheme.light(
                        primary: primaryBlue,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) =>
                    setState(() => _selectedDate = date),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews(
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
    bool isDark,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Reviews',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star,
                      color: Colors.amber, size: 14),
                  Text(
                    ' 4.2 (135 reviews)',
                    style:
                        TextStyle(color: subtitleColor, fontSize: 12),
                  ),
                ],
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(
            'Albert Flores',
            'Oct 15, 2025',
            'Amazing product, just like new!',
            '4',
            surfaceColor,
            textColor,
            subtitleColor,
            isDark,
          ),
          _buildReviewCard(
            'Kathryn Murphy',
            'Sep 22, 2025',
            'Worked perfectly, great service.',
            '5',
            surfaceColor,
            textColor,
            subtitleColor,
            isDark,
          ),
          _buildReviewCard(
            'Ralph Edwards',
            'Sep 12, 2025',
            'Smooth handover and return process.',
            '4',
            surfaceColor,
            textColor,
            subtitleColor,
            isDark,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.grey[800]!
                      : Colors.blue.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.blue.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Show More',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    String date,
    String comment,
    String rating,
    Color surfaceColor,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIX 5: surfaceColor is now theme-aware (white in light mode)
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=$name&background=random',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                            color: subtitleColor, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B58E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment,
              style:
                  TextStyle(color: subtitleColor, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color primaryBlue, bool isDark) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        // ✅ FIX 6: Theme-aware bottom bar background
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildSolidButton(
                icon: Icons.call_outlined,
                label: 'Call Now',
                color: primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSolidButton(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                color: primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolidButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}