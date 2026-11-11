import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

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
  State<SlideStopConfirmation> createState() => _SlideStopConfirmationState();
}

class _SlideStopConfirmationState extends State<SlideStopConfirmation> {
  double _progress = 0;
  bool _submitting = false;
  bool _dragging = false;

  Future<void> _finish() async {
    final complete =
        _dragging && _progress >= 1 && widget.enabled && !_submitting;
    setState(() {
      _progress = 0;
      _dragging = false;
    });
    if (!complete) return;
    setState(() => _submitting = true);
    try {
      await widget.onConfirmed();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.confirmation.action == StopAction.boarding
        ? AppLocalizations.of(context)!.driverHomeBoarding
        : AppLocalizations.of(context)!.driverHomeDisembarking;
    final enabled = widget.enabled && !_submitting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!
              .driverHomeSlideStudent(widget.confirmation.studentName, action),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, box) {
            const thumb = 52.0;
            final distance = box.maxWidth - thumb;
            return Semantics(
              label: AppLocalizations.of(context)!.driverHomeSlideHint(action),
              child: Container(
                height: thumb,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.keyboard_double_arrow_right),
                    ),
                    Positioned(
                      left: _progress * (distance > 0 ? distance : 0),
                      child: GestureDetector(
                        // Somente arrastar a alça até o fim confirma; toque não confirma.
                        onHorizontalDragStart: enabled && distance > 0
                            ? (_) => setState(() => _dragging = true)
                            : null,
                        onHorizontalDragUpdate: enabled && distance > 0
                            ? (event) {
                                setState(
                                  () => _progress =
                                      (_progress + event.delta.dx / distance)
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                );
                              }
                            : null,
                        onHorizontalDragEnd: enabled ? (_) => _finish() : null,
                        onHorizontalDragCancel: () => setState(() {
                          _progress = 0;
                          _dragging = false;
                        }),
                        child: Container(
                          width: thumb,
                          height: thumb,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: enabled
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).disabledColor,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
