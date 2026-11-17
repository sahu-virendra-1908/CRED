import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/bank_card.dart';
import '../../domain/entities/card_action_item.dart';
import '../providers/card_dashboard_state.dart';
import 'bank_card_artwork.dart';
import 'quick_action_radial_rail.dart';

class CardDeckStage extends StatefulWidget {
  const CardDeckStage({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.deckMode,
    required this.pendingActionsCount,
    required this.onSelectCard,
    required this.onDeckModeChanged,
    required this.onQuickAction,
    required this.onPayNow,
    required this.onPendingActionsTap,
    this.flipperInterval = const Duration(milliseconds: 2200),
  });

  final List<BankCard> cards;
  final int selectedIndex;
  final DeckPresentationMode deckMode;
  final int pendingActionsCount;
  final ValueChanged<int> onSelectCard;
  final ValueChanged<DeckPresentationMode> onDeckModeChanged;
  final ValueChanged<CardQuickActionType> onQuickAction;
  final ValueChanged<BankCard> onPayNow;
  final VoidCallback onPendingActionsTap;
  final Duration flipperInterval;

  @override
  State<CardDeckStage> createState() => _CardDeckStageState();
}

class _CardDeckStageState extends State<CardDeckStage>
    with TickerProviderStateMixin {
  late final AnimationController _peekController;
  late final AnimationController _expandController;
  late final AnimationController _pressScaleController;
  late final ScrollController _verticalListController;

  bool _isHorizontalDragging = false;
  bool _isVerticalDragging = false;
  double _dragStartPeekValue = 0.0;
  double _dragStartExpandValue = 0.0;

  @override
  void initState() {
    super.initState();
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value:
          widget.deckMode == DeckPresentationMode.peekQuickActions ? 1.0 : 0.0,
    );
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      value: widget.deckMode == DeckPresentationMode.expandedVerticalList
          ? 1.0
          : 0.0,
    );
    _pressScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      value: 0.0,
    );
    _verticalListController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant CardDeckStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deckMode != widget.deckMode) {
      if (widget.deckMode == DeckPresentationMode.peekQuickActions) {
        _peekController.animateTo(1.0, curve: Curves.easeOutCubic);
      } else {
        _peekController.animateTo(0.0, curve: Curves.easeOutCubic);
      }

      if (widget.deckMode == DeckPresentationMode.expandedVerticalList) {
        _expandController.animateTo(1.0, curve: Curves.easeOutCubic);
      } else {
        _expandController.animateTo(0.0, curve: Curves.easeOutCubic);
        if (_verticalListController.hasClients) {
          _verticalListController.jumpTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    _peekController.dispose();
    _expandController.dispose();
    _pressScaleController.dispose();
    _verticalListController.dispose();
    super.dispose();
  }

  bool get _isInteractionLocked =>
      _peekController.isAnimating ||
      _expandController.isAnimating ||
      widget.deckMode == DeckPresentationMode.longPressDetail;

  void _handleHorizontalDragStart(DragStartDetails details) {
    if (_expandController.value > 0.1 || _isInteractionLocked) return;
    _isHorizontalDragging = true;
    _dragStartPeekValue = _peekController.value;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (!_isHorizontalDragging) return;
    final deltaFraction = -(details.primaryDelta ?? 0.0) / (width * 0.45);
    _peekController.value =
        (_peekController.value + deltaFraction).clamp(0.0, 1.0);
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_isHorizontalDragging) return;
    _isHorizontalDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final shouldOpenPeek = velocity < -320 ||
        (velocity.abs() <= 320 &&
            (_peekController.value > 0.35 ||
                (_dragStartPeekValue == 0.0 && _peekController.value > 0.2)));

    if (shouldOpenPeek) {
      _peekController.animateTo(1.0, curve: Curves.easeOutCubic);
      widget.onDeckModeChanged(DeckPresentationMode.peekQuickActions);
    } else {
      _peekController.animateTo(0.0, curve: Curves.easeOutCubic);
      widget.onDeckModeChanged(DeckPresentationMode.collapsedStack);
    }
  }

  void _handleVerticalDragStart(DragStartDetails details) {
    if (_peekController.value > 0.15 || _isInteractionLocked) return;
    _isVerticalDragging = true;
    _dragStartExpandValue = _expandController.value;
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details, double height) {
    if (!_isVerticalDragging) return;
    final delta = (details.primaryDelta ?? 0.0) / (height * 0.42);
    _expandController.value = (_expandController.value + delta).clamp(0.0, 1.0);
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (!_isVerticalDragging) return;
    _isVerticalDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;
    final shouldExpand = velocity > 320 ||
        (velocity.abs() <= 320 &&
            (_expandController.value > 0.38 ||
                (_dragStartExpandValue == 0.0 &&
                    _expandController.value > 0.22)));

    if (shouldExpand) {
      _expandController.animateTo(1.0, curve: Curves.easeOutCubic);
      widget.onDeckModeChanged(DeckPresentationMode.expandedVerticalList);
    } else {
      _expandController.animateTo(0.0, curve: Curves.easeOutCubic);
      widget.onDeckModeChanged(DeckPresentationMode.collapsedStack);
    }
  }

  void _handleLongPressStart() {
    if (_isHorizontalDragging ||
        _isVerticalDragging ||
        _expandController.value > 0.1 ||
        _isInteractionLocked) {
      return;
    }
    _pressScaleController.forward();
  }

  void _handleLongPressTriggered() {
    if (_isHorizontalDragging ||
        _isVerticalDragging ||
        _expandController.value > 0.1 ||
        _isInteractionLocked) {
      _pressScaleController.reverse();
      return;
    }
    HapticFeedback.mediumImpact();
    _pressScaleController.reverse();
    widget.onDeckModeChanged(DeckPresentationMode.longPressDetail);
  }

  void _handleLongPressCancel() {
    _pressScaleController.reverse();
  }

  void _openCardDetailFoldout() {
    if (_isInteractionLocked) return;
    HapticFeedback.lightImpact();
    widget.onDeckModeChanged(DeckPresentationMode.longPressDetail);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = widget.selectedIndex.clamp(0, widget.cards.length - 1);
    final activeCard = widget.cards[safeIndex];
    final effectivePendingCount = activeCard.pendingActionsCount > 0
        ? activeCard.pendingActionsCount
        : (safeIndex == 0 ? widget.pendingActionsCount : 0);

    final stackedCards = <MapEntry<int, BankCard>>[];
    for (int i = 0; i < widget.cards.length; i++) {
      if (i != safeIndex) {
        stackedCards.add(MapEntry(i, widget.cards[i]));
      }
    }

    final isDetailOpen =
        widget.deckMode == DeckPresentationMode.longPressDetail;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stageWidth = constraints.maxWidth;
        final stageHeight = constraints.maxHeight;
        final horizontalPadding = AppSpacing.md;
        final cardWidth = stageWidth - (horizontalPadding * 2);
        final cardHeight = cardWidth / 1.586;

        return GestureDetector(
          key: const Key('card_deck_gesture_surface'),
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: _handleVerticalDragStart,
          onVerticalDragUpdate: (d) =>
              _handleVerticalDragUpdate(d, stageHeight),
          onVerticalDragEnd: _handleVerticalDragEnd,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _peekController,
              _expandController,
              _pressScaleController,
            ]),
            builder: (context, _) {
              final peekT = _peekController.value;
              final expandT = _expandController.value;
              final pressScale = 1.0 - (_pressScaleController.value * 0.03);

              if (expandT > 0.85) {
                return _ExpandedVerticalCardList(
                  cards: widget.cards,
                  selectedIndex: safeIndex,
                  controller: _verticalListController,
                  onSelectCard: widget.onSelectCard,
                  onCollapse: () {
                    _expandController.animateTo(
                      0.0,
                      curve: Curves.easeOutCubic,
                    );
                    widget.onDeckModeChanged(
                      DeckPresentationMode.collapsedStack,
                    );
                  },
                  onPayNow: widget.onPayNow,
                );
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  if (peekT > 0.01)
                    Positioned(
                      top: 10,
                      right: 14,
                      width: stageWidth * 0.46,
                      height: cardHeight,
                      child: Opacity(
                        opacity: peekT.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset((1.0 - peekT) * 28, 0),
                          child: QuickActionRadialRail(
                            onActionSelected: widget.onQuickAction,
                          ),
                        ),
                      ),
                    ),
                  // Layered bottom card deck (back-to-front z-index order)
                  ..._buildBottomStackedCards(
                    stackedCards: stackedCards,
                    stageWidth: stageWidth,
                    stageHeight: stageHeight,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    expandT: expandT,
                  ),
                  // Primary front card
                  Positioned(
                    top: 10,
                    left: horizontalPadding,
                    width: cardWidth,
                    child: IgnorePointer(
                      ignoring: isDetailOpen,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: isDetailOpen ? 0.0 : 1.0,
                        child: GestureDetector(
                          key: const Key('active_bank_card'),
                          onHorizontalDragStart: _handleHorizontalDragStart,
                          onHorizontalDragUpdate: (d) =>
                              _handleHorizontalDragUpdate(d, stageWidth),
                          onHorizontalDragEnd: _handleHorizontalDragEnd,
                          onLongPressDown: (_) => _handleLongPressStart(),
                          onLongPress: _handleLongPressTriggered,
                          onLongPressCancel: _handleLongPressCancel,
                          onTap: () {
                            if (peekT > 0.5) {
                              _peekController.animateTo(
                                0.0,
                                curve: Curves.easeOutCubic,
                              );
                              widget.onDeckModeChanged(
                                DeckPresentationMode.collapsedStack,
                              );
                            } else {
                              _openCardDetailFoldout();
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              );
                            },
                            child: Transform(
                              key: ValueKey(activeCard.id),
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.0014)
                                ..translateByDouble(
                                  -peekT * (cardWidth * 0.44),
                                  expandT * 8,
                                  0.0,
                                  1.0,
                                )
                                ..rotateY(-peekT * (math.pi / 11))
                                ..scaleByDouble(
                                  pressScale,
                                  pressScale,
                                  1.0,
                                  1.0,
                                ),
                              child: BankCardArtwork(
                                card: activeCard,
                                onPayNow: () => widget.onPayNow(activeCard),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (peekT < 0.25)
                    Positioned(
                      top: 10 + cardHeight + 12 + (expandT * 24),
                      left: 0,
                      right: 0,
                      child: Opacity(
                        opacity: (1.0 - (peekT * 4)).clamp(0.0, 1.0) *
                            (1.0 - expandT),
                        child: Center(
                          child: _FlipperActionPill(
                            cardId: activeCard.id,
                            pendingCount: effectivePendingCount,
                            interval: widget.flipperInterval,
                            isPaused: isDetailOpen ||
                                _isHorizontalDragging ||
                                _isVerticalDragging ||
                                peekT > 0.05 ||
                                expandT > 0.05,
                            onPendingActionsTap: widget.onPendingActionsTap,
                            onViewDetailsTap: _openCardDetailFoldout,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> _buildBottomStackedCards({
    required List<MapEntry<int, BankCard>> stackedCards,
    required double stageWidth,
    required double stageHeight,
    required double cardWidth,
    required double cardHeight,
    required double expandT,
  }) {
    if (stackedCards.isEmpty) return const <Widget>[];

    final visibleCount = math.min(stackedCards.length, 4);
    final widgets = <Widget>[];

    // Staggered vertical fan so all 4 background cards clearly peek out above bottom edge
    const peekHeights = <double>[86.0, 134.0, 160.0, 178.0];
    const widthScales = <double>[0.96, 0.90, 0.83, 0.74];

    for (int depth = visibleCount - 1; depth >= 0; depth--) {
      final entry = stackedCards[depth];
      final targetScale = widthScales[depth];
      final scale = targetScale + ((1.0 - targetScale) * expandT);
      final collapsedTop = stageHeight - peekHeights[depth];
      final expandedTop = 10.0 + ((depth + 1) * (cardHeight + 14.0));
      final currentTop =
          collapsedTop + ((expandedTop - collapsedTop) * expandT);

      widgets.add(
        AnimatedPositioned(
          key: Key('stacked_card_${entry.value.id}_${entry.key}'),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          top: currentTop,
          left: (stageWidth - (cardWidth * scale)) / 2,
          width: cardWidth * scale,
          child: GestureDetector(
            onTap: () {
              if (_isInteractionLocked) return;
              HapticFeedback.selectionClick();
              widget.onSelectCard(entry.key);
            },
            child: BankCardArtwork(
              card: entry.value,
              isDimmed: depth >= 2 && expandT < 0.5,
              onPayNow: () => widget.onPayNow(entry.value),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

class _FlipperActionPill extends StatefulWidget {
  const _FlipperActionPill({
    required this.cardId,
    required this.pendingCount,
    required this.interval,
    required this.isPaused,
    required this.onPendingActionsTap,
    required this.onViewDetailsTap,
  });

  final String cardId;
  final int pendingCount;
  final Duration interval;
  final bool isPaused;
  final VoidCallback onPendingActionsTap;
  final VoidCallback onViewDetailsTap;

  @override
  State<_FlipperActionPill> createState() => _FlipperActionPillState();
}

class _FlipperActionPillState extends State<_FlipperActionPill> {
  Timer? _flipTimer;
  bool _showViewDetails = false;
  bool _userTouching = false;

  @override
  void initState() {
    super.initState();
    _showViewDetails = widget.pendingCount <= 0;
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _FlipperActionPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cardId != widget.cardId ||
        oldWidget.pendingCount != widget.pendingCount) {
      _showViewDetails = widget.pendingCount <= 0;
    }
    if (oldWidget.cardId != widget.cardId ||
        oldWidget.pendingCount != widget.pendingCount ||
        oldWidget.isPaused != widget.isPaused ||
        oldWidget.interval != widget.interval) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _flipTimer?.cancel();
    if (widget.pendingCount <= 0 || widget.isPaused || _userTouching) {
      return;
    }
    _flipTimer = Timer.periodic(widget.interval, (_) {
      if (!mounted || widget.isPaused || _userTouching) return;
      setState(() {
        _showViewDetails = !_showViewDetails;
      });
    });
  }

  @override
  void dispose() {
    _flipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showingDetails = _showViewDetails || widget.pendingCount <= 0;

    return Listener(
      onPointerDown: (_) {
        _userTouching = true;
        _syncTimer();
      },
      onPointerUp: (_) {
        _userTouching = false;
        _syncTimer();
      },
      onPointerCancel: (_) {
        _userTouching = false;
        _syncTimer();
      },
      child: GestureDetector(
        key: Key(showingDetails ? 'view_details_pill' : 'pending_actions_pill'),
        onTap: showingDetails
            ? widget.onViewDetailsTap
            : widget.onPendingActionsTap,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetTween = Tween<Offset>(
                begin: const Offset(0, 0.55),
                end: Offset.zero,
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetTween.animate(animation),
                  child: child,
                ),
              );
            },
            child: showingDetails
                ? const Row(
                    key: ValueKey('pill_view_details'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkPrimary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.inkSecondary,
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('pill_pending_actions'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.alertCoral,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.pendingCount} pending ${widget.pendingCount == 1 ? 'action' : 'actions'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkPrimary,
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
        ),
      ),
    );
  }
}

class _ExpandedVerticalCardList extends StatelessWidget {
  const _ExpandedVerticalCardList({
    required this.cards,
    required this.selectedIndex,
    required this.controller,
    required this.onSelectCard,
    required this.onCollapse,
    required this.onPayNow,
  });

  final List<BankCard> cards;
  final int selectedIndex;
  final ScrollController controller;
  final ValueChanged<int> onSelectCard;
  final VoidCallback onCollapse;
  final ValueChanged<BankCard> onPayNow;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification &&
            notification.overscroll < -8 &&
            controller.offset <= 0) {
          onCollapse();
          return true;
        }
        return false;
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ALL CARDS (${cards.length})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.inkSecondary,
                  ),
                ),
                TextButton.icon(
                  key: const Key('collapse_deck_button'),
                  onPressed: onCollapse,
                  icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
                  label: const Text(
                    'Stack view',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              key: const Key('expanded_cards_list_view'),
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final card = cards[index];
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelectCard(index),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.cardRadius),
                      border: isSelected
                          ? Border.all(color: AppColors.inkPrimary, width: 2)
                          : null,
                    ),
                    child: BankCardArtwork(
                      card: card,
                      onPayNow: () => onPayNow(card),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
