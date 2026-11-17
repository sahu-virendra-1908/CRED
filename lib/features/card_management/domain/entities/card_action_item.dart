import 'package:equatable/equatable.dart';

enum CardQuickActionType {
  markAsPaid,
  smartStatement,
  paymentHistory,
  cardOffers,
  recentSpends,
  moreActions,
}

class CardActionItem extends Equatable {
  const CardActionItem({
    required this.type,
    required this.label,
    required this.subtitle,
  });

  final CardQuickActionType type;
  final String label;
  final String subtitle;

  @override
  List<Object?> get props => [type, label, subtitle];
}
