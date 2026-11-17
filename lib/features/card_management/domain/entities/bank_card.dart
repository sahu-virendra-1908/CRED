import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'statement_summary.dart';

enum CardArtworkPattern {
  axisGeometric,
  hdfcMesh,
  yesMandala,
  idfcLines,
  sbiRupeePattern,
}

class BankCard extends Equatable {
  const BankCard({
    required this.id,
    required this.bankName,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.dueAmount,
    required this.recentSpendAmount,
    required this.dueDateText,
    required this.isPaid,
    required this.primaryColor,
    required this.secondaryColor,
    required this.pattern,
    required this.statementSummary,
    this.logoUrl,
    this.cardBackgroundUrl,
    this.pendingActionsCount = 0,
  });

  final String id;
  final String bankName;
  final String lastFourDigits;
  final String cardHolderName;
  final double dueAmount;
  final double recentSpendAmount;
  final String dueDateText;
  final bool isPaid;
  final Color primaryColor;
  final Color secondaryColor;
  final CardArtworkPattern pattern;
  final StatementSummary statementSummary;
  final String? logoUrl;
  final String? cardBackgroundUrl;
  final int pendingActionsCount;

  bool get hasDue => dueAmount > 0 && !isPaid;

  BankCard copyWith({
    String? id,
    String? bankName,
    String? lastFourDigits,
    String? cardHolderName,
    double? dueAmount,
    double? recentSpendAmount,
    String? dueDateText,
    bool? isPaid,
    Color? primaryColor,
    Color? secondaryColor,
    CardArtworkPattern? pattern,
    StatementSummary? statementSummary,
    String? logoUrl,
    String? cardBackgroundUrl,
    int? pendingActionsCount,
  }) {
    return BankCard(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      dueAmount: dueAmount ?? this.dueAmount,
      recentSpendAmount: recentSpendAmount ?? this.recentSpendAmount,
      dueDateText: dueDateText ?? this.dueDateText,
      isPaid: isPaid ?? this.isPaid,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      pattern: pattern ?? this.pattern,
      statementSummary: statementSummary ?? this.statementSummary,
      logoUrl: logoUrl ?? this.logoUrl,
      cardBackgroundUrl: cardBackgroundUrl ?? this.cardBackgroundUrl,
      pendingActionsCount: pendingActionsCount ?? this.pendingActionsCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bankName,
        lastFourDigits,
        cardHolderName,
        dueAmount,
        recentSpendAmount,
        dueDateText,
        isPaid,
        primaryColor,
        secondaryColor,
        pattern,
        statementSummary,
        logoUrl,
        cardBackgroundUrl,
        pendingActionsCount,
      ];
}
