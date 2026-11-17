import 'package:flutter/material.dart';

class LoadingShimmerView extends StatelessWidget {
  const LoadingShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              height: 44,
              width: 240,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBF0),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 36),
            Container(
              height: 44,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBF0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              width: 112,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBF0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBF0),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
