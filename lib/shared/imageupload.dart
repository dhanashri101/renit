import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentit24/core/theme.dart'; // Ensure this matches your project structure

class _UploadImageStep extends StatefulWidget {
  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;

  const _UploadImageStep({
    required this.imagePaths,
    required this.onChanged,
  });

  @override
  State<_UploadImageStep> createState() => _UploadImageStepState();
}

class _UploadImageStepState extends State<_UploadImageStep> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (widget.imagePaths.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 5 photos allowed.')),
      );
      return;
    }

    setState(() => _isPicking = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Compress slightly for better performance
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
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white; // Adjust to your AppTheme
    final borderColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFDDE3F0);
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
                ]
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
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
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
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEF2FF),
                            child: Icon(Icons.broken_image, color: hintColor),
                          ),
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
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              )
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