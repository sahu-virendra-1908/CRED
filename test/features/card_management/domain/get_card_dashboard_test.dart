import 'package:cred_card_management/features/card_management/domain/repositories/card_repository.dart';
import 'package:cred_card_management/features/card_management/domain/usecases/get_card_dashboard.dart';
import 'package:cred_card_management/features/card_management/domain/usecases/mark_card_as_paid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockCardRepository extends Mock implements CardRepository {}

void main() {
  test('GetCardDashboard delegates to repository', () async {
    final repo = _MockCardRepository();
    final sample = TestFixtures.sampleDashboard();
    when(() => repo.fetchCardDashboard(forceRefresh: true))
        .thenAnswer((_) async => sample);

    final useCase = GetCardDashboard(repo);
    final result = await useCase(forceRefresh: true);

    expect(result, sample);
    verify(() => repo.fetchCardDashboard(forceRefresh: true)).called(1);
  });

  test('MarkCardAsPaid settles due amount and updates card count', () {
    final sample = TestFixtures.sampleDashboard();
    const markPaid = MarkCardAsPaid();

    final updated = markPaid(
      dashboard: sample,
      cardId: sample.cards.first.id,
    );

    expect(updated.cards.first.isPaid, isTrue);
    expect(updated.cards.first.dueAmount, 0.0);
    expect(updated.totalDueAmount, 0.0);
    expect(updated.dueCardsCount, 0);
  });
}
