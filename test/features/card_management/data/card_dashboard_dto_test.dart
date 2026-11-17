import 'package:cred_card_management/core/errors/exceptions.dart';
import 'package:cred_card_management/features/card_management/data/models/card_dashboard_dto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('CardDashboardDto', () {
    test('parses SDUI mocklets payload strictly from API fields', () {
      final dto = CardDashboardDto.fromJson(TestFixtures.mockletsApiResponse);
      final domain = dto.toDomain();

      expect(domain.totalDueAmount, 50000.0);
      expect(domain.totalRecentSpendsAmount, 967340.0);
      expect(domain.cards.length, 3);
      expect(domain.cards.first.bankName, 'AXIS BANK');
      expect(domain.cards.first.lastFourDigits, '1234');
      expect(domain.cards.first.cardHolderName, 'SNEHA IYER');
    });

    test('returns empty cards list when API contains no card items', () {
      final dto = CardDashboardDto.fromJson(const {
        'items': [
          {
            'external_id': 'sec_header',
            'entity_type': 'section',
            'template_name': 'cm_top_bar',
            'template_properties': {
              'body': <String, dynamic>{},
              'child_list': <Map<String, dynamic>>[],
            },
          },
        ],
      });

      final domain = dto.toDomain();
      expect(domain.cards, isEmpty);
    });

    test('deduplicates cards with duplicate IDs', () {
      final dto = CardDashboardDto.fromJson({
        'items': [
          {
            'external_id': 'sec_1',
            'entity_type': 'section',
            'template_name': 'card_carousel',
            'template_properties': {
              'body': <String, dynamic>{},
              'child_list': [
                {
                  'id': 'dup_1',
                  'bank_name': 'HDFC BANK',
                  'last_four': '5501',
                  'holder_name': 'Sneha Iyer',
                  'due_amount': '12000',
                },
                {
                  'id': 'dup_1',
                  'bank_name': 'HDFC BANK',
                  'last_four': '5501',
                  'holder_name': 'Sneha Iyer',
                  'due_amount': '12000',
                },
              ],
            },
          },
        ],
      });

      final domain = dto.toDomain();
      expect(domain.cards.length, 1);
      expect(domain.cards.first.id, 'dup_1');
    });

    test('throws InvalidPayloadException when items key is missing', () {
      expect(
        () => CardDashboardDto.fromJson(const {'unexpected': true}),
        throwsA(isA<InvalidPayloadException>()),
      );
    });
  });
}
