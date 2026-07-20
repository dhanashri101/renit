import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/model/category_model.dart';
import 'package:rentit24/model/listing_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/category_services.dart';
import 'package:rentit24/services/listing_services.dart';
import 'package:rentit24/services/local_area_service.dart';
import 'package:rentit24/services/media_service.dart';
import 'package:rentit24/services/session_service.dart';

class ProductListingFlow extends StatefulWidget {
  const ProductListingFlow({super.key});

  @override
  State<ProductListingFlow> createState() => _ProductListingFlowState();
}

class _ProductListingFlowState extends State<ProductListingFlow> {
  int _currentStep = 0;
  final int _totalSteps = 4;
  List<String> _imagePaths = [];
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _brand;
  String? _modelName;
  String? _color;
  String _additionalDetails = '';
  String _productName = '';
  String _description = '';
  String _rentalPrice = '';
  String _rentalUnit = 'per day';
  String _securityDeposit = '';
  DateTime? _availableFrom;
  bool _isSubmitting = false;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (_productName.trim().isEmpty ||
        _rentalPrice.trim().isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the required product details.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final categories = await CategoryService().getAllCategories();
      final parent = _resolveBackendCategory(
        categories,
        _selectedCategory!,
      );
      final child = parent == null
          ? null
          : _firstWhereOrNull(
              categories,
              (item) =>
                  item.parentId == parent.id &&
                  _normaliseCategory(item.name) ==
                      _normaliseCategory(_selectedSubCategory ?? ''),
            );
      if (parent == null) {
        throw const ApiException(
          type: ApiErrorType.validation,
          message: 'Selected category is not available on the backend.',
        );
      }

      final ownerId = await SessionService.getUserId();
      final areaId = await SessionService.getAreaId();
      final area = await LocalAreaService().getById(areaId);
      final uploaded = await MediaService().uploadFiles(
        _imagePaths,
        category: 'user',
        userId: ownerId,
      );

      final details = <String>[
        _additionalDetails.trim(),
        if (_availableFrom != null) 'Available from: ${_availableFrom!.toIso8601String()}',
        if (uploaded.isNotEmpty) 'Uploaded media: ${uploaded.join(', ')}',
      ].where((item) => item.isNotEmpty).join('\n');

      final listingId = await ListingService().createListing(
        ListingModel(
          ownerId: ownerId,
          listingType: 'product',
          title: _productName.trim(),
          description: _description.trim(),
          categoryId: parent.id,
          subcategoryId: child?.id ?? 0,
          rentalPrice: double.tryParse(_rentalPrice.trim()) ?? 0,
          priceUnit: _rentalUnit.replaceFirst('per ', '').trim(),
          securityDeposit: double.tryParse(_securityDeposit.trim()) ?? 0,
          brand: _brand?.trim() ?? '',
          modelName: _modelName?.trim() ?? '',
          color: _color?.trim() ?? '',
          additionalDetails: details,
          localAreaId: area.id,
          address: area.displayName,
          latitude: area.latitude,
          longitude: area.longitude,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            listingId > 0
                ? 'Product submitted successfully. Listing #$listingId is pending approval.'
                : 'Product submitted successfully and is pending approval.',
          ),
        ),
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to submit product: $error')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _UploadImageStep(
        imagePaths: _imagePaths,
        onChanged: (paths) => setState(() => _imagePaths = paths),
      ),
      _SelectCategoryStep(
        selectedCategory: _selectedCategory,
        selectedSubCategory: _selectedSubCategory,
        onSubCategoryChanged: (sub) =>
            setState(() => _selectedSubCategory = sub),
      ),
      _SpecificationsStep(
        brand: _brand,
        modelName: _modelName,
        color: _color,
        additionalDetails: _additionalDetails,
        onBrandChanged: (v) => setState(() => _brand = v),
        onModelChanged: (v) => setState(() => _modelName = v),
        onColorChanged: (v) => setState(() => _color = v),
        onAdditionalChanged: (v) => setState(() => _additionalDetails = v),
      ),
      _ProductDetailsStep(
        productName: _productName,
        description: _description,
        rentalPrice: _rentalPrice,
        rentalUnit: _rentalUnit,
        securityDeposit: _securityDeposit,
        availableFrom: _availableFrom,
        onProductNameChanged: (v) => setState(() => _productName = v),
        onDescriptionChanged: (v) => setState(() => _description = v),
        onRentalPriceChanged: (v) => setState(() => _rentalPrice = v),
        onRentalUnitChanged: (v) =>
            setState(() => _rentalUnit = v ?? 'per day'),
        onSecurityDepositChanged: (v) => setState(() => _securityDeposit = v),
        onAvailableFromChanged: (d) => setState(() => _availableFrom = d),
      ),
    ];

    final stepTitles = [
      'Product Image',
      'Select Category',
      'Specifications',
      'Product Details',
    ];

    final isLastStep = _currentStep == _totalSteps - 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          backgroundColor: bgColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _prevStep,
          ),
          titleSpacing: 0,
          title: Text(
            stepTitles[_currentStep],
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Row(
              children: List.generate(_totalSteps, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    color: index <= _currentStep
                        ? AppTheme.primaryBlue
                        : (isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFDCE5F8)),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_currentStep == 1)
            _MainCategoryBar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) => setState(() {
                _selectedCategory = cat;
                _selectedSubCategory = null;
              }),
            ),
         Expanded(
  child: SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      16,
      _currentStep == 1 ? 0 : 20, // No top padding on category page
      16,
      20,
    ),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: steps[_currentStep],
    ),
  ),
),
          _BottomButton(
            label: isLastStep && _isSubmitting ? 'Submitting...' : (isLastStep ? 'Submit' : 'Continue'),
            onPressed: isLastStep ? _onSubmit : _nextStep,
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BottomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const _FormLabel(this.text, {this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE5E7EB);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          isExpanded: true,
          dropdownColor: surfaceColor,
          iconEnabledColor: Colors.grey[500],
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _UploadImageStep extends StatefulWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;

  const _UploadImageStep({required this.imagePaths, required this.onChanged});

  @override
  State<_UploadImageStep> createState() => _UploadImageStepState();
}

class _UploadImageStepState extends State<_UploadImageStep> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickGalleryImages() async {
    if (widget.imagePaths.length >= 10) {
      _showLimitMessage();
      return;
    }

    setState(() => _isPicking = true);
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        final availableSlots = 10 - widget.imagePaths.length;

        final selectedPaths = images.take(availableSlots).map((e) => e.path).toList();
        final updated = List<String>.from(widget.imagePaths)..addAll(selectedPaths);

        widget.onChanged(updated);

        if (images.length > availableSlots && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 10 images allowed. Extra images were discarded.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Future<void> _pickCameraImage() async {
    if (widget.imagePaths.length >= 10) {
      _showLimitMessage();
      return;
    }

    setState(() => _isPicking = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final updated = List<String>.from(widget.imagePaths)..add(image.path);
        widget.onChanged(updated);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  void _showLimitMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can only upload up to 10 images.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dashColor = isDark ? AppTheme.primaryBlue.withOpacity(0.5) : AppTheme.primaryBlue.withOpacity(0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel('Upload product images', isRequired: true),
        const SizedBox(height: 6),
        Text(
          'Add your product images here. You can add a maximum of 10 files. Please add clear photos.',
          style: TextStyle(fontSize: 12, color: hintColor),
        ),
        const SizedBox(height: 24),

        GestureDetector(
          onTap: _isPicking ? null : () => _pickGalleryImages(),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: dashColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isPicking)
                  const CircularProgressIndicator(strokeWidth: 2)
                else ...[
                  Icon(Icons.image_outlined, size: 32, color: hintColor),
                  const SizedBox(height: 8),
                  Text(
                    'Select file',
                    style: TextStyle(color: hintColor, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text('or', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isPicking ? null : () => _pickCameraImage(),
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: const Text('Open Camera & Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue ,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (widget.imagePaths.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        final updated = List<String>.from(widget.imagePaths)..removeAt(index);
                        widget.onChanged(updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove_circle, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _CategoryData {
  final String label;
  final String asset;
  const _CategoryData(this.label, this.asset);
}

class _MainCategoryBar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const _MainCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  static const List<_CategoryData> _mainCategories = [
    _CategoryData('Agriculture Farming', 'agriculture-farming'),
    _CategoryData('Appliances', 'appliances'),
    _CategoryData('Baby Kids', 'baby-kids'),
    _CategoryData('Beauty Grooming', 'beauty-grooming'),
    _CategoryData('Books Stationery', 'books-stationery'),
    _CategoryData('Community NGO', 'community-ngo'),
    _CategoryData('Construction Heavy Machinery', 'construction-heavy-machinery'),
    _CategoryData('Coworking Business', 'coworking-business'),
    _CategoryData('Delivery Logistics', 'delivery-logistics'),
    _CategoryData('Digital Tech Services', 'digital-tech-services'),
    _CategoryData('Education', 'education'),
    _CategoryData('Electronics', 'electronics'),
    _CategoryData('Event Professionals', 'event-professionals'),
    _CategoryData('Events Parties', 'events-parties'),
    _CategoryData('Fashion Dress', 'fashion-dress'),
    _CategoryData('Fashion Services', 'fashion-services'),
    _CategoryData('Festivals Celebrations', 'festivals-celebrations'),
    _CategoryData('Food Catering', 'food-catering'),
    _CategoryData('Furniture', 'furniture'),
    _CategoryData('Gaming Consoles', 'gaming-consoles'),
    _CategoryData('Gardening Outdoor', 'gardening-outdoor'),
    _CategoryData('Health Wellness', 'health-wellness'),
    _CategoryData('Household Items', 'household-items'),
    _CategoryData('Medical Equipment', 'medical-equipment'),
    _CategoryData('Miscellaneous', 'miscellaneous'),
    _CategoryData('Musical Instruments', 'musical-instruments'),
    _CategoryData('Office Work Equipment', 'office-work-equipment'),
    _CategoryData('Pets Animals', 'pets-animals'),
    _CategoryData('Professional Services', 'professional-services'),
    _CategoryData('Real Estate', 'real-estate'),
    _CategoryData('Security Services', 'security-services'),
    _CategoryData('Seasonal Needs', 'sesonal-needs'),
    _CategoryData('Sports Fitness', 'sports-fitness'),
    _CategoryData('Tools Machinery', 'tools-machinery'),
    _CategoryData('Transportation Services', 'transportation-services'),
    _CategoryData('Travel Hospitality', 'travel-hospitality'),
    _CategoryData('Travel Outdoors', 'travel-outdoors'),
    _CategoryData('Vehicles', 'vehicles'),
    _CategoryData('Wedding Photography', 'wedding-photography'),
  ];

  static const List<double> _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = AppTheme.primaryBlue; 
    
    final barBgColor = isDark ? const Color(0xFF121212) : Colors.white;
    
    final selectedBgColor = isDark ? blue.withOpacity(0.15) : const Color(0xFFF0F4FF);

    return Container(
      height: 95, 
      width: double.infinity,
      color: barBgColor, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _mainCategories.length,
        itemBuilder: (context, index) {
          final cat = _mainCategories[index];
          final isSelected = selectedCategory == cat.label;
          final assetPath = 'assets/images/categories/${cat.asset}.png';

          final icon = Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.category_outlined,
              size: 24,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          );

          return GestureDetector(
            behavior: HitTestBehavior.opaque, 
            onTap: () => onCategoryChanged(isSelected ? null : cat.label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 85, 
              margin: const EdgeInsets.symmetric(horizontal: 2), 
              decoration: BoxDecoration(

                color: isSelected ? selectedBgColor : Colors.transparent,
                // borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 32, 
                    width: 32,
                    child: isSelected
                        ? icon
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                            child: Opacity(
                              opacity: 0.7, 
                              child: icon,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12, 
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF2C3E50)) 
                          : (isDark ? Colors.grey[500] : Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 6), 
                                    AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 4,
                    width: 40, 
                    decoration: BoxDecoration(
                      color: isSelected ? blue : Colors.transparent, 
                      borderRadius: BorderRadius.circular(4), 
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class _SelectCategoryStep extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedSubCategory;
  final ValueChanged<String?> onSubCategoryChanged;

  const _SelectCategoryStep({
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onSubCategoryChanged,
  });

 static const Map<String, List<_CategoryItem>> _subCategories = {
    'Agriculture Farming': [
      _CategoryItem('Tractors', Icons.agriculture),
      _CategoryItem('Seeds', Icons.grass),
      _CategoryItem('Fertilizers', Icons.eco),
      _CategoryItem('Tools', Icons.hardware),
    ],
    'Appliances': [
      _CategoryItem('Microwave', Icons.microwave),
      _CategoryItem('Fridge', Icons.kitchen),
      _CategoryItem('AC', Icons.ac_unit),
      _CategoryItem('Washing Machine', Icons.local_laundry_service),
    ],
    'Baby Kids': [
      _CategoryItem('Toys', Icons.toys),
      _CategoryItem('Strollers', Icons.child_friendly),
      _CategoryItem('Clothing', Icons.checkroom),
    ],

    'Electronics': [
      _CategoryItem('Laptop', Icons.laptop),
      _CategoryItem('Desktop', Icons.desktop_windows),
      _CategoryItem('Headphones', Icons.headphones),
      _CategoryItem('Speaker', Icons.speaker),
    ],
    'Mobile': [
      _CategoryItem('Android', Icons.android),
      _CategoryItem('iPhone', Icons.phone_iphone),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final List<_CategoryItem> subItems = selectedCategory != null
        ? (_subCategories[selectedCategory] ?? [])
        : [];

    if (subItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _CategoryGrid(
      items: subItems,
      selected: selectedSubCategory,
      onTap: onSubCategoryChanged,
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  const _CategoryItem(this.label, this.icon);
}

class _CategoryGrid extends StatelessWidget {
  final List<_CategoryItem> items;
  final String? selected;
  final ValueChanged<String?> onTap;

  const _CategoryGrid({
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = AppTheme.primaryBlue;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75, 
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selected == item.label;

        return GestureDetector(
          onTap: () => onTap(item.label),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? blue.withOpacity(0.2) : const Color(0xFFDFE6F9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 32,
                  color: isDark ? Colors.blue[300] : const Color(0xFF1F54D3),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SpecificationsStep extends StatefulWidget {
  final String? brand;
  final String? modelName;
  final String? color;
  final String additionalDetails;
  final ValueChanged<String?> onBrandChanged;
  final ValueChanged<String> onModelChanged;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String> onAdditionalChanged;

  const _SpecificationsStep({
    required this.brand,
    required this.modelName,
    required this.color,
    required this.additionalDetails,
    required this.onBrandChanged,
    required this.onModelChanged,
    required this.onColorChanged,
    required this.onAdditionalChanged,
  });

  @override
  State<_SpecificationsStep> createState() => _SpecificationsStepState();
}

class _SpecificationsStepState extends State<_SpecificationsStep> {
  late final TextEditingController _modelCtrl;
  late final TextEditingController _additionalCtrl;

  static const List<String> _brands = [
    'Canon',
    'Sony',
    'Nikon',
    'Fujifilm',
    'Panasonic',
    'Olympus',
    'Leica',
    'Apple',
    'Samsung',
    'Dell',
    'HP',
    'Lenovo',
    'Asus',
    'Acer',
    'Other',
  ];

  static const List<String> _colors = [
    'Black',
    'White',
    'Silver',
    'Gold',
    'Blue',
    'Red',
    'Green',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _modelCtrl = TextEditingController(text: widget.modelName ?? '');
    _additionalCtrl = TextEditingController(text: widget.additionalDetails);
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _additionalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel('Brand'),
        const SizedBox(height: 6),
        _DropdownField<String>(
          value: widget.brand,
          hint: 'Not selected',
          items: _brands,
          onChanged: widget.onBrandChanged,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Model Name'),
        const SizedBox(height: 6),
        _InputField(
          controller: _modelCtrl,
          hint: 'e.g. EOS M50 Mark II',
          onChanged: widget.onModelChanged,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Color'),
        const SizedBox(height: 6),
        _DropdownField<String>(
          value: widget.color,
          hint: 'Not selected',
          items: _colors,
          onChanged: widget.onColorChanged,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Additional Details'),
        const SizedBox(height: 6),
        _InputField(
          controller: _additionalCtrl,
          hint: 'Input additional details',
          onChanged: widget.onAdditionalChanged,
          maxLines: 4,
        ),
        if (widget.additionalDetails.isNotEmpty) ...[
          const SizedBox(height: 8),
          _BulletList(text: widget.additionalDetails),
        ],
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final String text;
  const _BulletList({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(l, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductDetailsStep extends StatefulWidget {
  final String productName;
  final String description;
  final String rentalPrice;
  final String rentalUnit;
  final String securityDeposit;
  final DateTime? availableFrom;
  final ValueChanged<String> onProductNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onRentalPriceChanged;
  final ValueChanged<String?> onRentalUnitChanged;
  final ValueChanged<String> onSecurityDepositChanged;
  final ValueChanged<DateTime?> onAvailableFromChanged;

  const _ProductDetailsStep({
    required this.productName,
    required this.description,
    required this.rentalPrice,
    required this.rentalUnit,
    required this.securityDeposit,
    required this.availableFrom,
    required this.onProductNameChanged,
    required this.onDescriptionChanged,
    required this.onRentalPriceChanged,
    required this.onRentalUnitChanged,
    required this.onSecurityDepositChanged,
    required this.onAvailableFromChanged,
  });

  @override
  State<_ProductDetailsStep> createState() => _ProductDetailsStepState();
}

class _ProductDetailsStepState extends State<_ProductDetailsStep> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _depositCtrl;

  static const List<String> _rentalUnits = ['per day', 'per week', 'per month'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.productName);
    _descCtrl = TextEditingController(text: widget.description);
    _priceCtrl = TextEditingController(text: widget.rentalPrice);
    _depositCtrl = TextEditingController(text: widget.securityDeposit);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.availableFrom ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) widget.onAvailableFromChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel('Product name/Title', isRequired: true),
        const SizedBox(height: 6),
        _InputField(
          controller: _nameCtrl,
          hint: 'e.g. Canon EOS M50 Mark II mirrorless',
          onChanged: widget.onProductNameChanged,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Description'),
        const SizedBox(height: 6),
        _InputField(
          controller: _descCtrl,
          hint: 'Add a description of your product',
          onChanged: widget.onDescriptionChanged,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Rental Price', isRequired: true),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _InputField(
                controller: _priceCtrl,
                hint: '₹0.00',
                onChanged: widget.onRentalPriceChanged,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: _DropdownField<String>(
                value: widget.rentalUnit,
                hint: 'per day',
                items: _rentalUnits,
                onChanged: widget.onRentalUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _FormLabel('Security Deposit'),
        const SizedBox(height: 6),
        _InputField(
          controller: _depositCtrl,
          hint: '₹0.00',
          onChanged: widget.onSecurityDepositChanged,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        const _FormLabel('Available From'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.availableFrom != null
                        ? '${widget.availableFrom!.day} ${_monthName(widget.availableFrom!.month)} ${widget.availableFrom!.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.availableFrom != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey[500],
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m];
  }
}


String _normaliseCategory(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

CategoryModel? _resolveBackendCategory(
  List<CategoryModel> categories,
  String selectedLabel,
) {
  final normalized = _normaliseCategory(selectedLabel);
  const aliases = <String, String>{
    'babykids': 'Baby & Kids',
    'beautygrooming': 'Beauty & Grooming',
    'petsanimals': 'Pets Care Services',
    'toolsmachinery': 'Tools & Machinery',
    'constructionheavymachinery': 'Tools & Machinery',
    'transportationservices': 'Transport Services',
    'deliverylogistics': 'Transport Services',
    'fashiondress': 'Fashion Services',
    'weddingphotography': 'Event Professionals',
    'eventsparties': 'Event Professionals',
    'foodcatering': 'Event Professionals',
    'education': 'Professional Services',
    'digitaltechservices': 'Professional Services',
    'securityservices': 'Professional Services',
    'healthwellness': 'Professional Services',
    'sportsfitness': 'Professional Services',
    'agriculturefarming': 'Tools & Machinery',
    'gardeningoutdoor': 'Tools & Machinery',
    'householditems': 'Furniture',
    'officeworkequipment': 'Furniture',
    'gamingconsoles': 'Electronics',
    'musicalinstruments': 'Electronics',
  };
  final expected = _normaliseCategory(aliases[normalized] ?? selectedLabel);
  return _firstWhereOrNull(
    categories,
    (item) => item.parentId == null && _normaliseCategory(item.name) == expected,
  );
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
