import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:vanep_mobile/core/design_system/vanep_theme_context.dart';

const vanepSwipeToConfirmHeight = 60.0;
const vanepSwipeToConfirmKnobSize = 50.0;
const vanepSwipeToConfirmPadding = 5.0;
const vanepSwipeToConfirmThreshold = 0.9;
const vanepSwipeToConfirmSpringBack = Duration(milliseconds: 220);
const vanepSwipeToConfirmKnobKey = ValueKey('vanep-swipe-to-confirm-knob');

class VanepSwipeToConfirm extends StatefulWidget {
  const VanepSwipeToConfirm({
    required this.label,
    required this.semanticsLabel,
    required this.onConfirmed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final String semanticsLabel;
  final VoidCallback? onConfirmed;
  final bool isLoading;

  bool get isEnabled => onConfirmed != null && !isLoading;

  @override
  State<VanepSwipeToConfirm> createState() => _VanepSwipeToConfirmState();
}

class _VanepSwipeToConfirmState extends State<VanepSwipeToConfirm> {
  double dragOffset = 0;
  bool isDragging = false;

  void moveKnob(double delta, double maxOffset) {
    if (!widget.isEnabled) return;
    setState(() {
      isDragging = true;
      dragOffset = (dragOffset + delta).clamp(0, maxOffset);
    });
  }

  void releaseKnob(double maxOffset) {
    final reachedEnd =
        maxOffset > 0 && dragOffset >= maxOffset * vanepSwipeToConfirmThreshold;
    setState(() {
      isDragging = false;
      dragOffset = 0;
    });
    if (reachedEnd) confirm();
  }

  void confirm() {
    if (!widget.isEnabled) return;
    HapticFeedback.mediumImpact();
    widget.onConfirmed!();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      container: true,
      button: true,
      enabled: widget.isEnabled,
      label: widget.semanticsLabel,
      onTap: widget.isEnabled ? confirm : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: widget.onConfirmed == null ? 0.45 : 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxOffset =
                constraints.maxWidth -
                vanepSwipeToConfirmPadding * 2 -
                vanepSwipeToConfirmKnobSize;

            return Container(
              height: vanepSwipeToConfirmHeight,
              decoration: BoxDecoration(
                color: palette.successSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: palette.success.withValues(alpha: 0.25),
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left:
                          vanepSwipeToConfirmKnobSize +
                          vanepSwipeToConfirmPadding * 2,
                      right: 16,
                    ),
                    child: Center(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.button.copyWith(
                          color: palette.success,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: isDragging
                        ? Duration.zero
                        : vanepSwipeToConfirmSpringBack,
                    curve: Curves.easeOut,
                    left: vanepSwipeToConfirmPadding + dragOffset,
                    child: GestureDetector(
                      key: vanepSwipeToConfirmKnobKey,
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) =>
                          moveKnob(details.delta.dx, maxOffset),
                      onHorizontalDragEnd: (_) => releaseKnob(maxOffset),
                      onHorizontalDragCancel: () => releaseKnob(0),
                      child: VanepSwipeToConfirmKnob(
                        isLoading: widget.isLoading,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VanepSwipeToConfirmKnob extends StatelessWidget {
  const VanepSwipeToConfirmKnob({required this.isLoading, super.key});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: vanepSwipeToConfirmKnobSize,
      height: vanepSwipeToConfirmKnobSize,
      decoration: BoxDecoration(
        color: palette.success,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: palette.success.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: palette.onAction,
              ),
            )
          : Icon(
              Icons.keyboard_double_arrow_right_rounded,
              color: palette.onAction,
            ),
    );
  }
}
