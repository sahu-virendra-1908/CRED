import 'package:cred_card_management/core/errors/exceptions.dart';
import 'package:cred_card_management/core/errors/failures.dart';
import 'package:cred_card_management/features/card_management/data/datasources/card_local_mock_data_source.dart';
import 'package:cred_card_management/features/card_management/data/datasources/card_remote_data_source.dart';
import 'package:cred_card_management/features/card_management/data/models/card_dashboard_dto.dart';
import 'package:cred_card_management/features/card_management/data/repositories/card_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_fixtures.dart';

class _MockRemoteDataSource extends Mock implements CardRemoteDataSource {}

void main() {
  late _MockRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = _MockRemoteDataSource();
  });

  test('returns remote CardDashboard when API call succeeds', () async {
    when(() => remoteDataSource.fetchDashboard(forceRefresh: false)).thenAnswer(
      (_) async => CardDashboardDto.fromJson(TestFixtures.mockletsApiResponse),
    );

    final repository = CardRepositoryImpl(remoteDataSource: remoteDataSource);
    final result = await repository.fetchCardDashboard();

    expect(result.isFromFallbackCache, isFalse);
    expect(result.totalDueAmount, 50000.0);
  });

  test('throws TimeoutFailure when remote request times out', () async {
    when(() => remoteDataSource.fetchDashboard(forceRefresh: false))
        .thenThrow(const NetworkTimeoutException());

    final repository = CardRepositoryImpl(remoteDataSource: remoteDataSource);

    expect(
      () => repository.fetchCardDashboard(),
      throwsA(isA<TimeoutFailure>()),
    );
  });

  test('throws NetworkFailure when offline and fallback is disabled', () async {
    when(() => remoteDataSource.fetchDashboard(forceRefresh: false))
        .thenThrow(const NetworkUnavailableException());

    final repository = CardRepositoryImpl(remoteDataSource: remoteDataSource);

    expect(
      () => repository.fetchCardDashboard(),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('uses local fallback only when explicitly configured', () async {
    when(() => remoteDataSource.fetchDashboard(forceRefresh: false))
        .thenThrow(const NetworkUnavailableException());

    final repository = CardRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localFallbackDataSource: const CardLocalMockDataSourceImpl(),
    );

    final result = await repository.fetchCardDashboard();
    expect(result.isFromFallbackCache, isTrue);
  });
}
