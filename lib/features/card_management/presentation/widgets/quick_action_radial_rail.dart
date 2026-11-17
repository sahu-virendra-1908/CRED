import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/card_action_item.dart';

class QuickActionRadialRail extends StatelessWidget {
  const QuickActionRadialRail({
    super.key,
    required this.onActionSelected,
  });

  final ValueChanged<CardQuickActionType> onActionSelected;

  @override
  Widget build(BuildContext context) {
    const leftColumn = <_QuickActionSpec>[
      _QuickActionSpec(
        keyName: 'action_mark_as_paid',
        type: CardQuickActionType.markAsPaid,
        label: 'mark\nas paid',
        icon: Icons.check_circle_outline_rounded,
      ),
      _QuickActionSpec(
        keyName: 'action_payment_history',
        type: CardQuickActionType.paymentHistory,
        label: 'payment\nhistory',
        icon: Icons.history_edu_outlined,
      ),
      _QuickActionSpec(
        keyName: 'action_recent_spends',
        type: CardQuickActionType.recentSpends,
        label: 'recent\nspends',
        icon: Icons.currency_rupee_rounded,
      ),
    ];

    const rightColumn = <_QuickActionSpec>[
      _QuickActionSpec(
        keyName: 'action_smart_statement',
        type: CardQuickActionType.smartStatement,
        label: 'smart\nstatement',
        icon: Icons.description_outlined,
      ),
      _QuickActionSpec(
        keyName: 'action_card_offers',
        type: CardQuickActionType.cardOffers,
        label: 'card\noffers',
        icon: Icons.percent_rounded,
      ),
      _QuickActionSpec(
        keyName: 'action_more_actions',
        type: CardQuickActionType.moreActions,
        label: 'more\nactions',
        icon: Icons.hub_outlined,
      ),
    ];

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: SizedBox(
        width: 168,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActionColumn(
              items: leftColumn,
              onActionSelected: onActionSelected,
            ),
            const SizedBox(width: 10),
            _ActionColumn(
              items: rightColumn,
              onActionSelected: onActionSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionSpec {
  const _QuickActionSpec({
    required this.keyName,
    required this.type,
    required this.label,
    required this.icon,
  });

  final String keyName;
  final CardQuickActionType type;
  final String label;
  final IconData icon;
}

class _ActionColumn extends StatelessWidget {
  const _ActionColumn({
    required this.items,
    required this.onActionSelected,
  });

  final List<_QuickActionSpec> items;
  final ValueChanged<CardQuickActionType> onActionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _RadialActionNode(
            item: items[i],
            onTap: () => onActionSelected(items[i].type),
          ),
          if (i < items.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RadialActionNode extends StatelessWidget {
  const _RadialActionNode({
    required this.item,
    required this.onTap,
  });

  final _QuickActionSpec item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key(item.keyName),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 74,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 17,
                color: AppColors.inkPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.12,
                color: AppColors.inkPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
