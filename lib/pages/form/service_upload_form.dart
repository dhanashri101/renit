import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentit24/core/theme.dart';
class ServiceUploadFlow extends StatefulWidget {
  const ServiceUploadFlow({super.key});

  @override
  State<ServiceUploadFlow> createState() => _ServiceUploadFlowState();
}

class _ServiceUploadFlowState extends State<ServiceUploadFlow> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  List<String> _imagePaths = [];

  String? _selectedCategory = 'Professional Services';
  String? _selectedSubCategory = 'Carpenter';

  String _profession = '';
  String _experience = '';
  String _skills = '';
  String _additionalDetails = '';

  String _productTitle = '';
  String _description = '';
  String _rentalPrice = '';
  String _rentalUnit = 'per day';
  bool _agreedToTerms = true;
  bool _agreedToPrivacy = true;

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

  void _onSubmit() {
    if (!_agreedToTerms || !_agreedToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to all terms and policies.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Service was not submitted because no verified professional-service/create-listing request schema and multipart contract is available.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _ServiceImageStep(
        key: const ValueKey(0),
        imagePaths: _imagePaths,
        onChanged: (paths) => setState(() => _imagePaths = paths),
      ),
      _SelectServiceCategoryStep(
        key: const ValueKey(1),
        selectedSubCategory: _selectedSubCategory,
        onSubCategoryChanged: (sub) =>
            setState(() => _selectedSubCategory = sub),
      ),
      _ProfessionalDetailsStep(
        key: const ValueKey(2),
        profession: _profession,
        experience: _experience,
        skills: _skills,
        additionalDetails: _additionalDetails,
        onProfessionChanged: (v) => setState(() => _profession = v),
        onExperienceChanged: (v) => setState(() => _experience = v),
        onSkillsChanged: (v) => setState(() => _skills = v),
        onAdditionalChanged: (v) => setState(() => _additionalDetails = v),
      ),
      _FinalServiceDetailsStep(
        key: const ValueKey(3),
        productTitle: _productTitle,
        description: _description,
        rentalPrice: _rentalPrice,
        rentalUnit: _rentalUnit,
        agreedToTerms: _agreedToTerms,
        agreedToPrivacy: _agreedToPrivacy,
        onTitleChanged: (v) => setState(() => _productTitle = v),
        onDescriptionChanged: (v) => setState(() => _description = v),
        onRentalPriceChanged: (v) => setState(() => _rentalPrice = v),
        onRentalUnitChanged: (v) =>
            setState(() => _rentalUnit = v ?? 'per day'),
        onTermsChanged: (v) => setState(() => _agreedToTerms = v ?? false),
        onPrivacyChanged: (v) => setState(() => _agreedToPrivacy = v ?? false),
      ),
    ];
    final stepTitles = [
      'Product Image',
      'Select Category',
      'Details',
      'Service Details',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: steps[_currentStep],
              ),
            ),
          ),
          _BottomButton(
            label: isLastStep ? 'Submit' : 'Continue',
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
              backgroundColor: AppTheme.primaryBlue ,
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


class _ServiceImageStep extends StatefulWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;

  const _ServiceImageStep({super.key, required this.imagePaths, required this.onChanged});

  @override
  State<_ServiceImageStep> createState() => _ServiceImageStepState();
}

class _ServiceImageStepState extends State<_ServiceImageStep> {
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
    final dashColor = isDark ? AppTheme.primaryBlue .withOpacity(0.5) : AppTheme.primaryBlue .withOpacity(0.3);

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

class _SelectServiceCategoryStep extends StatelessWidget {
  final String? selectedSubCategory;
  final ValueChanged<String?> onSubCategoryChanged;

  const _SelectServiceCategoryStep({
    super.key,
    required this.selectedSubCategory,
    required this.onSubCategoryChanged,
  });

  static const List<Map<String, dynamic>> _subCategories = [
    {'label': 'Doctor', 'icon': Icons.local_hospital},
    {'label': 'Nurse', 'icon': Icons.medical_services},
    {'label': 'CA', 'icon': Icons.person}, 
    {'label': 'Teacher', 'icon': Icons.cast_for_education},
    {'label': 'Carpenter', 'icon': Icons.handyman},
    {'label': 'Driver', 'icon': Icons.drive_eta},
    {'label': 'Plumber', 'icon': Icons.plumbing},
    {'label': 'Electrician', 'icon': Icons.electrical_services},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = AppTheme.primaryBlue ;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 20,
            childAspectRatio: 0.75, 
          ),
          itemCount: _subCategories.length,
          itemBuilder: (context, index) {
            final sub = _subCategories[index];
            final isSelected = selectedSubCategory == sub['label'];

            return GestureDetector(
              onTap: () => onSubCategoryChanged(sub['label']),
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
                      sub['icon'],
                      size: 32,
                      color: isDark ? Colors.blue[300] : const Color(0xFF1F54D3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sub['label'],
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
        ),
      ],
    );
  }
}


class _ProfessionalDetailsStep extends StatefulWidget {
  final String profession;
  final String experience;
  final String skills;
  final String additionalDetails;
  final ValueChanged<String> onProfessionChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onSkillsChanged;
  final ValueChanged<String> onAdditionalChanged;

  const _ProfessionalDetailsStep({
    super.key,
    required this.profession,
    required this.experience,
    required this.skills,
    required this.additionalDetails,
    required this.onProfessionChanged,
    required this.onExperienceChanged,
    required this.onSkillsChanged,
    required this.onAdditionalChanged,
  });

  @override
  State<_ProfessionalDetailsStep> createState() => _ProfessionalDetailsStepState();
}

class _ProfessionalDetailsStepState extends State<_ProfessionalDetailsStep> {
  late final TextEditingController _profCtrl;
  late final TextEditingController _expCtrl;
  late final TextEditingController _skillsCtrl;
  late final TextEditingController _addCtrl;

  @override
  void initState() {
    super.initState();
    _profCtrl = TextEditingController(text: widget.profession);
    _expCtrl = TextEditingController(text: widget.experience);
    _skillsCtrl = TextEditingController(text: widget.skills);
    _addCtrl = TextEditingController(text: widget.additionalDetails);
  }

  @override
  void dispose() {
    _profCtrl.dispose();
    _expCtrl.dispose();
    _skillsCtrl.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel('Profession'),
        const SizedBox(height: 6),
        _InputField(
          controller: _profCtrl,
          hint: 'e.g. Carpenter',
          onChanged: widget.onProfessionChanged,
        ),
        const SizedBox(height: 16),

        const _FormLabel('Experience'),
        const SizedBox(height: 6),
        _InputField(
          controller: _expCtrl,
          hint: 'e.g. 8 years',
          onChanged: widget.onExperienceChanged,
        ),
        const SizedBox(height: 16),

        const _FormLabel('Skills'),
        const SizedBox(height: 6),
        _InputField(
          controller: _skillsCtrl,
          hint: 'e.g. Modern Wood work, wood carving...',
          maxLines: 2,
          onChanged: widget.onSkillsChanged,
        ),
        const SizedBox(height: 16),

        const _FormLabel('Additional Details'),
        const SizedBox(height: 6),
        _InputField(
          controller: _addCtrl,
          hint: 'Some more information if needed',
          maxLines: 4,
          onChanged: widget.onAdditionalChanged,
        ),
      ],
    );
  }
}


class _FinalServiceDetailsStep extends StatefulWidget {
  final String productTitle;
  final String description;
  final String rentalPrice;
  final String rentalUnit;
  final bool agreedToTerms;
  final bool agreedToPrivacy;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<String> onRentalPriceChanged;
  final ValueChanged<String?> onRentalUnitChanged;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<bool?> onPrivacyChanged;

  const _FinalServiceDetailsStep({
    super.key,
    required this.productTitle,
    required this.description,
    required this.rentalPrice,
    required this.rentalUnit,
    required this.agreedToTerms,
    required this.agreedToPrivacy,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
    required this.onRentalPriceChanged,
    required this.onRentalUnitChanged,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
  });

  @override
  State<_FinalServiceDetailsStep> createState() => _FinalServiceDetailsStepState();
}

class _FinalServiceDetailsStepState extends State<_FinalServiceDetailsStep> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  static const List<String> _rentalUnits = ['per day', 'per hour', 'per project'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.productTitle);
    _descCtrl = TextEditingController(text: widget.description);
    _priceCtrl = TextEditingController(text: widget.rentalPrice);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel('Product name/title', isRequired: true),
        const SizedBox(height: 6),
        _InputField(
          controller: _titleCtrl,
          hint: 'e.g. Wood work and wood carving',
          onChanged: widget.onTitleChanged,
        ),
        const SizedBox(height: 16),

        const _FormLabel('Description'),
        const SizedBox(height: 6),
        _InputField(
          controller: _descCtrl,
          hint: 'Meet Ravi, a skilled carpenter...',
          maxLines: 5,
          onChanged: widget.onDescriptionChanged,
        ),
        const SizedBox(height: 16),

        const _FormLabel('Rental Price', isRequired: true),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _InputField(
                controller: _priceCtrl,
                hint: '₹ 800',
                keyboardType: TextInputType.number,
                onChanged: widget.onRentalPriceChanged,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.rentalUnit,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  items: _rentalUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: widget.onRentalUnitChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _AgreementCheckbox(
          value: widget.agreedToTerms,
          onChanged: widget.onTermsChanged,
          text: 'I read and agree to the ',
          linkText: 'terms and conditions',
        ),
        const SizedBox(height: 8),
        _AgreementCheckbox(
          value: widget.agreedToPrivacy,
          onChanged: widget.onPrivacyChanged,
          text: 'I read and agree to the ',
          linkText: 'privacy policy',
        ),
      ],
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final String linkText;

  const _AgreementCheckbox({
    required this.value,
    required this.onChanged,
    required this.text,
    required this.linkText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue ,
            side: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.black87,
              ),
              children: [
                TextSpan(
                  text: linkText,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue ,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}