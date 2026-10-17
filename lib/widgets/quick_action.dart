import 'package:flutter/material.dart';
import '../config/theme.dart';

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const QuickAction(this.icon, this.title, this.subtitle, this.onTap,
      {super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: brandRed),
    ),
    title: Text(title, style: const TextStyle(
      fontSize: 12, fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle, style: const TextStyle(
      fontSize: 10, color: muted)),
    trailing: const Icon(Icons.chevron_right_rounded, color: muted),
  );
}