import '../entities/card_dashboard.dart';

abstract interface class CardRepository {
  Future<CardDashboard> fetchCardDashboard({bool forceRefresh = false});
}
