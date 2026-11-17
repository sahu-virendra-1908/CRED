import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_action_item.dart';

class ActionFeedbackSheet extends StatelessWidget {
  const ActionFeedbackSheet({
    super.key,
    required this.card,
    required this.actionType,
    required this.onConfirmMarkPaid,
  });

  final BankCard card;
  final CardQuickActionType actionType;
  final VoidCallback onConfirmMarkPaid;

  @override
  Widget build(BuildContext context) {
    final title = switch (actionType) {
      CardQuickActionType.markAsPaid => 'Mark bill as paid',
      CardQuickActionType.smartStatement => 'Smart statement',
      CardQuickActionType.paymentHistory => 'Payment history',
      CardQuickActionType.cardOffers => 'Card offers & rewards',
      CardQuickActionType.recentSpends => 'Recent spends',
      CardQuickActionType.moreActions => 'Card controls',
    };

    final description = switch (actionType) {
      CardQuickActionType.markAsPaid =>
        'Confirm if you have already settled ${CurrencyFormatter.splitInr(card.dueAmount).fullFormatted} for ${card.bankName} •• ${card.lastFourDigits} outside CRED.',
      CardQuickActionType.smartStatement =>
        card.statementSummary.latestStatementText,
      CardQuickActionType.paymentHistory =>
        'Last payment settled on time with zero late charges.',
      CardQuickActionType.cardOffers => card.statementSummary.cardOffersText,
      CardQuickActionType.recentSpends =>
        'Unbilled cycle spends: ${CurrencyFormatter.splitInr(card.recentSpendAmount).fullFormatted}. ${card.statementSummary.recentSpendsText}.',
      CardQuickActionType.moreActions =>
        'Manage auto-pay mandate, billing cycle alerts, and card PIN reminders.',
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '${card.bankName} •• ${card.lastFourDigits}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.inkPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppColors.inkSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                key: const Key('sheet_primary_confirm_button'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (actionType == CardQuickActionType.markAsPaid) {
                    onConfirmMarkPaid();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inkPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionType == CardQuickActionType.markAsPaid
                      ? 'Confirm & mark paid'
                      : 'Done',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
