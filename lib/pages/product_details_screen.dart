import 'package:flutter/material.dart';
import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/pages/chat_screens/chat_details_screen.dart';
import 'package:rentit24/pages/chat_screens/profile.dart';
import 'package:rentit24/services/chat_service.dart';
import 'package:rentit24/services/listing_services.dart';
import 'package:rentit24/services/review_service.dart';
import 'package:rentit24/services/session_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatefulWidget {
  final AdItem adData;
  const ProductDetailsScreen({
    super.key,
    required this.adData,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const Color _primaryBlue = Color(0xFF2B5BE4);
  static const Color _lightBackground = Color(0xFFF1F5FF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF171A23);
  static const Color _lightSubtext = Color(0xFF747B8C);
  static const Color _ownerCard = Color(0xFFDCE7FF);

  final ListingService _listingService = ListingService();
  final ReviewService _reviewService = ReviewService();
  final ChatService _chatService = ChatService();

  late final PageController _pageController;
  late AdItem _adData;

  ListingModel? _listing;
  DateTime? _postedAt;
  DateTime _selectedDate = DateTime.now();

  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isLoadingDetails = false;
  bool _isLoadingReviews = false;
  String? _reviewLoadError;
  bool _isFavorite = false;

  List<String> _images = <String>[];
  String _fullDescription = '';
  List<Map<String, String>> _reviews = <Map<String, String>>[];
  List<AdItem> _similarListings = <AdItem>[];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _adData = widget.adData;
    _fullDescription = _adData.description.trim().isEmpty
        ? 'No description provided.'
        : _adData.description.trim();
    _images = <String>[_resolvedMainImage(_adData.image)];
    _loadDetails();
  }

  String _resolvedMainImage(String image) {
    final value = image.trim();
    return value.isEmpty ? 'assets/images/carpainter.jpg' : value;
  }

  Future<void> _loadDetails() async {
    if (_adData.id <= 0) return;

    setState(() => _isLoadingDetails = true);

    ListingModel? loadedListing;

    try {
      final listing = await _listingService.getListingById(_adData.id);
      loadedListing = listing;

      if (!mounted) return;

      final mappedAd = AdItem.fromListing(listing);

      setState(() {
        _listing = listing;
        _postedAt = listing.postedAt;
        _adData = mappedAd;
        _fullDescription = listing.description.trim().isEmpty
            ? 'No description provided.'
            : listing.description.trim();
        _images = <String>[
          _resolvedMainImage(
            listing.imageUrl.trim().isEmpty
                ? mappedAd.image
                : listing.imageUrl,
          ),
        ];
        _currentImageIndex = 0;
      });
    } catch (error, stackTrace) {
      debugPrint('Listing detail error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    final listingId = loadedListing?.id ?? _adData.id;

    // Reviews and similar listings are intentionally loaded independently.
    // A failure in the similar-listing API must not clear valid reviews.
    await Future.wait<void>(<Future<void>>[
      _loadReviews(listingId),
      if (loadedListing != null) _loadSimilarListings(loadedListing),
    ]);

    if (mounted) {
      setState(() => _isLoadingDetails = false);
    }
  }

  Future<void> _loadReviews(int listingId) async {
    if (listingId <= 0) return;

    if (mounted) {
      setState(() {
        _isLoadingReviews = true;
        _reviewLoadError = null;
      });
    }

    try {
      final rawReviews = await _reviewService.getReviews(
        listingId,
        limit: 50,
      );

      final mappedReviews = rawReviews
          .map<Map<String, String>>(_mapReview)
          .where((review) {
            final hasName = (review['name'] ?? '').trim().isNotEmpty;
            final hasComment = (review['comment'] ?? '').trim().isNotEmpty;
            final rating = double.tryParse(review['rating'] ?? '') ?? 0;
            return hasName || hasComment || rating > 0;
          })
          .toList();

      if (!mounted) return;

      setState(() {
        _reviews = mappedReviews;
        _isLoadingReviews = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Review loading error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoadingReviews = false;
        _reviewLoadError = 'Unable to load reviews.';
      });
    }
  }

  Future<void> _loadSimilarListings(ListingModel listing) async {
    try {
      final similar = await _listingService.searchListings(
        categoryId: listing.categoryId == 0 ? null : listing.categoryId,
        listingType:
            listing.listingType.isEmpty ? null : listing.listingType,
        limit: 10,
      );

      if (!mounted) return;

      setState(() {
        _similarListings = similar
            .where((item) => item.id != listing.id)
            .map(AdItem.fromListing)
            .take(8)
            .toList();
      });
    } catch (error, stackTrace) {
      debugPrint('Similar listing error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Map<String, String> _mapReview(dynamic review) {
    dynamic mapValue(List<String> keys) {
      if (review is! Map) return null;
      for (final key in keys) {
        final value = review[key];
        if (value != null) return value;
      }
      return null;
    }

    dynamic safeValue(dynamic Function() getter) {
      try {
        return getter();
      } catch (_) {
        return null;
      }
    }

    final rawName = review is Map
        ? mapValue(<String>['reviewerName', 'userName', 'name'])
        : safeValue(() => review.reviewerName);
    final rawComment = review is Map
        ? mapValue(<String>['comment', 'review', 'description'])
        : safeValue(() => review.comment);
    final rawRating = review is Map
        ? mapValue(<String>['rating', 'stars'])
        : safeValue(() => review.rating);
    final rawDate = review is Map
        ? mapValue(<String>['reviewedAt', 'createdAt', 'date'])
        : safeValue(() => review.reviewedAt);

    final name = rawName?.toString().trim() ?? '';
    final comment = rawComment?.toString().trim() ?? '';
    final rating = rawRating is num
        ? rawRating.toDouble()
        : double.tryParse(rawRating?.toString() ?? '') ?? 0;
    final parsedDate = _parseReviewDate(rawDate);

    return <String, String>{
      'name': name.isEmpty || name.toLowerCase() == 'null'
          ? 'RentIt24 User'
          : name,
      'date': parsedDate == null ? '' : _formatDate(parsedDate),
      'comment': comment.isEmpty || comment.toLowerCase() == 'null'
          ? 'No written comment.'
          : comment,
      'rating': rating.toStringAsFixed(1),
    };
  }

  DateTime? _parseReviewDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }

  int get _displayReviewCount {
    return _adData.reviews > _reviews.length
        ? _adData.reviews
        : _reviews.length;
  }

  double get _displayAverageRating {
    if (_adData.rating > 0) return _adData.rating;
    if (_reviews.isEmpty) return 0;

    final total = _reviews.fold<double>(0, (sum, review) {
      return sum + (double.tryParse(review['rating'] ?? '') ?? 0);
    });
    return total / _reviews.length;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _callNow() async {
    final phone = _adData.phone.trim();

    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Phone number is not available from the backend.',
            ),
          ),
        );
      }
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the phone app.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to make call: $error')),
        );
      }
    }
  }

  Future<void> _openChat() async {
    if (_adData.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This listing is not connected to a backend record.',
          ),
        ),
      );
      return;
    }

    try {
      final renterId = await SessionService.getUserId();
      final chatId = await _chatService.startChat(
        _adData.id,
        renterId: renterId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ChatDetailScreen(
            chatId: chatId,
            ownerId: _listing?.ownerId ?? 0,
            userName: _adData.owner,
            avatar: _adData.ownerAvatar,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _openSimilarProduct(AdItem ad) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailsScreen(adData: ad),
      ),
    );
  }

  Future<void> _openAllReviews() async {
    // When the user opens Reviews quickly, make sure the API request has
    // completed before passing the list to the next screen.
    if (_reviews.isEmpty && !_isLoadingReviews && _adData.id > 0) {
      await _loadReviews(_listing?.id ?? _adData.id);
    } else if (_isLoadingReviews) {
      while (_isLoadingReviews && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 80));
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => _AllReviewsScreen(
          reviews: List<Map<String, String>>.from(_reviews),
          averageRating: _displayAverageRating,
          totalReviews: _displayReviewCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : _lightBackground;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : _lightCard;
    final textColor = isDark ? Colors.white : _lightText;
    final subtitleColor = isDark ? Colors.white60 : _lightSubtext;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark),
      bottomNavigationBar: _buildBottomBar(isDark),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildImageCarousel(backgroundColor),
                _buildHeaderInfo(
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                ),
                _buildOwnerCard(
                  isDark: isDark,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                _buildDescription(
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                _buildSpecifications(
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                _buildAvailabilityCalendar(
                  isDark: isDark,
                  textColor: textColor,
                  cardColor: cardColor,
                ),
                _buildReviews(
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                ),
                _buildSimilarProducts(
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoadingDetails)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: _primaryBlue,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      toolbarHeight: 78,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _primaryBlue,
      leadingWidth: 48,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon:  Icon(
          Icons.arrow_back,
          color: isDark?Colors.black:Colors.white,
          size: 19,
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8B93A5),
                  size: 21,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Rent a "Car"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9AA1B1),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Color backgroundColor) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            SizedBox(
              height: 278,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _images.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemBuilder: (context, index) {
                  return _buildProductImage(
                    _images[index],
                    width: double.infinity,
                    height: 278,
                    borderRadius: BorderRadius.zero,
                  );
                },
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                children: <Widget>[
                  _buildFloatingImageAction(
                    icon: _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: () {
                      setState(() => _isFavorite = !_isFavorite);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFloatingImageAction(
                    icon: Icons.ios_share_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share action is ready for integration.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.48),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentImageIndex + 1}/${_images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 32,
          color: backgroundColor,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(
              _images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentImageIndex == index ? 22 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? _primaryBlue
                      : const Color(0xFFC8D5F8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingImageAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.43),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: <Widget>[
                    _buildBadge(
                      text: 'Featured',
                      backgroundColor: _primaryBlue,
                    ),
                    _buildBadge(
                      text: 'Top Choice',
                      backgroundColor:
                          isDark ? const Color(0xFF34343A) : const Color(0xFF151327),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _postedAt == null
                        ? 'Posted date unavailable'
                        : 'Posted on ${_formatDate(_postedAt!)}',
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC33A),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${_displayAverageRating.toStringAsFixed(1)} '
                        '(${_displayReviewCount} reviews)',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _adData.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _adData.price,
            style: TextStyle(
              color: textColor,
              fontSize: 21,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _adData.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOwnerCard({
    required bool isDark,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: isDark ? const Color(0xFF1C294C) : _ownerCard,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Row(
              children: <Widget>[
                _buildAvatar(
                  name: _adData.owner,
                  imageUrl: _adData.ownerAvatar,
                  radius: 19,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Service Provider',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _adData.owner.trim().isEmpty
                            ? 'RentIt24 Provider'
                            : _adData.owner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: isDark ? Colors.white70 : const Color(0xFF6D7587),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription({
    required Color textColor,
    required Color subtitleColor,
  }) {
    const previewLimit = 165;
    final needsToggle = _fullDescription.length > previewLimit;
    final displayText = !_isDescriptionExpanded && needsToggle
        ? '${_fullDescription.substring(0, previewLimit).trimRight()}...'
        : _fullDescription;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('Description', textColor),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
                children: <InlineSpan>[
                  TextSpan(text: displayText),
                  if (needsToggle)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Text(
                            _isDescriptionExpanded ? 'Show less' : 'Read more',
                            style: const TextStyle(
                              color: _primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildSpecifications({
    required Color textColor,
    required Color subtitleColor,
  }) {
    final listingType = _listing?.listingType.trim() ?? '';
    final category = _adData.category.trim();
    final provider = _adData.owner.trim();
    final phone = _adData.phone.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 19, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('Specifications', textColor),
          const SizedBox(height: 12),
          _buildSpecificationRow(
            label: 'Category',
            value: category.isEmpty ? 'Not specified' : category,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _buildSpecificationRow(
            label: 'Listing type',
            value: listingType.isEmpty ? 'Not specified' : listingType,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _buildSpecificationRow(
            label: 'Provider',
            value: provider.isEmpty ? 'RentIt24 Provider' : provider,
            textColor: textColor,
            subtitleColor: subtitleColor,
          ),
          _buildSpecificationRow(
            label: 'Contact',
            value: phone.isEmpty ? 'Available through chat' : phone,
            textColor: textColor,
            subtitleColor: subtitleColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow({
    required String label,
    required String value,
    required Color textColor,
    required Color subtitleColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCalendar({
    required bool isDark,
    required Color textColor,
    required Color cardColor,
  }) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final initialDate = _selectedDate.isBefore(firstDate)
        ? firstDate
        : _selectedDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('Availability', textColor),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark
                  ? const <BoxShadow>[]
                  : <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF243B70).withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: _primaryBlue,
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E1E1E),
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: _primaryBlue,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: _lightText,
                      ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryBlue,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: firstDate.add(const Duration(days: 365)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews({
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    final visibleReviews = _reviews.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _buildSectionTitle('Reviews', textColor),
              const SizedBox(width: 8),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC33A),
                size: 14,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '${_displayAverageRating.toStringAsFixed(1)} '
                  '(${_displayReviewCount} reviews)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openAllReviews,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          if (_isLoadingReviews && visibleReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryBlue,
                ),
              ),
            )
          else if (visibleReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                _reviewLoadError ?? 'No reviews yet.',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          else
            ...visibleReviews.map(
              (review) => _ReviewCard(
                review: review,
                cardColor: cardColor,
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: _isLoadingReviews ? null : _openAllReviews,
              style: TextButton.styleFrom(
                backgroundColor:
                    isDark ? const Color(0xFF1D2948) : const Color(0xFFDDE8FF),
                foregroundColor: _primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
              ),
              label: const Text(
                'Show more',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts({
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildSectionTitle('Similar Products', textColor),
                ),
                Text(
                  'See all',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_similarListings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'No similar products available.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 222,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _similarListings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final similarAd = _similarListings[index];
                  return _SimilarProductCard(
                    ad: similarAd,
                    cardColor: cardColor,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    isDark: isDark,
                    onTap: () => _openSimilarProduct(similarAd),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _buildBottomActionButton(
                icon: Icons.call_outlined,
                label: 'Call Now',
                onTap: _callNow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBottomActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                onTap: _openChat,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 46,
      child: Material(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAvatar({
    required String name,
    required String imageUrl,
    required double radius,
  }) {
    final trimmedUrl = imageUrl.trim();
    final initial = name.trim().isEmpty ? 'R' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8EEFF),
      backgroundImage:
          trimmedUrl.startsWith('http') ? NetworkImage(trimmedUrl) : null,
      child: trimmedUrl.startsWith('http')
          ? null
          : Text(
              initial,
              style: const TextStyle(
                color: _primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildProductImage(
    String source, {
    required double width,
    required double height,
    required BorderRadius borderRadius,
  }) {
    final isNetwork = source.startsWith('http');

    return ClipRRect(
      borderRadius: borderRadius,
      child: isNetwork
          ? Image.network(
              source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageError(width, height),
            )
          : Image.asset(
              source,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageError(width, height),
            ),
    );
  }

  Widget _imageError(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE5E9F2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9AA1B1),
        size: 38,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  static const Color _primaryBlue = Color(0xFF2B5BE4);

  final Map<String, String> review;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;

  const _ReviewCard({
    required this.review,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = review['name']?.trim().isNotEmpty == true
        ? review['name']!.trim()
        : 'RentIt24 User';
    final date = review['date'] ?? '';
    final comment = review['comment']?.trim().isNotEmpty == true
        ? review['comment']!.trim()
        : 'No written review.';
    final rating = review['rating'] ?? '0.0';
    final initial = name[0].toUpperCase();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 11, 11, 11),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF0F3FA),
        ),
        boxShadow: isDark
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF263B68).withOpacity(0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFE6EDFF),
            child: Text(
              initial,
              style: const TextStyle(
                color: _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (date.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              date,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryBlue,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _primaryBlue.withOpacity(0.22),
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFCB3F),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarProductCard extends StatelessWidget {
  static const Color _primaryBlue = Color(0xFF2B5BE4);

  final AdItem ad;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final bool isDark;
  final VoidCallback onTap;

  const _SimilarProductCard({
    required this.ad,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 145,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFEBEFF7),
              ),
              boxShadow: isDark
                  ? const <BoxShadow>[]
                  : <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF233866).withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    _productImage(ad.image),
                    Positioned(
                      left: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          ad.isFeatured ? 'Featured' : ad.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: Color(0xFF252A36),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          ad.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10.5,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ad.price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 8,
                              backgroundColor: const Color(0xFFE6EDFF),
                              child: Text(
                                ad.owner.trim().isEmpty
                                    ? 'R'
                                    : ad.owner.trim()[0].toUpperCase(),
                                style: const TextStyle(
                                  color: _primaryBlue,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                ad.owner.trim().isEmpty
                                    ? 'RentIt24'
                                    : ad.owner,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC33A),
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${ad.rating.toStringAsFixed(1)} '
                              '(${ad.reviews})',
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 8.5,
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
        ),
      ),
    );
  }

  Widget _productImage(String source) {
    final image = source.trim().isEmpty
        ? 'assets/images/carpainter.jpg'
        : source.trim();
    final isNetwork = image.startsWith('http');

    return SizedBox(
      width: double.infinity,
      height: 92,
      child: isNetwork
          ? Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageError(),
            )
          : Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageError(),
            ),
    );
  }

  Widget _imageError() {
    return Container(
      color: const Color(0xFFE5E9F2),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9AA1B1),
        size: 28,
      ),
    );
  }
}

class _AllReviewsScreen extends StatefulWidget {
  final List<Map<String, String>> reviews;
  final double averageRating;
  final int totalReviews;

  const _AllReviewsScreen({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  State<_AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<_AllReviewsScreen> {
  static const Color _primaryBlue = Color(0xFF2B5BE4);
  static const Color _lightBackground = Color(0xFFF1F5FF);
  static const Color _lightText = Color(0xFF171A23);
  static const Color _lightSubtext = Color(0xFF747B8C);

  int? _selectedRating;

  List<Map<String, String>> get _filteredReviews {
    if (_selectedRating == null) return widget.reviews;

    return widget.reviews.where((review) {
      final rating = double.tryParse(review['rating'] ?? '') ?? 0;
      return rating.round() == _selectedRating;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : _lightBackground;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : _lightText;
    final subtitleColor = isDark ? Colors.white60 : _lightSubtext;
    final filtered = _filteredReviews;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon:  Icon(Icons.arrow_back, size: 19,color: isDark?Colors.white:Colors.black,),
        ),
        titleSpacing: 0,
        title: Text(
          'Reviews',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            SizedBox(
              height:47 ,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: <Widget>[
                  _ratingChip(
                    label: 'All',
                    selected: _selectedRating == null,
                    onTap: () => setState(() => _selectedRating = null),
                  ),
                  for (int rating = 5; rating >= 1; rating--)
                    _ratingChip(
                      label: '$rating.0',
                      selected: _selectedRating == rating,
                      onTap: () => setState(() => _selectedRating = rating),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Reviews',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC33A),
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.averageRating.toStringAsFixed(1)} '
                        '(${widget.totalReviews} reviews)',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (filtered.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'No reviews for this rating.',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (review) => _ReviewCard(
                        review: review,
                        cardColor: cardColor,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        isDark: isDark,
                      ),
                    ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 46,
                    child: TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Review submission is ready for backend integration.',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF1D2948)
                            : const Color(0xFFDDE8FF),
                        foregroundColor: _primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Write a review',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _ratingChip({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  final bool isDark =
      Theme.of(context).brightness == Brightness.dark;

  final Color unselectedBackground = isDark
      ? const Color(0xFF1E1E1E)
      : const Color(0xFFF9FAFD);

  final Color unselectedContent = isDark
      ? Colors.white54
      : const Color(0xFF9AA1B1);

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 31,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? _primaryBlue : unselectedBackground,
            borderRadius: BorderRadius.circular(20),
            border: selected
                ? null
                : Border.all(
                    color: isDark
                        ? const Color(0xFF30333A)
                        : const Color(0xFFEEF1F6),
                    width: 0.8,
                  ),
            boxShadow: selected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x332B5BE4),
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.star_rounded,
                size: 13,
                color: selected
                    ? Colors.white
                    : unselectedContent,
              ),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : unselectedContent,
                  fontSize: 11,
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
