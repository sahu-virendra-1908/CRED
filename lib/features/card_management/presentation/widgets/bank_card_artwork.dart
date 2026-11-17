import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
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
        child: Container(
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
                    errorBuilder: (_, __, ___) => _FallbackCardBase(card: card),
                  )
                else
                  _FallbackCardBase(card: card),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
                                // Reserve exact height of baked-in bank logo row in CloudFront art
                                const SizedBox(height: 24),
                                if (!isDockedInSheet) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    '\u2022\u2022  ${card.lastFourDigits}',
                                    style: AppTypography.cardDigits,
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
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '.${amountParts.decimalPart}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.dueDateText,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color: Color(0xD9FFFFFF),
                                  ),
                                ),
                              ],
                            )
                          else if (card.isPaid && !isDockedInSheet)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x29FFFFFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'NO DUES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      if (!isDockedInSheet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                card.cardHolderName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.cardHolderName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: onPayNow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF141416),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Pay now',
                                  style: TextStyle(
                                    fontSize: 13,
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
        ),
      ),
    );
  }
}

class _FallbackCardBase extends StatelessWidget {
  const _FallbackCardBase({required this.card});

  final BankCard card;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _CardPatternPainter(pattern: card.pattern),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.credit_card_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    card.bankName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const _EmvChipIllustration(),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmvChipIllustration extends StatelessWidget {
  const _EmvChipIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
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
