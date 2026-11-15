import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class VanepPalette extends ThemeExtension<VanepPalette> with Equatable {
  const VanepPalette({
    required this.surface,
    required this.card,
    required this.raisedSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.avatarPlaceholder,
    required this.danger,
    required this.dangerSurface,
    required this.dangerBorder,
    required this.dangerText,
    required this.warning,
    required this.warningSurface,
    required this.warningSurfaceSoft,
    required this.warningBorder,
    required this.warningText,
    required this.action,
    required this.actionSurface,
    required this.actionHalo,
    required this.actionTint,
    required this.actionBorder,
    required this.onAction,
    required this.success,
    required this.successSurface,
    required this.inputBorder,
    required this.cardBorder,
    required this.placeholder,
    required this.avatarAmberSurface,
    required this.avatarAmberText,
    required this.avatarBlueSurface,
    required this.avatarBlueText,
    required this.avatarGreenSurface,
    required this.avatarGreenText,
    required this.avatarGraySurface,
    required this.avatarGrayText,
    required this.scheduleEmpty,
    required this.schedulePartTime,
    required this.scheduleFullTime,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadow,
  });

  final Color surface;
  final Color card;
  final Color raisedSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color avatarPlaceholder;
  final Color danger;
  final Color dangerSurface;
  final Color dangerBorder;
  final Color dangerText;
  final Color warning;
  final Color warningSurface;
  final Color warningSurfaceSoft;
  final Color warningBorder;
  final Color warningText;
  final Color action;
  final Color actionSurface;
  final Color actionHalo;
  final Color actionTint;
  final Color actionBorder;
  final Color onAction;
  final Color success;
  final Color successSurface;
  final Color inputBorder;
  final Color cardBorder;
  final Color placeholder;
  final Color avatarAmberSurface;
  final Color avatarAmberText;
  final Color avatarBlueSurface;
  final Color avatarBlueText;
  final Color avatarGreenSurface;
  final Color avatarGreenText;
  final Color avatarGraySurface;
  final Color avatarGrayText;
  final Color scheduleEmpty;
  final Color schedulePartTime;
  final Color scheduleFullTime;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color shadow;

  static const VanepPalette light = VanepPalette(
    surface: Color(0xFFF4F6F8),
    card: Color(0xFFFFFFFF),
    raisedSurface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B2038),
    textSecondary: Color(0xFF6B7A8C),
    textMuted: Color(0xFF9AA7B4),
    divider: Color(0xFFE1E7ED),
    avatarPlaceholder: Color(0xFFE8EAED),
    danger: Color(0xFFC4564A),
    dangerSurface: Color(0xFFFDF3F2),
    dangerBorder: Color(0xFFF0CDC8),
    dangerText: Color(0xFFB3443A),
    warning: Color(0xFFC98A1F),
    warningSurface: Color(0xFFFBF0DA),
    warningSurfaceSoft: Color(0xFFFFFAEE),
    warningBorder: Color(0xFFF1DDB3),
    warningText: Color(0xFF8A5A00),
    action: Color(0xFF0B6BD3),
    actionSurface: Color(0x140B6BD3),
    actionHalo: Color(0x2E0B6BD3),
    actionTint: Color(0xFFF5F9FE),
    actionBorder: Color(0xFFB9D3F2),
    onAction: Color(0xFFFFFFFF),
    success: Color(0xFF1E8E5A),
    successSurface: Color(0x1A1E8E5A),
    inputBorder: Color(0xFFDFE3E7),
    cardBorder: Color(0xFFE4E5E7),
    placeholder: Color(0xFF9AA0A6),
    avatarAmberSurface: Color(0xFFFBF0DA),
    avatarAmberText: Color(0xFF8A5A00),
    avatarBlueSurface: Color(0xFFDCE6F5),
    avatarBlueText: Color(0xFF022856),
    avatarGreenSurface: Color(0xFFE3F3EA),
    avatarGreenText: Color(0xFF187A4C),
    avatarGraySurface: Color(0xFFEDF0F3),
    avatarGrayText: Color(0xFF4A5867),
    scheduleEmpty: Color(0xFFE7EBEF),
    schedulePartTime: Color(0xFF0B6BD3),
    scheduleFullTime: Color(0xFF022856),
    skeletonBase: Color(0xFFE6EAEF),
    skeletonHighlight: Color(0xFFF5F7F9),
    shadow: Color(0xFF0B2038),
  );

  static const VanepPalette dark = VanepPalette(
    surface: Color(0xFF0B1420),
    card: Color(0xFF152232),
    raisedSurface: Color(0xFF2E3F55),
    textPrimary: Color(0xFFE8EEF5),
    textSecondary: Color(0xFF9DAABA),
    textMuted: Color(0xFF6F7F91),
    divider: Color(0xFF243346),
    avatarPlaceholder: Color(0xFF22303F),
    danger: Color(0xFFE5776B),
    dangerSurface: Color(0xFF2A1715),
    dangerBorder: Color(0xFF5A2A25),
    dangerText: Color(0xFFF0948A),
    warning: Color(0xFFE0A84A),
    warningSurface: Color(0xFF2E2412),
    warningSurfaceSoft: Color(0xFF241D10),
    warningBorder: Color(0xFF5A4520),
    warningText: Color(0xFFF0C873),
    action: Color(0xFF3D8BE8),
    actionSurface: Color(0x263D8BE8),
    actionHalo: Color(0x473D8BE8),
    actionTint: Color(0xFF14263B),
    actionBorder: Color(0xFF2D5585),
    onAction: Color(0xFFFFFFFF),
    success: Color(0xFF3DBE82),
    successSurface: Color(0x263DBE82),
    inputBorder: Color(0xFF2C3B4D),
    cardBorder: Color(0xFF223144),
    placeholder: Color(0xFF66768A),
    avatarAmberSurface: Color(0xFF3A2E14),
    avatarAmberText: Color(0xFFF0C873),
    avatarBlueSurface: Color(0xFF1C3354),
    avatarBlueText: Color(0xFFB9D3F2),
    avatarGreenSurface: Color(0xFF163828),
    avatarGreenText: Color(0xFF8FDDB5),
    avatarGraySurface: Color(0xFF243140),
    avatarGrayText: Color(0xFFB5C1CE),
    scheduleEmpty: Color(0xFF243140),
    schedulePartTime: Color(0xFF3D8BE8),
    scheduleFullTime: Color(0xFF8EC5FF),
    skeletonBase: Color(0xFF1C2A3A),
    skeletonHighlight: Color(0xFF26364A),
    shadow: Color(0xFF000000),
  );

  @override
  VanepPalette copyWith() => this;

  @override
  VanepPalette lerp(VanepPalette? other, double t) {
    if (other == null) return this;
    return VanepPalette(
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      raisedSurface: Color.lerp(raisedSurface, other.raisedSurface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      avatarPlaceholder: Color.lerp(
        avatarPlaceholder,
        other.avatarPlaceholder,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
      dangerBorder: Color.lerp(dangerBorder, other.dangerBorder, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningSurfaceSoft: Color.lerp(
        warningSurfaceSoft,
        other.warningSurfaceSoft,
        t,
      )!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      action: Color.lerp(action, other.action, t)!,
      actionSurface: Color.lerp(actionSurface, other.actionSurface, t)!,
      actionHalo: Color.lerp(actionHalo, other.actionHalo, t)!,
      actionTint: Color.lerp(actionTint, other.actionTint, t)!,
      actionBorder: Color.lerp(actionBorder, other.actionBorder, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      avatarAmberSurface: Color.lerp(
        avatarAmberSurface,
        other.avatarAmberSurface,
        t,
      )!,
      avatarAmberText: Color.lerp(avatarAmberText, other.avatarAmberText, t)!,
      avatarBlueSurface: Color.lerp(
        avatarBlueSurface,
        other.avatarBlueSurface,
        t,
      )!,
      avatarBlueText: Color.lerp(avatarBlueText, other.avatarBlueText, t)!,
      avatarGreenSurface: Color.lerp(
        avatarGreenSurface,
        other.avatarGreenSurface,
        t,
      )!,
      avatarGreenText: Color.lerp(avatarGreenText, other.avatarGreenText, t)!,
      avatarGraySurface: Color.lerp(
        avatarGraySurface,
        other.avatarGraySurface,
        t,
      )!,
      avatarGrayText: Color.lerp(avatarGrayText, other.avatarGrayText, t)!,
      scheduleEmpty: Color.lerp(scheduleEmpty, other.scheduleEmpty, t)!,
      schedulePartTime: Color.lerp(
        schedulePartTime,
        other.schedulePartTime,
        t,
      )!,
      scheduleFullTime: Color.lerp(
        scheduleFullTime,
        other.scheduleFullTime,
        t,
      )!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }

  @override
  List<Object?> get props => [
    surface,
    card,
    raisedSurface,
    textPrimary,
    textSecondary,
    textMuted,
    divider,
    avatarPlaceholder,
    danger,
    dangerSurface,
    dangerBorder,
    dangerText,
    warning,
    warningSurface,
    warningSurfaceSoft,
    warningBorder,
    warningText,
    action,
    actionSurface,
    actionHalo,
    actionTint,
    actionBorder,
    onAction,
    success,
    successSurface,
    inputBorder,
    cardBorder,
    placeholder,
    avatarAmberSurface,
    avatarAmberText,
    avatarBlueSurface,
    avatarBlueText,
    avatarGreenSurface,
    avatarGreenText,
    avatarGraySurface,
    avatarGrayText,
    scheduleEmpty,
    schedulePartTime,
    scheduleFullTime,
    skeletonBase,
    skeletonHighlight,
    shadow,
  ];
}
