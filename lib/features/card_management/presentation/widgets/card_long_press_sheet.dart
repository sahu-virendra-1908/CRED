import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_action_item.dart';
import 'bank_card_artwork.dart';

class CardLongPressSheet extends StatefulWidget {
  const CardLongPressSheet({
    super.key,
    required this.card,
    required this.onDismiss,
    required this.onActionSelected,
    required this.onPayNow,
  });

  final BankCard card;
  final VoidCallback onDismiss;
  final ValueChanged<CardQuickActionType> onActionSelected;
  final VoidCallback onPayNow;

  @override
  State<CardLongPressSheet> createState() => _CardLongPressSheetState();
}

class _CardLongPressSheetState extends State<CardLongPressSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _closeSheet([VoidCallback? afterClose]) async {
    if (_isClosing) return;
    _isClosing = true;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismiss();
    afterClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final formattedDue =
        CurrencyFormatter.splitInr(widget.card.dueAmount).fullFormatted;

    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, _) {
        final t = _curvedAnimation.value;
        // Realistic 3D flip/tilt as the card rises from stack into the expanded slot
        final flipX = math.sin(t * math.pi) * (math.pi / 4.2);
        final flipY = math.sin(t * math.pi) * (math.pi / 16);
        final cardRiseY = (1.0 - t) * (screenHeight * 0.24);
        final cardScale = 0.96 + (0.04 * t);

        return GestureDetector(
          key: const Key('card_detail_backdrop'),
          onTap: () => _closeSheet(),
          onVerticalDragUpdate: (details) {
            if (_isClosing) return;
            final delta = details.primaryDelta ?? 0;
            if (delta < 0) {
              _controller.value =
                  (_controller.value + (delta / (screenHeight * 0.35)))
                      .clamp(0.0, 1.0);
            }
          },
          onVerticalDragEnd: (details) {
            if (_isClosing) return;
            if ((details.primaryVelocity ?? 0) < -300 ||
                _controller.value < 0.65) {
              _closeSheet();
            } else {
              _controller.forward();
            }
          },
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.68 * t),
            child: Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {},
                child: Transform.translate(
                  offset: Offset(0, -(1.0 - t) * (screenHeight * 0.45)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20, topInset + 10, 20, 22),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x3D000000),
                          blurRadius: 28,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${widget.card.bankName} \u2022\u2022 ${widget.card.lastFourDigits}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                              IconButton(
                                key: const Key('close_card_detail_button'),
                                onPressed: () => _closeSheet(),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppColors.inkPrimary,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0018)
                              ..translateByDouble(0.0, cardRiseY, 0.0, 1.0)
                              ..rotateX(flipX)
                              ..rotateY(flipY)
                              ..scaleByDouble(cardScale, cardScale, 1.0, 1.0),
                            child: BankCardArtwork(
                              card: widget.card,
                              isDockedInSheet: true,
                              onPayNow: () => _closeSheet(widget.onPayNow),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  key: const Key('detail_mark_as_paid'),
                                  onTap: () => _closeSheet(
                                    () => widget.onActionSelected(
                                      CardQuickActionType.markAsPaid,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 20,
                                          color: AppColors.inkPrimary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'mark as paid',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.inkPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: AppColors.borderSubtle,
                              ),
                              Expanded(
                                child: InkWell(
                                  key: const Key('detail_payment_history'),
                                  onTap: () => _closeSheet(
                                    () => widget.onActionSelected(
                                      CardQuickActionType.paymentHistory,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history_edu_outlined,
                                          size: 20,
                                          color: AppColors.inkPrimary,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'payment history',
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.inkPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 22,
                            color: AppColors.borderSubtle,
                          ),
                          Text(
                            widget.card.statementSummary.sectionDateLabel
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DetailInfoRow(
                            icon: Icons.description_outlined,
                            label: 'latest statement',
                            value: widget.card.dueAmount > 0
                                ? '$formattedDue bill generated'
                                : widget
                                    .card.statementSummary.latestStatementText,
                            onTap: () => _closeSheet(
                              () => widget.onActionSelected(
                                CardQuickActionType.smartStatement,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _DetailInfoRow(
                            icon: Icons.currency_rupee_rounded,
                            label: 'recent spends',
                            value: widget.card.recentSpendAmount > 0
                                ? widget.card.statementSummary.recentSpendsText
                                : 'no spends since last statement',
                            onTap: () => _closeSheet(
                              () => widget.onActionSelected(
                                CardQuickActionType.recentSpends,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _DetailInfoRow(
                            icon: Icons.percent_rounded,
                            label: 'card offers',
                            value: 'verify card to unlock',
                            onTap: () => _closeSheet(
                              () => widget.onActionSelected(
                                CardQuickActionType.cardOffers,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: 19, color: AppColors.inkPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.inkSecondary,
          ),
        ],
      ),
    );
  }
}
