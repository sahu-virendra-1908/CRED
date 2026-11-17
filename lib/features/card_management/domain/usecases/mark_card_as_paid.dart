import '../entities/card_dashboard.dart';

class MarkCardAsPaid {
  const MarkCardAsPaid();

  CardDashboard call({
    required CardDashboard dashboard,
    required String cardId,
  }) {
    final updatedCards = dashboard.cards.map((card) {
      if (card.id != cardId || card.isPaid) return card;
      return card.copyWith(
        isPaid: true,
        dueAmount: 0.0,
        dueDateText: 'PAID IN FULL',
      );
    }).toList(growable: false);

    final remainingDue = updatedCards.fold<double>(
      0.0,
      (sum, card) => sum + (card.isPaid ? 0.0 : card.dueAmount),
    );
    final remainingDueCards =
        updatedCards.where((card) => !card.isPaid && card.dueAmount > 0).length;

    return dashboard.copyWith(
      cards: updatedCards,
      totalDueAmount: remainingDue,
      dueCardsCount: remainingDueCards,
      headerSubtitle: remainingDueCards == 0
          ? 'ALL STATEMENTS SETTLED'
          : 'STATEMENT DUE FOR $remainingDueCards ${remainingDueCards == 1 ? 'CARD' : 'CARDS'}',
    );
  }
}
