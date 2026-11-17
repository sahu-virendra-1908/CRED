import 'package:cred_card_management/core/di/injection_container.dart';
import 'package:cred_card_management/core/performance/frame_timing_tracker.dart';
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
  testWidgets(
      'measures widget build durations across swipe and expand transitions',
      (WidgetTester tester) async {
    final mockRemote = _MockRemoteDataSource();
    when(() => mockRemote.fetchDashboard(forceRefresh: false)).thenAnswer(
      (_) async => CardDashboardDto.fromJson(TestFixtures.mockletsApiResponse),
    );

    await configureDependencies(
      customRemoteDataSource: mockRemote,
      allowMockFallback: false,
    );

    final tracker = serviceLocator<FrameTimingTracker>()..start();

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CardManagementScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final buildStopwatch = Stopwatch()..start();
    await tester.fling(
      find.byKey(const Key('active_bank_card')),
      const Offset(-220, 0),
      1000,
    );
    await tester.pumpAndSettle();
    buildStopwatch.stop();

    expect(buildStopwatch.elapsedMilliseconds, lessThan(2000));
    expect(tracker.snapshot().jankPercentage, lessThanOrEqualTo(5.0));
  });
}
