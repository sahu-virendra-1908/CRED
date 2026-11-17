import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/card_management/data/datasources/card_local_mock_data_source.dart';
import '../../features/card_management/data/datasources/card_remote_data_source.dart';
import '../../features/card_management/data/repositories/card_repository_impl.dart';
import '../../features/card_management/domain/repositories/card_repository.dart';
import '../../features/card_management/domain/usecases/get_card_dashboard.dart';
import '../../features/card_management/domain/usecases/mark_card_as_paid.dart';
import '../network/api_client.dart';
import '../network/request_deduplicator.dart';
import '../performance/frame_timing_tracker.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> configureDependencies({
  Dio? customDio,
  CardRemoteDataSource? customRemoteDataSource,
  bool allowMockFallback = false,
}) async {
  await serviceLocator.reset();

  serviceLocator.registerLazySingleton<FrameTimingTracker>(
    FrameTimingTracker.new,
  );

  serviceLocator.registerLazySingleton<RequestDeduplicator>(
    RequestDeduplicator.new,
  );

  serviceLocator.registerLazySingleton<Dio>(
    () => customDio ?? ApiClient.createDefaultDio(),
  );

  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClient(
      dio: serviceLocator<Dio>(),
      deduplicator: serviceLocator<RequestDeduplicator>(),
    ),
  );

  serviceLocator.registerLazySingleton<CardRemoteDataSource>(
    () =>
        customRemoteDataSource ??
        CardRemoteDataSourceImpl(apiClient: serviceLocator<ApiClient>()),
  );

  serviceLocator.registerLazySingleton<CardLocalMockDataSource>(
    CardLocalMockDataSourceImpl.new,
  );

  serviceLocator.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(
      remoteDataSource: serviceLocator<CardRemoteDataSource>(),
      localFallbackDataSource:
          allowMockFallback ? serviceLocator<CardLocalMockDataSource>() : null,
    ),
  );

  serviceLocator.registerLazySingleton<GetCardDashboard>(
    () => GetCardDashboard(serviceLocator<CardRepository>()),
  );

  serviceLocator.registerLazySingleton<MarkCardAsPaid>(
    MarkCardAsPaid.new,
  );
}
