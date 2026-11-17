import '../entities/card_dashboard.dart';
import '../repositories/card_repository.dart';

class GetCardDashboard {
  const GetCardDashboard(this._repository);

  final CardRepository _repository;

  Future<CardDashboard> call({bool forceRefresh = false}) {
    return _repository.fetchCardDashboard(forceRefresh: forceRefresh);
  }
}
