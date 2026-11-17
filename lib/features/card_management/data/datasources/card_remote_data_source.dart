import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/card_dashboard_dto.dart';

abstract interface class CardRemoteDataSource {
  Future<CardDashboardDto> fetchDashboard({bool forceRefresh = false});
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  const CardRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<CardDashboardDto> fetchDashboard({bool forceRefresh = false}) async {
    final json = await _apiClient.getJson(
      ApiConstants.cardManagementEndpoint,
      forceRefresh: forceRefresh,
    );
    return CardDashboardDto.fromJson(json);
  }
}
