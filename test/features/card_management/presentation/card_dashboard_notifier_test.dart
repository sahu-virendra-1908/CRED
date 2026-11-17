import 'package:cred_card_management/core/errors/failures.dart';
import 'package:cred_card_management/features/card_management/domain/usecases/get_card_dashboard.dart';
import 'package:cred_card_management/features/card_management/domain/usecases/mark_card_as_paid.dart';
import 'package:cred_card_management/features/card_management/presentation/providers/card_dashboard_provider.dart';
import 'package:cred_card_management/features/card_management/presentation/providers/card_dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockGetCardDashboard extends Mock implements GetCardDashboard {}

void main() {
  late _MockGetCardDashboard getCardDashboard;

  setUp(() {
    getCardDashboard = _MockGetCardDashboard();
  });

  test('loads dashboard and handles card selection, expansion, and collapse',
      () async {
    when(() => getCardDashboard(forceRefresh: false))
        .thenAnswer((_) async => TestFixtures.sampleDashboard());

    final notifier = CardDashboardNotifier(
      getCardDashboard: getCardDashboard,
      markCardAsPaid: const MarkCardAsPaid(),
    );

    await notifier.loadDashboard();
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.cards.length, 3);
    expect(notifier.state.selectedIndex, 0);

    notifier.selectCard(2);
    expect(notifier.state.selectedIndex, 2);
    expect(notifier.state.selectedCard?.bankName, 'YES BANK');

    notifier.expandVerticalCollection();
    expect(notifier.state.deckMode, DeckPresentationMode.expandedVerticalList);

    notifier.collapseVerticalCollection();
    expect(notifier.state.deckMode, DeckPresentationMode.collapsedStack);
  });

  test('exposes failure state when repository throws Failure', () async {
    when(() => getCardDashboard(forceRefresh: false))
        .thenThrow(const TimeoutFailure('Timed out'));

    final notifier = CardDashboardNotifier(
      getCardDashboard: getCardDashboard,
      markCardAsPaid: const MarkCardAsPaid(),
    );

    await notifier.loadDashboard();
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.failure, isA<TimeoutFailure>());
  });
}
