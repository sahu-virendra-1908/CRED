import 'package:cred_card_management/features/card_management/data/models/card_dashboard_dto.dart';
import 'package:cred_card_management/features/card_management/domain/entities/card_dashboard.dart';

abstract final class TestFixtures {
  static const Map<String, dynamic> mockletsApiResponse = {
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
      {
        'external_id': 'section_cards',
        'entity_type': 'section',
        'template_name': 'card_carousel_section',
        'template_properties': {
          'body': <String, dynamic>{
            'pending_count': 2,
          },
          'child_list': [
            {
              'id': 'card_axis_1234',
              'bank_name': 'AXIS BANK',
              'last_four': '1234',
              'holder_name': 'SNEHA IYER',
              'due_amount': '50000.00',
              'recent_spends': '18420.00',
              'due_date': 'DUE ON 18 SEP',
              'primary_color': '#A40047',
              'secondary_color': '#7E0036',
              'statement_section_date': 'SEPTEMBER 7TH',
              'latest_statement': '₹50,000.00 bill generated on 28 Aug',
              'recent_spends_summary': 'no spends since last statement',
              'card_offers_summary': 'verify card to unlock',
            },
            {
              'id': 'card_hdfc_5501',
              'bank_name': 'HDFC BANK',
              'last_four': '5501',
              'holder_name': 'SNEHA IYER',
              'due_amount': '0',
              'recent_spends': '42890.00',
              'primary_color': '#282A2E',
              'secondary_color': '#1A1B1E',
            },
            {
              'id': 'card_yes_7722',
              'bank_name': 'YES BANK',
              'last_four': '7722',
              'holder_name': 'DEEP GAURAV',
              'due_amount': '0',
              'recent_spends': '11250.00',
              'primary_color': '#008ED6',
              'secondary_color': '#003B95',
            },
          ],
        },
      },
    ],
  };

  static CardDashboard sampleDashboard() {
    return CardDashboardDto.fromJson(mockletsApiResponse).toDomain();
  }
}
