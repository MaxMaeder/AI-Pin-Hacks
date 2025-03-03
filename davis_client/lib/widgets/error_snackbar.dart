import 'package:flutter/material.dart';

class ErrorSnackbar {
  static SnackBar show(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.red,
    );
  }
}
