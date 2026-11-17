import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class LoadingShimmerView extends StatefulWidget {
  const LoadingShimmerView({super.key});

  @override
  State<LoadingShimmerView> createState() => _LoadingShimmerViewState();
}

class _LoadingShimmerViewState extends State<LoadingShimmerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final tone = Color.lerp(
          const Color(0xFFEBEBED),
          const Color(0xFFF6F6F8),
          _controller.value,
        )!;

        return SafeArea(
          key: const Key('dashboard_loading_view'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  height: 36,
                  width: 220,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  height: 40,
                  width: 180,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 42,
                  width: 120,
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 28),
                AspectRatio(
                  aspectRatio: 1.586,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                ),
                const Spacer(),
                const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.inkPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
