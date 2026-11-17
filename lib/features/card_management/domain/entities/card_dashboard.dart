import 'package:equatable/equatable.dart';

import 'bank_card.dart';

class CardDashboard extends Equatable {
  const CardDashboard({
    required this.headerSubtitle,
    required this.totalDueAmount,
    required this.totalRecentSpendsAmount,
    required this.dueCardsCount,
    required this.cashbackBannerText,
    required this.pendingActionsCount,
    required this.cards,
    this.isFromFallbackCache = false,
  });

  final String headerSubtitle;
  final double totalDueAmount;
  final double totalRecentSpendsAmount;
  final int dueCardsCount;
  final String cashbackBannerText;
  final int pendingActionsCount;
  final List<BankCard> cards;
  final bool isFromFallbackCache;

  CardDashboard copyWith({
    String? headerSubtitle,
    double? totalDueAmount,
    double? totalRecentSpendsAmount,
    int? dueCardsCount,
    String? cashbackBannerText,
    int? pendingActionsCount,
    List<BankCard>? cards,
    bool? isFromFallbackCache,
  }) {
    return CardDashboard(
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      totalDueAmount: totalDueAmount ?? this.totalDueAmount,
      totalRecentSpendsAmount:
          totalRecentSpendsAmount ?? this.totalRecentSpendsAmount,
      dueCardsCount: dueCardsCount ?? this.dueCardsCount,
      cashbackBannerText: cashbackBannerText ?? this.cashbackBannerText,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
      cards: cards ?? this.cards,
      isFromFallbackCache: isFromFallbackCache ?? this.isFromFallbackCache,
    );
  }

  @override
  List<Object?> get props => [
        headerSubtitle,
        totalDueAmount,
        totalRecentSpendsAmount,
        dueCardsCount,
        cashbackBannerText,
        pendingActionsCount,
        cards,
        isFromFallbackCache,
      ];
}
