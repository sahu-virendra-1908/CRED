import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_action_item.dart';
import '../providers/card_dashboard_provider.dart';
import '../providers/card_dashboard_state.dart';
import '../widgets/action_feedback_sheet.dart';
import '../widgets/card_deck_stage.dart';
import '../widgets/card_long_press_sheet.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/error_state_view.dart';
import '../widgets/loading_shimmer_view.dart';

class CardManagementScreen extends ConsumerWidget {
  const CardManagementScreen({super.key});

  void _openQuickActionSheet(
    BuildContext context,
    WidgetRef ref,
    BankCard card,
    CardQuickActionType actionType,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ActionFeedbackSheet(
        card: card,
        actionType: actionType,
        onConfirmMarkPaid: () {
          ref.read(cardDashboardProvider.notifier).markSelectedCardPaid();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(
      cardDashboardProvider.select((s) => s.lastActionToast),
      (previous, next) {
        if (next != null && next.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(next),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          ref.read(cardDashboardProvider.notifier).clearToast();
        }
      },
    );

    final isLoading =
        ref.watch(cardDashboardProvider.select((s) => s.isLoading));
    final failure = ref.watch(cardDashboardProvider.select((s) => s.failure));
    final dashboard =
        ref.watch(cardDashboardProvider.select((s) => s.dashboard));

    if (isLoading && dashboard == null) {
      return const Scaffold(
        body: LoadingShimmerView(),
      );
    }

    if (failure != null && dashboard == null) {
      return Scaffold(
        body: ErrorStateView(
          message: failure.message,
          onRetry: () => ref
              .read(cardDashboardProvider.notifier)
              .loadDashboard(forceRefresh: true),
        ),
      );
    }

    if (dashboard == null || dashboard.cards.isEmpty) {
      return Scaffold(
        body: ErrorStateView(
          message: 'No linked credit cards returned by the API.',
          onRetry: () => ref
              .read(cardDashboardProvider.notifier)
              .loadDashboard(forceRefresh: true),
        ),
      );
    }

    final selectedIndex =
        ref.watch(cardDashboardProvider.select((s) => s.selectedIndex));
    final activeTab =
        ref.watch(cardDashboardProvider.select((s) => s.activeTab));
    final deckMode = ref.watch(cardDashboardProvider.select((s) => s.deckMode));
    final notifier = ref.read(cardDashboardProvider.notifier);
    final selectedCard =
        dashboard.cards[selectedIndex.clamp(0, dashboard.cards.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.canvasTop,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              DashboardHeader(
                dashboard: dashboard,
                activeTab: activeTab,
                onTabChanged: notifier.switchTab,
                onPayBillPressed: () => _openQuickActionSheet(
                  context,
                  ref,
                  selectedCard,
                  CardQuickActionType.markAsPaid,
                ),
                onOffersPressed: () => _openQuickActionSheet(
                  context,
                  ref,
                  selectedCard,
                  CardQuickActionType.cardOffers,
                ),
                onSettingsPressed: () => _openQuickActionSheet(
                  context,
                  ref,
                  selectedCard,
                  CardQuickActionType.moreActions,
                ),
                onBannerPressed: () => notifier.notifyAction(
                  dashboard.cashbackBannerText,
                ),
              ),
              Expanded(
                child: CardDeckStage(
                  cards: dashboard.cards,
                  selectedIndex: selectedIndex,
                  deckMode: deckMode,
                  pendingActionsCount: dashboard.pendingActionsCount,
                  onSelectCard: notifier.selectCard,
                  onDeckModeChanged: notifier.setDeckMode,
                  onQuickAction: (action) => _openQuickActionSheet(
                    context,
                    ref,
                    selectedCard,
                    action,
                  ),
                  onPayNow: (card) => _openQuickActionSheet(
                    context,
                    ref,
                    card,
                    CardQuickActionType.markAsPaid,
                  ),
                  onPendingActionsTap: () => _openQuickActionSheet(
                    context,
                    ref,
                    selectedCard,
                    CardQuickActionType.moreActions,
                  ),
                ),
              ),
            ],
          ),
          if (deckMode == DeckPresentationMode.longPressDetail)
            Positioned.fill(
              child: CardLongPressSheet(
                card: selectedCard,
                onDismiss: () => notifier.setDeckMode(
                  DeckPresentationMode.collapsedStack,
                ),
                onActionSelected: (action) {
                  notifier.setDeckMode(DeckPresentationMode.collapsedStack);
                  _openQuickActionSheet(context, ref, selectedCard, action);
                },
                onPayNow: () {
                  notifier.setDeckMode(DeckPresentationMode.collapsedStack);
                  _openQuickActionSheet(
                    context,
                    ref,
                    selectedCard,
                    CardQuickActionType.markAsPaid,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
