import 'package:flutter/material.dart';

/// A single tile widget with dynamic colors and animations
class TileWidget extends StatelessWidget {
  final int value;
  final double size;

  const TileWidget({
    super.key,
    required this.value,
    this.size = 80.0,
  });

  /// Get background color based on tile value
  Color _getBackgroundColor() {
    switch (value) {
      case 0:
        return const Color(0xFFFFFFFF).withOpacity(0.5);
      case 2:
        return const Color(0xFF4a5568);
      case 4:
        return const Color(0xFF5a6478);
      case 8:
        return const Color(0xFFf97316);
      case 16:
        return const Color(0xFFfb923c);
      case 32:
        return const Color(0xFFf87171);
      case 64:
        return const Color(0xFFef4444);
      case 128:
        return const Color(0xFFfbbf24);
      case 256:
        return const Color(0xFFfacc15);
      case 512:
        return const Color(0xFFfde047);
      case 1024:
        return const Color(0xFFfde68a);
      case 2048:
        return const Color(0xFFfef3c7);
      default:
        return const Color(0xFF8b5cf6);
    }
  }

  /// Get text color based on tile value
  Color _getTextColor() {
    // Dark text for very light tiles (2048)
    if (value >= 2048) {
      return const Color(0xFF1f2937);
    }
    // Light text for all other tiles
    return Colors.white;
  }

  /// Get font size based on tile value
  double _getFontSize() {
    if (value < 100) {
      return 32.0;
    } else if (value < 1000) {
      return 28.0;
    } else {
      return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12.0),
        border: value != 0
            ? Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              )
            : null,
        boxShadow: value != 0
            ? [
                BoxShadow(
                  color: _getBackgroundColor().withOpacity(0.5),
                  blurRadius: 8.0,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: value != 0 ? 1.0 : 0.0,
          child: Text(
            value != 0 ? value.toString() : '',
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
            ),
          ),
        ),
      ),
    );
  }
}
