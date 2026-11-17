import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_dashboard.dart';

enum HeaderSegmentTab {
  totalDue,
  recentSpends,
}

enum DeckPresentationMode {
  collapsedStack,
  peekQuickActions,
  longPressDetail,
  expandedVerticalList,
}

class CardDashboardState extends Equatable {
  const CardDashboardState({
    this.isLoading = true,
    this.dashboard,
    this.failure,
    this.selectedIndex = 0,
    this.activeTab = HeaderSegmentTab.totalDue,
    this.deckMode = DeckPresentationMode.collapsedStack,
    this.lastActionToast,
  });

  final bool isLoading;
  final CardDashboard? dashboard;
  final Failure? failure;
  final int selectedIndex;
  final HeaderSegmentTab activeTab;
  final DeckPresentationMode deckMode;
  final String? lastActionToast;

  List<BankCard> get cards => dashboard?.cards ?? const <BankCard>[];

  BankCard? get selectedCard {
    if (cards.isEmpty) return null;
    final clampedIndex = selectedIndex.clamp(0, cards.length - 1);
    return cards[clampedIndex];
  }

  CardDashboardState copyWith({
    bool? isLoading,
    CardDashboard? dashboard,
    Failure? failure,
    bool clearFailure = false,
    int? selectedIndex,
    HeaderSegmentTab? activeTab,
    DeckPresentationMode? deckMode,
    String? lastActionToast,
    bool clearToast = false,
  }) {
    return CardDashboardState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      failure: clearFailure ? null : (failure ?? this.failure),
      selectedIndex: selectedIndex ?? this.selectedIndex,
      activeTab: activeTab ?? this.activeTab,
      deckMode: deckMode ?? this.deckMode,
      lastActionToast:
          clearToast ? null : (lastActionToast ?? this.lastActionToast),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        dashboard,
        failure,
        selectedIndex,
        activeTab,
        deckMode,
        lastActionToast,
      ];
}
