import 'package:flutter/material.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/markup_stripper.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_dashboard.dart';
import '../../domain/entities/statement_summary.dart';

class CardDashboardDto {
  const CardDashboardDto({required this.items});

  final List<SectionItemDto> items;

  factory CardDashboardDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      throw const InvalidPayloadException(
          'Missing items array in API payload.');
    }

    final parsedItems = rawItems
        .whereType<Map<dynamic, dynamic>>()
        .map((map) => SectionItemDto.fromJson(Map<String, dynamic>.from(map)))
        .toList(growable: false);

    return CardDashboardDto(items: parsedItems);
  }

  CardDashboard toDomain({bool isFromFallbackCache = false}) {
    String headerSubtitle = '';
    double parsedTotalDue = 0.0;
    double parsedRecentSpends = 0.0;
    int? explicitDueCount;
    String cashbackText = '';
    int topPendingActions = 0;

    final extractedCards = <BankCard>[];
    final seenIds = <String>{};

    for (var idx = 0; idx < items.length; idx++) {
      final section = items[idx];
      final template = section.templateName.toLowerCase();
      final body = section.body;

      if (template.contains('top_bar')) {
        final cta1Title = MarkupStripper.strip(
          _nestedString(body, const ['cta_1', 'title']),
        );
        if (cta1Title.isNotEmpty) {
          parsedRecentSpends = CurrencyFormatter.parseAmount(cta1Title);
        }
        continue;
      }

      if (template.contains('statement_info') ||
          template.contains('unbilled') ||
          template.contains('due_info')) {
        final statementMap = _asMap(body['statement']);
        final unbilledMap = _asMap(body['unbilled']);

        final sub = MarkupStripper.strip(
          _firstNonEmptyString(statementMap, const ['text_1']) ??
              _firstNonEmptyString(body, const ['subtitle', 'header', 'title']),
        );
        if (sub.isNotEmpty) {
          headerSubtitle = sub.toUpperCase();
        }

        final rawAmt = statementMap['amount'] ??
            _firstNonEmptyString(statementMap, const ['text_2']) ??
            body['amount'] ??
            body['due_amount'];
        if (rawAmt != null) {
          parsedTotalDue = rawAmt is num
              ? rawAmt.toDouble()
              : CurrencyFormatter.parseAmount(MarkupStripper.strip('$rawAmt'));
        }

        final dueCount = statementMap['due_count'];
        if (dueCount is int) {
          explicitDueCount = dueCount;
        }

        final rawUnbilled = unbilledMap['amount'] ??
            _firstNonEmptyString(unbilledMap, const ['text_2']);
        if (rawUnbilled != null) {
          final unbilledVal = rawUnbilled is num
              ? rawUnbilled.toDouble()
              : CurrencyFormatter.parseAmount(
                  MarkupStripper.strip('$rawUnbilled'),
                );
          if (unbilledVal > 0) {
            parsedRecentSpends = unbilledVal;
          }
        }

        for (final child in section.childList) {
          final childProps = _asMap(child['template_properties']);
          final childBody = _asMap(childProps['body']);
          final flippers =
              childBody['flipper_pill'] ?? childBody['flipper_config'];
          if (flippers is List && flippers.isNotEmpty) {
            final firstFlipper = _asMap(flippers.first);
            final offer = MarkupStripper.strip(
              _firstNonEmptyString(firstFlipper, const ['text_1', 'title']) ??
                  _nestedString(firstFlipper, const ['cta_1', 'title']),
            );
            if (offer.isNotEmpty && cashbackText.isEmpty) {
              cashbackText = offer;
            }
          }
        }
        continue;
      }

      if (template.contains('card_instrument') ||
          template.contains('card') ||
          section.childList.isNotEmpty) {
        final candidates = <Map<String, dynamic>>[];

        if (body.isNotEmpty &&
            (template.contains('card_instrument') || _looksLikeCard(body))) {
          candidates.add({
            if (section.externalId.isNotEmpty)
              'external_id': section.externalId,
            ...body,
          });
        }

        for (final child in section.childList) {
          final childProps = _asMap(child['template_properties']);
          final childBody = _asMap(childProps['body']);
          if (childBody.isNotEmpty) {
            candidates.add({
              if (child['external_id'] != null)
                'external_id': child['external_id'],
              ...childBody,
            });
          } else if (_looksLikeCard(child)) {
            candidates.add(child);
          }
        }

        for (var i = 0; i < candidates.length; i++) {
          final mapped = _mapCardFromApi(
            candidates[i],
            fallbackId: '${section.externalId}_${idx}_$i',
          );
          if (seenIds.add(mapped.id)) {
            extractedCards.add(mapped);
          }
        }
      }
    }

    final computedTotalDue = parsedTotalDue > 0
        ? parsedTotalDue
        : extractedCards.fold<double>(0.0, (sum, c) => sum + c.dueAmount);

    final computedRecentSpends = parsedRecentSpends > 0
        ? parsedRecentSpends
        : extractedCards.fold<double>(
            0.0,
            (sum, c) => sum + c.recentSpendAmount,
          );

    final activeDueCards = explicitDueCount ??
        extractedCards.where((c) => c.dueAmount > 0 && !c.isPaid).length;

    final resolvedPendingCount = topPendingActions > 0
        ? topPendingActions
        : extractedCards.fold<int>(
            0,
            (sum, c) => sum + c.pendingActionsCount,
          );

    return CardDashboard(
      headerSubtitle: headerSubtitle.isNotEmpty
          ? headerSubtitle
          : 'STATEMENT DUE FOR $activeDueCards ${activeDueCards == 1 ? 'CARD' : 'CARDS'}',
      totalDueAmount: computedTotalDue,
      totalRecentSpendsAmount: computedRecentSpends,
      dueCardsCount: activeDueCards,
      cashbackBannerText: cashbackText,
      pendingActionsCount: resolvedPendingCount,
      cards: extractedCards,
      isFromFallbackCache: isFromFallbackCache,
    );
  }

  static bool _looksLikeCard(Map<String, dynamic> map) {
    const candidateKeys = <String>{
      'instrument_id',
      'bank_name',
      'issuer',
      'card_number',
      'last_four',
      'last4',
      'text_3',
      'asset_1',
      'holder_name',
    };
    return map.keys.any(candidateKeys.contains);
  }

  static BankCard _mapCardFromApi(
    Map<String, dynamic> raw, {
    required String fallbackId,
  }) {
    final id = (raw['instrument_id'] ??
            raw['id'] ??
            raw['card_id'] ??
            raw['external_id'] ??
            fallbackId)
        .toString();

    final cardBackgroundUrl = _nestedString(raw, const ['asset_1', 'url']);
    final logoUrl = _nestedString(raw, const ['asset_3', 'url']) ??
        _nestedString(raw, const ['bank_logo', 'url']) ??
        _firstNonEmptyString(raw, const ['logo_url', 'icon_url']);

    final explicitBank = MarkupStripper.strip(
      _firstNonEmptyString(raw, const ['bank_name', 'issuer', 'issuer_name']) ??
          '',
    );
    final bankName = explicitBank.isNotEmpty
        ? explicitBank.toUpperCase()
        : _extractBankNameFromAssetUrl(cardBackgroundUrl ?? logoUrl ?? '');

    final rawDigits = _firstNonEmptyString(raw, const [
          'last_four',
          'last4',
          'text_3',
          'card_number',
          'masked_number',
        ]) ??
        '';
    final digitsOnly = rawDigits.replaceAll(RegExp(r'[^0-9]'), '');
    final lastFour = digitsOnly.length >= 4
        ? digitsOnly.substring(digitsOnly.length - 4)
        : (digitsOnly.isNotEmpty ? digitsOnly.padLeft(4, '•') : '••••');

    final holderName = MarkupStripper.strip(
      _firstNonEmptyString(raw, const [
            'holder_name',
            'cardholder_name',
            'text_4',
            'user_name',
          ]) ??
          'CARD MEMBER',
    ).toUpperCase();

    final statementMap = _asMap(raw['statement']);
    final dueRaw = _firstNonEmptyString(statementMap, const ['text_1']) ??
        _firstNonEmptyString(raw, const ['due_amount', 'amount']);
    final dueAmount = dueRaw != null
        ? CurrencyFormatter.parseAmount(MarkupStripper.strip(dueRaw))
        : 0.0;

    final dueDateRaw = MarkupStripper.strip(
      _firstNonEmptyString(statementMap, const ['text_2']) ??
          _firstNonEmptyString(raw, const ['due_date', 'due_text']) ??
          '',
    );
    final dueDateText = dueDateRaw.isNotEmpty
        ? dueDateRaw.toUpperCase()
        : (dueAmount <= 0 ? 'NO DUES' : '');

    int pendingActions = (raw['pending_actions'] as int?) ?? 0;
    final flipperPill = raw['flipper_pill'];
    if (pendingActions == 0 && flipperPill is List) {
      for (final item in flipperPill) {
        final pillMap = _asMap(item);
        if (pillMap['type'] == 'pending_action') {
          final title = MarkupStripper.strip(
            _nestedString(pillMap, const ['cta_1', 'title']),
          );
          final match = RegExp(r'(\d+)').firstMatch(title);
          if (match != null) {
            pendingActions = int.tryParse(match.group(1)!) ?? 1;
          } else {
            pendingActions = 1;
          }
        }
      }
    }

    final recentSpend = CurrencyFormatter.parseAmount(
      _firstNonEmptyString(raw, const ['recent_spends', 'unbilled_amount']) ??
          '0',
    );

    final colors = _resolveBrandPalette(bankName);
    final formattedDue = CurrencyFormatter.splitInr(dueAmount).fullFormatted;

    return BankCard(
      id: id,
      bankName: bankName,
      lastFourDigits: lastFour,
      cardHolderName: holderName,
      dueAmount: dueAmount,
      recentSpendAmount: recentSpend,
      dueDateText: dueDateText,
      isPaid: raw['is_paid'] == true || dueAmount <= 0,
      primaryColor: colors.$1,
      secondaryColor: colors.$2,
      pattern: _resolvePattern(bankName),
      logoUrl: logoUrl,
      cardBackgroundUrl: cardBackgroundUrl,
      pendingActionsCount: pendingActions,
      statementSummary: StatementSummary(
        sectionDateLabel:
            dueDateText.isNotEmpty ? dueDateText : 'CURRENT CYCLE',
        latestStatementText: dueAmount > 0
            ? '$formattedDue statement due'
            : 'No outstanding statement due',
        recentSpendsText: recentSpend > 0
            ? '${CurrencyFormatter.splitInr(recentSpend).fullFormatted} recent spends'
            : 'No unbilled spends recorded',
        cardOffersText: 'Tap to inspect statement & rewards',
      ),
    );
  }

  static String _extractBankNameFromAssetUrl(String url) {
    if (url.isEmpty) return 'CREDIT CARD';
    final decoded = Uri.decodeFull(url);
    final fileName = decoded.split('/').last.split('.').first.toUpperCase();
    final cleaned = fileName
        .replaceAll('CARD BACKGROUND', '')
        .replaceAll('MINI CARD', '')
        .replaceAll('BACKGROUND', '')
        .replaceAll('_', ' ')
        .trim();
    return cleaned.isNotEmpty ? cleaned : 'CREDIT CARD';
  }

  static (Color, Color) _resolveBrandPalette(String bankName) {
    if (bankName.contains('AXIS')) {
      return (const Color(0xFF8C1D40), const Color(0xFF561026));
    }
    if (bankName.contains('HDFC')) {
      return (const Color(0xFF1A3A6C), const Color(0xFF0E2140));
    }
    if (bankName.contains('YES')) {
      return (const Color(0xFF114B8A), const Color(0xFF0A2E57));
    }
    if (bankName.contains('IDFC')) {
      return (const Color(0xFF9C1D26), const Color(0xFF5E1016));
    }
    if (bankName.contains('SBI')) {
      return (const Color(0xFF1A6096), const Color(0xFF0D3A5E));
    }
    if (bankName.contains('ICICI')) {
      return (const Color(0xFFB04A1C), const Color(0xFF69290E));
    }
    final hue = (bankName.hashCode.abs() % 360).toDouble();
    return (
      HSLColor.fromAHSL(1.0, hue, 0.58, 0.30).toColor(),
      HSLColor.fromAHSL(1.0, hue, 0.64, 0.18).toColor(),
    );
  }

  static CardArtworkPattern _resolvePattern(String bankName) {
    if (bankName.contains('AXIS')) return CardArtworkPattern.axisGeometric;
    if (bankName.contains('HDFC')) return CardArtworkPattern.hdfcMesh;
    if (bankName.contains('YES')) return CardArtworkPattern.yesMandala;
    if (bankName.contains('IDFC')) return CardArtworkPattern.idfcLines;
    return CardArtworkPattern.sbiRupeePattern;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static String? _nestedString(Map<String, dynamic> map, List<String> path) {
    dynamic current = map;
    for (final key in path) {
      if (current is Map) {
        current = current[key];
      } else {
        return null;
      }
    }
    final str = current?.toString().trim();
    return (str != null && str.isNotEmpty) ? str : null;
  }

  static String? _firstNonEmptyString(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = map[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}

class SectionItemDto {
  const SectionItemDto({
    required this.externalId,
    required this.entityType,
    required this.templateName,
    required this.body,
    required this.childList,
  });

  final String externalId;
  final String entityType;
  final String templateName;
  final Map<String, dynamic> body;
  final List<Map<String, dynamic>> childList;

  factory SectionItemDto.fromJson(Map<String, dynamic> json) {
    final templateProps = json['template_properties'];
    Map<String, dynamic> bodyMap = const {};
    List<Map<String, dynamic>> children = const [];

    if (templateProps is Map) {
      final rawBody = templateProps['body'];
      if (rawBody is Map) {
        bodyMap = Map<String, dynamic>.from(rawBody);
      }
      final rawChildren = templateProps['child_list'];
      if (rawChildren is List) {
        children = rawChildren
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList(growable: false);
      }
    }

    return SectionItemDto(
      externalId: (json['external_id'] ?? '').toString(),
      entityType: (json['entity_type'] ?? 'section').toString(),
      templateName: (json['template_name'] ?? '').toString(),
      body: bodyMap,
      childList: children,
    );
  }
}
