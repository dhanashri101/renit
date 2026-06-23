import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentit24/core/theme.dart';

class ProductListingFlow extends StatefulWidget {
  const ProductListingFlow({super.key});

  @override
  State<ProductListingFlow> createState() => _ProductListingFlowState();
}

class _ProductListingFlowState extends State<ProductListingFlow> {
  int _currentStep = 0;
  final int _totalSteps = 4;

  List<String> _imagePaths = []; // simulated paths
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

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _onSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product listed successfully!')),
    );
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
        onCategoryChanged: (cat) => setState(() {
          _selectedCategory = cat;
          _selectedSubCategory = null;
        }),
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

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
        title: Text(stepTitles[_currentStep]),
      ),
      body: Column(
        children: [
          // ── Step progress indicator ──
          _StepProgressBar(current: _currentStep, total: _totalSteps),
          // ── Step content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: steps[_currentStep],
            ),
          ),
          // ── Bottom button (sticky) ──
          _BottomButton(
            label: isLastStep ? 'Submit' : 'Continue',
            onPressed: isLastStep ? _onSubmit : _nextStep,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STEP PROGRESS BAR
// ─────────────────────────────────────────────
class _StepProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _StepProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final blue = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactive = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDDE3F0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i <= current;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? blue : inactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM BUTTON
// ─────────────────────────────────────────────
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white; // Adjust to your AppTheme
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFDDE3F0);
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[400];
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'Upload product images*',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add photos of your item — you can add a maximum of 5 photos.',
          style: TextStyle(fontSize: 12, color: hintColor),
        ),
        const SizedBox(height: 16),

        // ── Main upload area (Gallery) ──
        GestureDetector(
          onTap: _isPicking ? null : () => _pickImage(ImageSource.gallery),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border.all(
                color: _isPicking ? primaryColor : borderColor,
                style: BorderStyle.solid,
                width: _isPicking ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isPicking)
                  const CircularProgressIndicator(strokeWidth: 2)
                else ...[
                  Icon(Icons.cloud_upload_outlined, size: 40, color: hintColor),
                  const SizedBox(height: 8),
                  Text(
                    'Select from Gallery',
                    style: TextStyle(color: hintColor, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Camera button ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isPicking ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Open Camera & Take Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Thumbnails Grid ──
        if (widget.imagePaths.isNotEmpty) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFEEF2FF),
                                child: Icon(
                                  Icons.broken_image,
                                  color: hintColor,
                                ),
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () {
                          final updated = List<String>.from(widget.imagePaths)
                            ..removeAt(index);
                          widget.onChanged(updated);
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STEP 2 – SELECT CATEGORY
// ─────────────────────────────────────────────
class _SelectCategoryStep extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedSubCategory;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onSubCategoryChanged;

  const _SelectCategoryStep({
    required this.selectedCategory,
    required this.selectedSubCategory,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
  });

  static const List<_CategoryItem> _categories = [
    _CategoryItem('Electronics', Icons.devices_other),
    _CategoryItem('Mobile', Icons.smartphone),
    _CategoryItem('Tablet', Icons.tablet),
    _CategoryItem('TV', Icons.tv),
    _CategoryItem('Projector', Icons.videocam_outlined),
    _CategoryItem('Camera', Icons.camera_alt_outlined),
  ];

  static const Map<String, List<_CategoryItem>> _subCategories = {
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
    'Tablet': [
      _CategoryItem('iPad', Icons.tablet_mac),
      _CategoryItem('Android Tab', Icons.tablet_android),
    ],
    'Camera': [
      _CategoryItem('DSLR', Icons.camera),
      _CategoryItem('Mirrorless', Icons.camera_enhance),
      _CategoryItem('Action Cam', Icons.videocam),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Explicitly add the type annotation here:
    final List<_CategoryItem> subItems = selectedCategory != null
        ? (_subCategories[selectedCategory] ?? [])
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _CategoryGrid(
          items: _categories,
          selected: selectedCategory,
          onTap: onCategoryChanged,
        ),
        if (subItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          _CategoryGrid(
            items: subItems,
            selected: selectedSubCategory,
            onTap: onSubCategoryChanged,
          ),
        ],
      ],
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
    final blue = Theme.of(context).colorScheme.primary;
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFDDE3F0);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: items.map((item) {
        final isSelected = selected == item.label;
        return GestureDetector(
          onTap: () => onTap(isSelected ? null : item.label),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? blue.withOpacity(0.12) : surfaceColor,
              border: Border.all(
                color: isSelected ? blue : borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 26,
                  color: isSelected
                      ? blue
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected
                        ? blue
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// STEP 3 – SPECIFICATIONS
// ─────────────────────────────────────────────
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _FormLabel('Brand'),
        const SizedBox(height: 6),
        _DropdownField<String>(
          value: widget.brand,
          hint: 'Not selected',
          items: _brands,
          onChanged: widget.onBrandChanged,
        ),
        const SizedBox(height: 16),
        _FormLabel('Model Name'),
        const SizedBox(height: 6),
        _InputField(
          controller: _modelCtrl,
          hint: 'e.g. EOS M50 Mark II',
          onChanged: widget.onModelChanged,
        ),
        const SizedBox(height: 16),
        _FormLabel('Color'),
        const SizedBox(height: 6),
        _DropdownField<String>(
          value: widget.color,
          hint: 'Not selected',
          items: _colors,
          onChanged: widget.onColorChanged,
        ),
        const SizedBox(height: 16),
        _FormLabel('Additional Details'),
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

// ─────────────────────────────────────────────
// STEP 4 – PRODUCT DETAILS
// ─────────────────────────────────────────────
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
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFDDE3F0);
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _FormLabel('Product name/Title*'),
        const SizedBox(height: 6),
        _InputField(
          controller: _nameCtrl,
          hint: 'e.g. Canon EOS M50 Mark II mirrorless',
          onChanged: widget.onProductNameChanged,
        ),
        const SizedBox(height: 16),
        _FormLabel('Description'),
        const SizedBox(height: 6),
        _InputField(
          controller: _descCtrl,
          hint: 'Add a description of your product',
          onChanged: widget.onDescriptionChanged,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _FormLabel('Rental Price*'),
        const SizedBox(height: 6),
        // Price + unit row
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
              width: 110,
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
        _FormLabel('Security Deposit'),
        const SizedBox(height: 6),
        _InputField(
          controller: _depositCtrl,
          hint: '₹0.00',
          onChanged: widget.onSecurityDepositChanged,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _FormLabel('Available From'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(10),
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
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m];
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white70 : Colors.black87,
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
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFDDE3F0);

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
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
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
    final surfaceColor = isDark ? AppTheme.darkSurface : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFDDE3F0);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          isExpanded: true,
          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
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
