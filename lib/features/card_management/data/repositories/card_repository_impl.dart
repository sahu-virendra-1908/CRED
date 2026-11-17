import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/card_dashboard.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_mock_data_source.dart';
import '../datasources/card_remote_data_source.dart';

class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({
    required CardRemoteDataSource remoteDataSource,
    CardLocalMockDataSource? localFallbackDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localFallbackDataSource = localFallbackDataSource;

  final CardRemoteDataSource _remoteDataSource;
  final CardLocalMockDataSource? _localFallbackDataSource;

  @override
  Future<CardDashboard> fetchCardDashboard({bool forceRefresh = false}) async {
    try {
      final dto = await _remoteDataSource.fetchDashboard(
        forceRefresh: forceRefresh,
      );
      return dto.toDomain();
    } on NetworkTimeoutException catch (error) {
      throw TimeoutFailure(error.message);
    } on NetworkUnavailableException catch (error) {
      if (_localFallbackDataSource != null) {
        final fallbackDto =
            await _localFallbackDataSource.loadFallbackDashboard();
        return fallbackDto.toDomain(isFromFallbackCache: true);
      }
      throw NetworkFailure(error.message);
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    } on InvalidPayloadException catch (error) {
      throw ParsingFailure(error.message);
    }
  }
}
