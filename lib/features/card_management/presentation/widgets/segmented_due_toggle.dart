import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../providers/card_dashboard_state.dart';

class SegmentedDueToggle extends StatelessWidget {
  const SegmentedDueToggle({
    super.key,
    required this.activeTab,
    required this.dueCount,
    required this.onChanged,
  });

  final HeaderSegmentTab activeTab;
  final int dueCount;
  final ValueChanged<HeaderSegmentTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final isTotalDue = activeTab == HeaderSegmentTab.totalDue;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.pillBackground,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            key: const Key('segment_total_due'),
            label: 'TOTAL DUE',
            badgeCount: dueCount > 0 ? dueCount : null,
            selected: isTotalDue,
            onTap: () => onChanged(HeaderSegmentTab.totalDue),
          ),
          _SegmentButton(
            key: const Key('segment_recent_spends'),
            label: 'RECENT SPENDS',
            selected: !isTotalDue,
            onTap: () => onChanged(HeaderSegmentTab.recentSpends),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: selected ? AppColors.inkPrimary : AppColors.inkSecondary,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.alertCoral,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
