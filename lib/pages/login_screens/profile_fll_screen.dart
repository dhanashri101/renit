import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentit24/pages/login_screens/create_new_app_pin.dart';

class FillYourProfileScreen extends StatefulWidget {
  const FillYourProfileScreen({super.key});

  @override
  State<FillYourProfileScreen> createState() => _FillYourProfileScreenState();
}

class _FillYourProfileScreenState extends State<FillYourProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobMonthController = TextEditingController();
  final _dobDayController = TextEditingController();
  final _dobYearController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedCountryFlag = '🇮🇳';
  final List<String> _countryFlags = ['🇮🇳', '🇺🇸', '🇬🇧', '🇨🇦', '🇦🇺'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobMonthController.dispose();
    _dobDayController.dispose();
    _dobYearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

 void _submitForm() {
  if (_formKey.currentState!.validate()) {
    final profileData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'dob':
          '${_dobMonthController.text}/${_dobDayController.text}/${_dobYearController.text}',
      'email': _emailController.text,
      'phone': '$_selectedCountryFlag ${_phoneController.text}',
      'address': _addressController.text,
    };

    print("Profile Data Saved: $profileData");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully!'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAppPinScreen(),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fill Your Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("Skipped Profile Fill");
            },
            child: Text(
              'SKIP',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.surface,
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.grey), 
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            print("Open Image Picker");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.scaffoldBackgroundColor, width: 3),
                            ),
                            child: const Icon(Icons.edit,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildLabel('First Name*'),
                StyledTextField(
                  hintText: 'ex. John',
                  controller: _firstNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'First Name is required' : null,
                ),
                const SizedBox(height: 20),

                _buildLabel('Last Name*'),
                StyledTextField(
                  hintText: 'ex. Doe',
                  controller: _lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Last Name is required' : null,
                ),
                const SizedBox(height: 20),

                _buildLabel('Date of Birth'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StyledTextField(
                        hintText: 'MM',
                        isNumber: true,
                        controller: _dobMonthController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StyledTextField(
                        hintText: 'DD',
                        isNumber: true,
                        controller: _dobDayController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: StyledTextField(
                        hintText: 'YYYY',
                        isNumber: true,
                        controller: _dobYearController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Email*'),
                StyledTextField(
                  hintText: 'ex. johndoe@domain.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email is required';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Phone Number*'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountryFlag,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: textColor.withOpacity(0.5)),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCountryFlag = newValue!;
                            });
                          },
                          items: _countryFlags
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: const TextStyle(fontSize: 20)),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StyledTextField(
                        hintText: '(000) 000 0000',
                        isNumber: true,
                        controller: _phoneController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Phone number required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Address'),
                StyledTextField(
                  hintText: 'Enter your location',
                  suffixIcon: Icons.location_on_outlined,
                  controller: _addressController,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class StyledTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isNumber;
  final bool isObscure;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const StyledTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isNumber = false,
    this.isObscure = false,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  State<StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor = _isFocused
        ? theme.primaryColor.withOpacity(0.1)
        : theme.colorScheme.surface;

    Color borderColor =
        _isFocused ? theme.primaryColor : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 56), 
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (!isDark && !_isFocused)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: _obscureText,
        validator: widget.validator,
        keyboardType: widget.keyboardType ??
            (widget.isNumber ? TextInputType.number : TextInputType.text),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.4),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon,
                  color: _isFocused
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20)
              : null,
          suffixIcon: widget.isObscure
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _isFocused
                        ? theme.primaryColor
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                )
              : widget.suffixIcon != null
                  ? Icon(widget.suffixIcon,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      size: 20)
                  : null,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}