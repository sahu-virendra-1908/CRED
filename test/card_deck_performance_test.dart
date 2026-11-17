import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cred_card_management/features/card_management/domain/entities/bank_card.dart';
import 'package:cred_card_management/features/card_management/domain/entities/statement_summary.dart';
import 'package:cred_card_management/features/card_management/presentation/providers/card_dashboard_state.dart';
import 'package:cred_card_management/features/card_management/presentation/widgets/card_deck_stage.dart';

void main() {
  final sampleCards = List.generate(
    5,
    (i) => BankCard(
      id: 'card_$i',
      bankName: 'BANK $i',
      lastFourDigits: '123$i',
      cardHolderName: 'LOREM IPSUM',
      dueAmount: i == 0 ? 50000 : 0,
      recentSpendAmount: 12000,
      dueDateText: 'DUE ON 18 SEP',
      isPaid: i != 0,
      pendingActionsCount: i == 0 ? 2 : 0,
      primaryColor: const Color(0xFF8C1443),
      secondaryColor: const Color(0xFF560A28),
      pattern: CardArtworkPattern.axisGeometric,
      statementSummary: const StatementSummary(
        sectionDateLabel: 'SEPTEMBER 7TH',
        latestStatementText: '₹50,000.00 bill generated',
        recentSpendsText: 'no spends since last statement',
        cardOffersText: 'verify card to unlock',
      ),
    ),
  );

  testWidgets(
    'UI correctness & zero severe frame drops across swipe-left, long-press, and scroll-down list',
    (tester) async {
      final recordedTimings = <FrameTiming>[];
      void onTimings(List<FrameTiming> timings) {
        recordedTimings.addAll(timings);
      }

      tester.binding.addTimingsCallback(onTimings);
      addTearDown(() => tester.binding.removeTimingsCallback(onTimings));

      var mode = DeckPresentationMode.collapsedStack;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CardDeckStage(
                  cards: sampleCards,
                  selectedIndex: 0,
                  deckMode: mode,
                  pendingActionsCount: 2,
                  onSelectCard: (_) {},
                  onDeckModeChanged: (next) => setState(() => mode = next),
                  onQuickAction: (_) {},
                  onPayNow: (_) {},
                  onPendingActionsTap: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Swipe left on active card -> opens quick actions rail
      await tester.fling(
        find.byKey(const Key('active_bank_card')),
        const Offset(-240, 0),
        900,
      );
      await tester.pumpAndSettle();
      expect(mode, DeckPresentationMode.peekQuickActions);
      expect(find.byKey(const Key('action_mark_as_paid')), findsOneWidget);

      // Tap left edge of shifted active card to restore collapsed stack
      final cardRect =
          tester.getRect(find.byKey(const Key('active_bank_card')));
      await tester.tapAt(Offset(cardRect.left + 20, cardRect.center.dy));
      await tester.pumpAndSettle();
      expect(mode, DeckPresentationMode.collapsedStack);

      // 2. Long press on active card -> triggers longPressDetail state
      await tester.longPress(find.byKey(const Key('active_bank_card')));
      await tester.pumpAndSettle();
      expect(mode, DeckPresentationMode.longPressDetail);

      // Reset to collapsed stack for scroll-down test
      mode = DeckPresentationMode.collapsedStack;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CardDeckStage(
                  cards: sampleCards,
                  selectedIndex: 0,
                  deckMode: mode,
                  pendingActionsCount: 2,
                  onSelectCard: (_) {},
                  onDeckModeChanged: (next) => setState(() => mode = next),
                  onQuickAction: (_) {},
                  onPayNow: (_) {},
                  onPendingActionsTap: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 3. Scroll down on deck surface -> opens expanded vertical list
      await tester.fling(
        find.byKey(const Key('card_deck_gesture_surface')),
        const Offset(0, 260),
        900,
      );
      await tester.pumpAndSettle();
      expect(mode, DeckPresentationMode.expandedVerticalList);
      expect(find.byKey(const Key('expanded_cards_list_view')), findsOneWidget);

      // Verify zero severe jank frames (> 32ms build+raster budget)
      final severeJankFrames = recordedTimings
          .where((t) => t.totalSpan.inMicroseconds > 32000)
          .length;
      expect(severeJankFrames, 0);
    },
  );
}
