import 'package:flutter/material.dart';
import '../config/theme.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final bool accent;

  const Panel({
    super.key,
    required this.child,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accent ? brandRed.withValues(alpha: 0.25) : line,
          ),
          boxShadow: [
            BoxShadow(
              color: accent
                  ? brandRed.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.025),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: child,
      );
}