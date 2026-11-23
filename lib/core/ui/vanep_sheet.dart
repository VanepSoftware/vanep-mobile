import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';

const vanepSheetTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w800,
  color: VanepColors.textPrimary,
);

Future<T?> showVanepSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: VanepColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}

class VanepSheetFrame extends StatelessWidget {
  const VanepSheetFrame({
    required this.title,
    required this.child,
    this.footer,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: VanepSheetHandle()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(title, style: vanepSheetTitleStyle)),
                    const CloseButton(),
                  ],
                ),
                Flexible(child: SingleChildScrollView(child: child)),
                if (footer != null) ...[const SizedBox(height: 16), footer],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VanepSheetHandle extends StatelessWidget {
  const VanepSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: VanepColors.inputBorder,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class VanepRadioIndicator extends StatelessWidget {
  const VanepRadioIndicator({required this.isSelected, super.key});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? VanepColors.action : VanepColors.textMuted,
          width: 2,
        ),
      ),
      child: isSelected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                color: VanepColors.action,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
