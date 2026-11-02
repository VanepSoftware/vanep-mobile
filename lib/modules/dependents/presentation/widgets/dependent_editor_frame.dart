import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependent_editor.dart';

class DependentEditorFrame extends StatelessWidget {
  const DependentEditorFrame({
    required this.title,
    required this.body,
    required this.bottomBar,
    this.caption,
    super.key,
  });

  final String title;
  final String? caption;
  final Widget body;
  final Widget bottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VanepColors.surface,
      appBar: VanepAppBar(title: title, caption: caption),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [body],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class DependentEditorSaveBar<
  C extends DependentEditorCubit<S>,
  S extends DependentEditorState
>
    extends StatelessWidget {
  const DependentEditorSaveBar({
    required this.label,
    required this.onSaved,
    this.skipLabel,
    this.onSkip,
    super.key,
  });

  final String label;
  final ValueChanged<S> onSaved;
  final String? skipLabel;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final skipLabel = this.skipLabel;
    final onSkip = this.onSkip;

    return BlocConsumer<C, S>(
      listenWhen: (previous, current) => !previous.isSaved && current.isSaved,
      listener: (context, state) => onSaved(state),
      builder: (context, state) {
        final editor = context.read<C>();
        return VanepBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VanepPrimaryButton(
                label: label,
                isLoading: state.isSaving,
                onPressed: state.canSave ? editor.save : null,
              ),
              if (skipLabel != null && onSkip != null) ...[
                const SizedBox(height: 8),
                VanepSecondaryButton(
                  label: skipLabel,
                  onPressed: state.isSaving ? null : onSkip,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
