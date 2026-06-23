import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentit24/pages/login_screens/biometric_screen.dart';

class CreateAppPinScreen extends StatefulWidget {
  const CreateAppPinScreen({super.key});

  @override
  State<CreateAppPinScreen> createState() => _CreateAppPinScreenState();
}

class _CreateAppPinScreenState extends State<CreateAppPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
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
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create New App Pin',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'SKIP',
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Add a PIN number to make your\naccount more secure',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _buildPinBox(index, theme),
                      );
                    }),
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: TextField(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 4,
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _pinController.text.length == 4 ? () {   Navigator.push(context, MaterialPageRoute(builder: (_) => BiometricAuthScreen(authType: BiometricType.faceId)));
} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox(int index, ThemeData theme) {
    bool isFilled = _pinController.text.length > index;
    bool isFocused = _pinController.text.length == index && _pinFocusNode.hasFocus;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isFilled ? theme.primaryColor.withOpacity(0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused || isFilled ? theme.primaryColor : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          if (theme.brightness == Brightness.light && !isFilled && !isFocused)
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: isFilled
            ? Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}