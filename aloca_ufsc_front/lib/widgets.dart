import 'package:aloca_ufsc_front/theme.dart';
import 'package:flutter/material.dart';

Widget textField ({
    required TextEditingController controller,
    required String label,
    bool dim = false,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: dim,
      keyboardType: keyboard,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.secondaryBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mainBlue, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
}

void showToast(BuildContext context, String message) {
ScaffoldMessenger.of(context) 
..hideCurrentSnackBar()
..showSnackBar(
    SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
    ),
);
}

