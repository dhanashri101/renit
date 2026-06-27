import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ServiceUploadFlow extends StatefulWidget {
  const ServiceUploadFlow({super.key});

  @override
  State<ServiceUploadFlow> createState() => _ServiceUploadFlowState();
}

class _ServiceUploadFlowState extends State<ServiceUploadFlow> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1: Images
  List<String> _imagePaths = [];
  
  // Step 2: Categories
  String? _selectedCategory = 'Professional Services';
  String? _selectedSubCategory = 'Carpenter';

  // Step 3: Details
  String _profession = '';
  String _experience = '';
  String _skills = '';
  String _additionalDetails = '';

  // Step 4: Service Details
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
      const SnackBar(content: Text('Service listed successfully!')),
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
        selectedCategory: _selectedCategory,
        selectedSubCategory: _selectedSubCategory,
        onCategoryChanged: (cat) => setState(() {
          _selectedCategory = cat;
          _selectedSubCategory = null;
        }),
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
    
    // Replace with AppTheme.darkBackground / lightBackground if needed
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

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
                        ? const Color(0xFF2F6BFF)
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              // Smooth transition between steps
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

// --- SHARED WIDGETS ---

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
              backgroundColor: const Color(0xFF2F6BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Pill shape as per UI
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

// --- STEP 1: IMAGE UPLOAD ---

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

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null && widget.imagePaths.length < 10) {
        final updated = List<String>.from(widget.imagePaths)..add(image.path);
        widget.onChanged(updated);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dashColor = isDark ? const Color(0xFF2F6BFF).withOpacity(0.5) : const Color(0xFF2F6BFF).withOpacity(0.3);

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
        
        // Dashed dropzone simulation
        GestureDetector(
          onTap: _isPicking ? null : () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              // Note: Using a solid border here to avoid needing external packages like dotted_border. 
              // To get true dashes, use `dotted_border` package in your pubspec.
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
            onPressed: _isPicking ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: const Text('Open Camera & Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F6BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // Pill shape
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

// --- STEP 2: CATEGORY ---

class _SelectServiceCategoryStep extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedSubCategory;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSubCategoryChanged;

  const _SelectServiceCategoryStep({
    super.key,
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  static const List<Map<String, dynamic>> _mainCategories = [
    {'label': 'Baby Kids', 'icon': Icons.child_care},
    {'label': 'Electronics', 'icon': Icons.devices},
    {'label': 'Furniture', 'icon': Icons.chair_alt},
    {'label': 'Professional\nServices', 'icon': Icons.engineering},
    {'label': 'Trading/\nMachinery', 'icon': Icons.precision_manufacturing},
  ];

  static const List<Map<String, dynamic>> _subCategories = [
    {'label': 'Doctor', 'icon': Icons.local_hospital},
    {'label': 'Nurse', 'icon': Icons.medical_services},
    {'label': 'CA', 'icon': Icons.calculate},
    {'label': 'Teacher', 'icon': Icons.school},
    {'label': 'Carpenter', 'icon': Icons.handyman},
    {'label': 'Driver', 'icon': Icons.directions_car},
    {'label': 'Plumber', 'icon': Icons.plumbing},
    {'label': 'Electrician', 'icon': Icons.electrical_services},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = const Color(0xFF2F6BFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Main Categories
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _mainCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = _mainCategories[index];
              final isSelected = selectedCategory == cat['label'].replaceAll('\n', ' ');
              
              return GestureDetector(
                onTap: () => onCategoryChanged(cat['label'].replaceAll('\n', ' ')),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? blue.withOpacity(0.1) 
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? blue : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        cat['icon'],
                        color: isSelected 
                            ? blue 
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected 
                            ? blue 
                            : (isDark ? Colors.grey[400] : Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, color: Colors.grey),
        ),

        // Subcategories Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
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
                      ? blue.withOpacity(0.15) 
                      : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? blue : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sub['icon'],
                      size: 28,
                      color: isSelected 
                          ? blue 
                          : (isDark ? Colors.blue[200] : blue), // Based on UI screenshot
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sub['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

// --- STEP 3: DETAILS ---

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

// --- STEP 4: SERVICE DETAILS ---

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
    final blue = const Color(0xFF2F6BFF);
    
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
              height: 48, // Match input field height
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
        
        // Custom Checkboxes to match UI precisely
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
            activeColor: const Color(0xFF2F6BFF),
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
                    color: Color(0xFF2F6BFF),
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