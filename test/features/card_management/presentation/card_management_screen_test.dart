import 'package:cred_card_management/core/di/injection_container.dart';
import 'package:cred_card_management/core/errors/exceptions.dart';
import 'package:cred_card_management/features/card_management/data/datasources/card_remote_data_source.dart';
import 'package:cred_card_management/features/card_management/data/models/card_dashboard_dto.dart';
import 'package:cred_card_management/features/card_management/presentation/screens/card_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockRemoteDataSource extends Mock implements CardRemoteDataSource {}

void main() {
  late _MockRemoteDataSource mockRemote;

  setUp(() async {
    mockRemote = _MockRemoteDataSource();
    await configureDependencies(
      customRemoteDataSource: mockRemote,
      allowMockFallback: false,
    );
  });

  Widget buildSubject() {
    return const ProviderScope(
      child: MaterialApp(
        home: CardManagementScreen(),
      ),
    );
  }

  testWidgets(
      'renders dashboard, handles swipe-left, long-press, and expand/collapse',
      (WidgetTester tester) async {
    when(() => mockRemote.fetchDashboard(forceRefresh: false)).thenAnswer(
      (_) async => CardDashboardDto.fromJson(TestFixtures.mockletsApiResponse),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('STATEMENT DUE FOR 1 CARD'), findsOneWidget);
    expect(find.text('SNEHA IYER'), findsOneWidget);

    await tester.fling(
      find.byKey(const Key('active_bank_card')),
      const Offset(-220, 0),
      900,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('action_mark_as_paid')), findsOneWidget);
    expect(find.byKey(const Key('action_smart_statement')), findsOneWidget);

    await tester.tap(find.byKey(const Key('active_bank_card')));
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('active_bank_card')));
    await tester.pumpAndSettle();
    expect(find.text('latest statement'), findsOneWidget);
    expect(find.text('verify card to unlock'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.fling(
      find.byKey(const Key('card_deck_gesture_surface')),
      const Offset(0, 260),
      900,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('expanded_cards_list_view')), findsOneWidget);

    await tester.tap(find.byKey(const Key('collapse_deck_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('expanded_cards_list_view')), findsNothing);
  });

  testWidgets('renders error state and retries successfully',
      (WidgetTester tester) async {
    when(() => mockRemote.fetchDashboard(forceRefresh: false))
        .thenThrow(const NetworkTimeoutException());
    when(() => mockRemote.fetchDashboard(forceRefresh: true)).thenAnswer(
      (_) async => CardDashboardDto.fromJson(TestFixtures.mockletsApiResponse),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboard_error_view')), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry_fetch_button')));
    await tester.pumpAndSettle();

    expect(find.text('SNEHA IYER'), findsOneWidget);
  });
}
