import 'package:equatable/equatable.dart';

class StatementSummary extends Equatable {
  const StatementSummary({
    required this.sectionDateLabel,
    required this.latestStatementText,
    required this.recentSpendsText,
    required this.cardOffersText,
  });

  final String sectionDateLabel;
  final String latestStatementText;
  final String recentSpendsText;
  final String cardOffersText;

  @override
  List<Object?> get props => [
        sectionDateLabel,
        latestStatementText,
        recentSpendsText,
        cardOffersText,
      ];
}
