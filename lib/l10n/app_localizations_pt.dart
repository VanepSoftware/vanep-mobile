// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vanep';

  @override
  String get welcomeTagline => 'Transporte escolar, simplificado.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginCancelled => 'O login foi cancelado.';

  @override
  String get loginFailed => 'Não foi possível entrar. Tente novamente.';

  @override
  String homeGreeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String homeSignedInAs(String email) {
    return 'Você está autenticado como $email.';
  }

  @override
  String get signOutButton => 'Sair';

  @override
  String get driversSearchHint => 'Buscar rota ou escola…';

  @override
  String get driversSuggestionsNearYou => 'Sugestões perto de você';

  @override
  String driverExperienceYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
    );
    return '$_temp0';
  }

  @override
  String get driversEmpty => 'Nenhum motorista encontrado.';

  @override
  String get driversLoadError =>
      'Não foi possível carregar os motoristas. Tente novamente.';

  @override
  String get driversRetryButton => 'Tentar novamente';

  @override
  String get navHome => 'Início';

  @override
  String get navVans => 'Vans';

  @override
  String get navNotifications => 'Notificações';

  @override
  String get navProfile => 'Perfil';

  @override
  String get comingSoon => 'Em breve';
}
