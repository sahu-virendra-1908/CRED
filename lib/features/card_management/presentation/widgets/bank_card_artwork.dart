import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/bank_card.dart';

class BankCardArtwork extends StatelessWidget {
  const BankCardArtwork({
    super.key,
    required this.card,
    required this.onPayNow,
    this.isDimmed = false,
    this.isDockedInSheet = false,
  });

  final BankCard card;
  final VoidCallback onPayNow;
  final bool isDimmed;
  final bool isDockedInSheet;

  @override
  Widget build(BuildContext context) {
    final amountParts = CurrencyFormatter.splitInr(card.dueAmount);
    final showDueDetails =
        card.dueAmount > 0 && !card.isPaid && !isDockedInSheet;
    final hasRemoteCardArt =
        card.cardBackgroundUrl != null && card.cardBackgroundUrl!.isNotEmpty;

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1.586,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final scale = (w / 344.0).clamp(0.76, 1.32);
            final pad = (18.0 * scale).clamp(12.0, 26.0);
            final logoBandHeight = (24.0 * scale).clamp(18.0, 32.0);
            final amountFontSize = (18.0 * scale).clamp(14.0, 24.0);
            final digitsFontSize = (13.0 * scale).clamp(10.5, 17.0);
            final dueDateFontSize = (10.0 * scale).clamp(8.5, 13.0);
            final holderFontSize = (12.5 * scale).clamp(10.0, 16.0);
            final btnHeight = (35.0 * scale).clamp(28.0, 44.0);
            final btnHPad = (16.0 * scale).clamp(12.0, 24.0);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [card.primaryColor, card.secondaryColor],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, -3),
                  ),
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasRemoteCardArt)
                      Image.network(
                        card.cardBackgroundUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _FallbackCardBase(card: card, scale: scale),
                      )
                    else
                      _FallbackCardBase(card: card, scale: scale),
                    Padding(
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: logoBandHeight),
                                    if (!isDockedInSheet) ...[
                                      SizedBox(height: 8.0 * scale),
                                      Text(
                                        '\u2022\u2022  ${card.lastFourDigits}',
                                        style: TextStyle(
                                          fontSize: digitsFontSize,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.4,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (showDueDetails)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${amountParts.symbol}${amountParts.wholePart}',
                                            style: TextStyle(
                                              fontSize: amountFontSize,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '.${amountParts.decimalPart}',
                                            style: TextStyle(
                                              fontSize: amountFontSize,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 3.0 * scale),
                                    Text(
                                      card.dueDateText,
                                      style: TextStyle(
                                        fontSize: dueDateFontSize,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                        color: const Color(0xD9FFFFFF),
                                      ),
                                    ),
                                  ],
                                )
                              else if (card.isPaid && !isDockedInSheet)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0 * scale,
                                    vertical: 4.0 * scale,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x29FFFFFF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'NO DUES',
                                    style: TextStyle(
                                      fontSize: dueDateFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (!isDockedInSheet && !isDimmed)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    card.cardHolderName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: holderFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.0 * scale),
                                SizedBox(
                                  height: btnHeight,
                                  child: ElevatedButton(
                                    onPressed: onPayNow,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF141416),
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: btnHPad,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Pay now',
                                      style: TextStyle(
                                        fontSize:
                                            (13.0 * scale).clamp(11.0, 15.5),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (isDimmed)
                      const ColoredBox(
                        color: Color(0x29000000),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FallbackCardBase extends StatelessWidget {
  const _FallbackCardBase({
    required this.card,
    required this.scale,
  });

  final BankCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final pad = (18.0 * scale).clamp(12.0, 26.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _CardPatternPainter(pattern: card.pattern),
        ),
        Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white,
                    size: (18.0 * scale).clamp(14.0, 22.0),
                  ),
                  SizedBox(width: 6.0 * scale),
                  Text(
                    card.bankName,
                    style: TextStyle(
                      fontSize: (13.5 * scale).clamp(11.0, 17.0),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.0 * scale),
              _EmvChipIllustration(scale: scale),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmvChipIllustration extends StatelessWidget {
  const _EmvChipIllustration({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0 * scale,
      height: 26.0 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6E8EC),
            Color(0xFFB7BCC4),
          ],
        ),
        border: Border.all(color: const Color(0x80FFFFFF), width: 0.8),
      ),
      child: CustomPaint(painter: _ChipLinesPainter()),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x664A4E57)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter({required this.pattern});

  final CardArtworkPattern pattern;

  @override
  void paint(Canvas canvas, Size size) {
    final subtleFill = Paint()
      ..color = const Color(0x14FFFFFF)
      ..style = PaintingStyle.fill;

    final subtleStroke = Paint()
      ..color = const Color(0x18FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    switch (pattern) {
      case CardArtworkPattern.axisGeometric:
        final path = Path()
          ..moveTo(size.width * 0.25, 0)
          ..lineTo(size.width * 0.58, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, subtleFill);
        break;
      case CardArtworkPattern.hdfcMesh:
        final center = Offset(size.width * 0.42, size.height * 1.15);
        for (double r = 60; r <= 190; r += 26) {
          canvas.drawCircle(center, r, subtleStroke);
        }
        break;
      case CardArtworkPattern.yesMandala:
        final center = Offset(size.width * 0.55, size.height * 0.95);
        for (double r = 45; r <= 165; r += 24) {
          canvas.drawCircle(center, r, subtleStroke);
        }
        for (int i = 0; i < 12; i++) {
          final angle = (math.pi * 2 / 12) * i;
          canvas.drawLine(
            center,
            Offset(
              center.dx + math.cos(angle) * 165,
              center.dy + math.sin(angle) * 165,
            ),
            subtleStroke,
          );
        }
        break;
      case CardArtworkPattern.idfcLines:
      case CardArtworkPattern.sbiRupeePattern:
        for (double x = 24; x < size.width; x += 48) {
          canvas.drawCircle(Offset(x, size.height * 0.45), 18, subtleStroke);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern;
}
