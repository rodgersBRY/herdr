import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static const Color _okColor = Color(0xFF1F7A45);
  static const Color _warningColor = Color(0xFFB0721F);
  static const Color _errorColor = Color(0xFFB3261E);

  static void ok(String title, String message) {
    _show(
      title: title,
      message: message,
      color: _okColor,
      icon: Icons.check_circle_outline,
    );
  }

  static void warning(String title, String message) {
    _show(
      title: title,
      message: message,
      color: _warningColor,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      color: _errorColor,
      icon: Icons.error_outline_rounded,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      icon: Icon(icon, color: Colors.white),
      duration: const Duration(seconds: 3),
      shouldIconPulse: false,
    );
  }
}
