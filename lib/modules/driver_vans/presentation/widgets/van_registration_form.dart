import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/vanep_typography.dart';
import '../../../../core/formatters/upper_case_input_formatter.dart';
import '../../../../core/ui/vanep_primary_button.dart';
import '../../../../core/ui/vanep_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/value_objects/van_registration.dart';
import '../cubit/driver_vans_cubit.dart';
import '../cubit/driver_vans_state.dart';
import '../formatters/driver_van_labels.dart';

const int maxVanPlateLength = 8;

class VanRegistrationForm extends StatefulWidget {
  const VanRegistrationForm({super.key});

  @override
  State<VanRegistrationForm> createState() => VanRegistrationFormState();
}

class VanRegistrationFormState extends State<VanRegistrationForm> {
  final Map<VanField, TextEditingController> controllers = {
    for (final field in VanField.values) field: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    final draft = context.read<DriverVansCubit>().state.draft;
    for (final field in VanField.values) {
      controllers[field]!.text = draft.valueOf(field);
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DriverVansCubit, DriverVansState>(
      builder: (context, state) {
        final cubit = context.read<DriverVansCubit>();

        Widget fieldFor(
          VanField field, {
          TextInputType? keyboardType,
          List<TextInputFormatter>? inputFormatters,
          int? maxLength,
        }) {
          return VanRegistrationField(
            label: vanFieldLabel(l10n, field),
            controller: controllers[field]!,
            errorText: vanFieldErrorLabel(
              l10n,
              field,
              state.fieldErrors[field],
            ),
            enabled: !state.isRegistering,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            onChanged: (value) => cubit.updateDraft(field, value),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.driverVansRegisterIntro,
              style: VanepTypography.cardSubtitle,
            ),
            fieldFor(
              VanField.plate,
              inputFormatters: const [UpperCaseInputFormatter()],
              maxLength: maxVanPlateLength,
            ),
            fieldFor(VanField.brand),
            fieldFor(VanField.model),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: fieldFor(
                    VanField.manufactureYear,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 4,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: fieldFor(
                    VanField.capacity,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 2,
                  ),
                ),
              ],
            ),
            fieldFor(VanField.color),
            const SizedBox(height: 20),
            VanepPrimaryButton(
              label: l10n.driverVanRegister,
              isLoading: state.isRegistering,
              onPressed: cubit.register,
            ),
          ],
        );
      },
    );
  }
}

class VanRegistrationField extends StatelessWidget {
  const VanRegistrationField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: VanepTextField(
        label: label,
        controller: controller,
        onChanged: onChanged,
        errorText: errorText,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
      ),
    );
  }
}
