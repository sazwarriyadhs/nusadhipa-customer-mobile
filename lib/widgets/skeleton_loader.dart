import 'package:flutter/material.dart';
import '../config/theme.dart';

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: line.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppRadius.xs),
          ),
        );
      },
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: SkeletonBox(
              width: double.infinity,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 12, width: double.infinity),
                SizedBox(height: 6),
                SkeletonBox(height: 12, width: 80),
                SizedBox(height: 10),
                SkeletonBox(height: 14, width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(
            height: 220,
            width: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SkeletonBox(height: 80, width: double.infinity),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 140),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      const SkeletonBox(height: 80, width: 80),
                      if (i < 3) const SizedBox(width: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                const SkeletonBox(height: 20, width: 180),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: 4,
            itemBuilder: (_, _) => const ProductCardSkeleton(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}