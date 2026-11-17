import '../models/card_dashboard_dto.dart';

abstract interface class CardLocalMockDataSource {
  Future<CardDashboardDto> loadFallbackDashboard();
}

/// Optional offline development fixture mirroring the Mocklets SDUI envelope.
class CardLocalMockDataSourceImpl implements CardLocalMockDataSource {
  const CardLocalMockDataSourceImpl();

  @override
  Future<CardDashboardDto> loadFallbackDashboard() async {
    return CardDashboardDto.fromJson(_mockletsEnvelopeFixture);
  }

  static const Map<String, dynamic> _mockletsEnvelopeFixture = {
    'items': [
      {
        'external_id': 'section_top_bar',
        'entity_type': 'section',
        'template_name': 'cm_top_bar',
        'template_properties': {
          'body': {
            'template_type': 'cm_top_bar',
            'cta_1': {
              'type': 'flow',
              'title': '<format>₹9,67,340</format>',
            },
          },
          'child_list': <Map<String, dynamic>>[],
        },
      },
      {
        'external_id': 'section_statement',
        'entity_type': 'section',
        'template_name': 'unbilled_statement_info_section_v2',
        'template_properties': {
          'body': {
            'subtitle': 'STATEMENT DUE FOR 1 CARD',
            'amount': '₹50,000.00',
            'banner_text': 'get ₹50 cashback on full bill payments',
          },
          'child_list': <Map<String, dynamic>>[],
        },
      },
    ],
  };
}
