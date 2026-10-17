import 'package:flutter/material.dart';
import '../config/theme.dart';

class Heading extends StatelessWidget {
  final String title;
  final String subtitle;

  const Heading(this.title, this.subtitle, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          fontSize: 25, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(
          fontSize: 12, color: muted)),
      ],
    ),
  );
}