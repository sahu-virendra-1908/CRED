import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/card_dashboard.dart';
import '../providers/card_dashboard_state.dart';
import 'segmented_due_toggle.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.dashboard,
    required this.activeTab,
    required this.onTabChanged,
    required this.onPayBillPressed,
    required this.onOffersPressed,
    required this.onSettingsPressed,
    required this.onBannerPressed,
  });

  final CardDashboard dashboard;
  final HeaderSegmentTab activeTab;
  final ValueChanged<HeaderSegmentTab> onTabChanged;
  final VoidCallback onPayBillPressed;
  final VoidCallback onOffersPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onBannerPressed;

  @override
  Widget build(BuildContext context) {
    final isDueTab = activeTab == HeaderSegmentTab.totalDue;
    final displayAmount =
        isDueTab ? dashboard.totalDueAmount : dashboard.totalRecentSpendsAmount;
    final parts = CurrencyFormatter.splitInr(displayAmount);
    final subtitleText = isDueTab
        ? dashboard.headerSubtitle
        : 'TOTAL SPENDS ACROSS ${dashboard.cards.length} CARDS';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceWhite,
            AppColors.headerWarmCream,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HeaderRewardBackdropPainter(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconAction(
                        key: const Key('header_offers_button'),
                        icon: Icons.percent_rounded,
                        onTap: onOffersPressed,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SegmentedDueToggle(
                              activeTab: activeTab,
                              dueCount: dashboard.dueCardsCount,
                              onChanged: onTabChanged,
                            ),
                          ),
                        ),
                      ),
                      _CircleIconAction(
                        key: const Key('header_settings_button'),
                        icon: Icons.settings_outlined,
                        onTap: onSettingsPressed,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    subtitleText,
                    style: AppTypography.overlineCaps,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${parts.symbol}${parts.wholePart}',
                        style: AppTypography.heroAmountMajor,
                      ),
                      Text(
                        '.${parts.decimalPart}',
                        style: AppTypography.heroAmountMinor,
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: AppColors.inkPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      key: const Key('header_pay_bill_button'),
                      onPressed: onPayBillPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.inkPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.pillRadius),
                        ),
                      ),
                      child: Text(
                        isDueTab ? 'Pay bill' : 'View spends',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  if (dashboard.cashbackBannerText.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _CashbackBannerPill(
                      text: dashboard.cashbackBannerText,
                      onTap: onBannerPressed,
                    ),
                  ] else
                    const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRewardBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.62);

    // Warm radial glow behind ₹50,000.00
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFF6F1E7).withValues(alpha: 0.72),
          const Color(0xFFEBE3D3).withValues(alpha: 0.45),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.65));
    canvas.drawRect(Offset.zero & size, glowPaint);

    // Subtle curved arch behind the Pay bill CTA
    final archPaint = Paint()
      ..color = const Color(0x14A89B84)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.92),
        width: size.width * 0.78,
        height: size.height * 0.75,
      ),
      math.pi,
      math.pi,
      false,
      archPaint,
    );

    // Left gift box & golden star card
    _drawGiftCluster(
      canvas: canvas,
      boxCenter: Offset(18, size.height * 0.70),
      cardCenter: Offset(24, size.height * 0.56),
      cardAngle: -0.26,
      ribbonDirection: 1.0,
    );

    // Right gift box & golden star card
    _drawGiftCluster(
      canvas: canvas,
      boxCenter: Offset(size.width - 14, size.height * 0.76),
      cardCenter: Offset(size.width - 18, size.height * 0.61),
      cardAngle: 0.24,
      ribbonDirection: -1.0,
    );
  }

  void _drawGiftCluster({
    required Canvas canvas,
    required Offset boxCenter,
    required Offset cardCenter,
    required double cardAngle,
    required double ribbonDirection,
  }) {
    // Flowing champagne ribbon
    final ribbonPaint = Paint()
      ..color = const Color(0x55D4B87A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final ribbonPath = Path()
      ..moveTo(boxCenter.dx + (18 * ribbonDirection), boxCenter.dy - 8)
      ..quadraticBezierTo(
        boxCenter.dx + (46 * ribbonDirection),
        boxCenter.dy + 14,
        boxCenter.dx + (34 * ribbonDirection),
        boxCenter.dy + 48,
      );
    canvas.drawPath(ribbonPath, ribbonPaint);

    // Ivory gift box silhouette
    canvas.save();
    canvas.translate(boxCenter.dx, boxCenter.dy);
    canvas.rotate(cardAngle * 0.6);
    final boxRect = Rect.fromCenter(center: Offset.zero, width: 62, height: 54);
    final boxPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFEDE6D8)],
      ).createShader(boxRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      boxPaint,
    );
    final boxBorder = Paint()
      ..color = const Color(0x26B5A486)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      boxBorder,
    );
    canvas.restore();

    // Floating metallic gold star card
    canvas.save();
    canvas.translate(cardCenter.dx, cardCenter.dy);
    canvas.rotate(cardAngle);
    final cardRect =
        Rect.fromCenter(center: Offset.zero, width: 34, height: 24);
    final goldPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE7C97D), Color(0xFFC39A45)],
      ).createShader(cardRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(4)),
      goldPaint,
    );

    // Subtle 4-point star emblem on gold card
    final starPaint = Paint()..color = const Color(0xCCFFF8E6);
    final starPath = Path()
      ..moveTo(0, -5)
      ..lineTo(1.6, -1.6)
      ..lineTo(5, 0)
      ..lineTo(1.6, 1.6)
      ..lineTo(0, 5)
      ..lineTo(-1.6, 1.6)
      ..lineTo(-5, 0)
      ..lineTo(-1.6, -1.6)
      ..close();
    canvas.drawPath(starPath, starPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleIconAction extends StatelessWidget {
  const _CircleIconAction({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceWhite,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.inkPrimary,
          ),
        ),
      ),
    );
  }
}

class _CashbackBannerPill extends StatelessWidget {
  const _CashbackBannerPill({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E2F7),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                '\u20B9',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.rewardPlum,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.rewardPlum,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.inkSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
