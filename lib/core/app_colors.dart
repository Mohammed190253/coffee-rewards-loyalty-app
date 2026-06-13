import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Color(0xFF0F2522);
  static const Color astrolabeGold = Color(0xFFD4AF37);
  static const Color backgroundBeige = Color(0xFFFBF9F6);
  static const Color textGrey = Color(0xFF8C8C8C);

  static const Color surfaceWhite = Color(0xFFFFFFFF);

  static const Color scholarBackground = Color(0xFF0A1413);
  static const Color scholarCard = Color(0xFF132826);

  static Color getBackground(bool isScholarMode) {
    return isScholarMode ? scholarBackground : backgroundBeige;
  }
}

class AstrolabeButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const AstrolabeButton({super.key, required this.label, required this.onPressed});

  @override
  State<AstrolabeButton> createState() => _AstrolabeButtonState();
}

class _AstrolabeButtonState extends State<AstrolabeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [AppColors.astrolabeGold, Color(0xFFB49020)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.astrolabeGold.withOpacity(0.4), offset: const Offset(0, 8), blurRadius: 15),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2
              ),
            ),
          ),
        ),
      ),
    );
  }
}