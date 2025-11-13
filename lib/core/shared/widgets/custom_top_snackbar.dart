
import 'package:flutter/material.dart';

class CustomTopSnackBar {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              color: Colors.black54,
              padding: EdgeInsets.all(20.0),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Display for a short duration
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}







