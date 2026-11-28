import 'package:flutter/material.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';

class SlideStopConfirmation extends StatefulWidget {
  const SlideStopConfirmation({
    super.key,
    required this.confirmation,
    required this.enabled,
    required this.onConfirmed,
  });

  final StopConfirmation confirmation;
  final bool enabled;
  final Future<void> Function() onConfirmed;

  @override
  State<SlideStopConfirmation> createState() => SlideStopConfirmationState();
}

class SlideStopConfirmationState extends State<SlideStopConfirmation> {
  double progress = 0;
  bool submitting = false;
  bool dragging = false;

  Future<void> finishDrag() async {
    final complete = dragging && progress >= 1 && widget.enabled && !submitting;
    setState(() {
      progress = 0;
      dragging = false;
    });
    if (!complete) return;
    setState(() => submitting = true);
    try {
      await widget.onConfirmed();
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final action = widget.confirmation.action == StopAction.boarding
        ? l10n.driverHomeBoarding
        : l10n.driverHomeDisembarking;
    final enabled = widget.enabled && !submitting;
    return LayoutBuilder(
      builder: (context, box) {
        const trackHeight = 62.0;
        const thumbSize = 50.0;
        const padding = 6.0;
        final distance = box.maxWidth - thumbSize - padding * 2;
        return Semantics(
          label: l10n.driverHomeSlideHint(action),
          child: Container(
            height: trackHeight,
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F3EA),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFC6E6D3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 12),
                  child: Text(
                    l10n.driverHomeSlideConfirm(action),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DriverHomeTokens.success,
                    ),
                  ),
                ),
                Positioned(
                  left: progress * (distance > 0 ? distance : 0),
                  child: GestureDetector(
                    onHorizontalDragStart: enabled && distance > 0
                        ? (_) => setState(() => dragging = true)
                        : null,
                    onHorizontalDragUpdate: enabled && distance > 0
                        ? (event) {
                            setState(
                              () => progress =
                                  (progress + event.delta.dx / distance)
                                      .clamp(0.0, 1.0)
                                      .toDouble(),
                            );
                          }
                        : null,
                    onHorizontalDragEnd: enabled ? (_) => finishDrag() : null,
                    onHorizontalDragCancel: () => setState(() {
                      progress = 0;
                      dragging = false;
                    }),
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: enabled
                            ? DriverHomeTokens.success
                            : Theme.of(context).disabledColor,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38187A4C),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.keyboard_double_arrow_right,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
