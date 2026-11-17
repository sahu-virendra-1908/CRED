import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_card_dashboard.dart';
import '../../domain/usecases/mark_card_as_paid.dart';
import 'card_dashboard_state.dart';

final getCardDashboardUseCaseProvider = Provider<GetCardDashboard>(
  (ref) => serviceLocator<GetCardDashboard>(),
);

final markCardAsPaidUseCaseProvider = Provider<MarkCardAsPaid>(
  (ref) => serviceLocator<MarkCardAsPaid>(),
);

final cardDashboardProvider =
    StateNotifierProvider<CardDashboardNotifier, CardDashboardState>((ref) {
  return CardDashboardNotifier(
    getCardDashboard: ref.watch(getCardDashboardUseCaseProvider),
    markCardAsPaid: ref.watch(markCardAsPaidUseCaseProvider),
  )..loadDashboard();
});

class CardDashboardNotifier extends StateNotifier<CardDashboardState> {
  CardDashboardNotifier({
    required GetCardDashboard getCardDashboard,
    required MarkCardAsPaid markCardAsPaid,
  })  : _getCardDashboard = getCardDashboard,
        _markCardAsPaid = markCardAsPaid,
        super(const CardDashboardState());

  final GetCardDashboard _getCardDashboard;
  final MarkCardAsPaid _markCardAsPaid;

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final result = await _getCardDashboard(forceRefresh: forceRefresh);
      final safeIndex = result.cards.isEmpty
          ? 0
          : state.selectedIndex.clamp(0, result.cards.length - 1);
      state = state.copyWith(
        isLoading: false,
        dashboard: result,
        selectedIndex: safeIndex,
        clearFailure: true,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        isLoading: false,
        failure: failure,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        failure: const ServerFailure('Unexpected error loading cards.'),
      );
    }
  }

  void selectCard(int index) {
    final cards = state.cards;
    if (cards.isEmpty) return;
    final clamped = index.clamp(0, cards.length - 1);
    if (clamped == state.selectedIndex &&
        state.deckMode == DeckPresentationMode.collapsedStack) {
      return;
    }
    state = state.copyWith(
      selectedIndex: clamped,
      deckMode: DeckPresentationMode.collapsedStack,
    );
  }

  void switchTab(HeaderSegmentTab tab) {
    if (state.activeTab == tab) return;
    state = state.copyWith(activeTab: tab);
  }

  void setDeckMode(DeckPresentationMode mode) {
    if (state.deckMode == mode) return;
    state = state.copyWith(deckMode: mode);
  }

  void expandVerticalCollection() {
    if (state.cards.isEmpty) return;
    state = state.copyWith(
      deckMode: DeckPresentationMode.expandedVerticalList,
    );
  }

  void collapseVerticalCollection() {
    state = state.copyWith(
      deckMode: DeckPresentationMode.collapsedStack,
    );
  }

  void markSelectedCardPaid() {
    final currentDashboard = state.dashboard;
    final currentCard = state.selectedCard;
    if (currentDashboard == null || currentCard == null) return;

    final updated = _markCardAsPaid(
      dashboard: currentDashboard,
      cardId: currentCard.id,
    );

    state = state.copyWith(
      dashboard: updated,
      deckMode: DeckPresentationMode.collapsedStack,
      lastActionToast:
          '${currentCard.bankName} •• ${currentCard.lastFourDigits} marked as paid',
    );
  }

  void notifyAction(String message) {
    state = state.copyWith(lastActionToast: message);
  }

  void clearToast() {
    state = state.copyWith(clearToast: true);
  }
}
