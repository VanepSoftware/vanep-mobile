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

  @override
  String get profilePersonalData => 'Dados pessoais';

  @override
  String get profileAddresses => 'Endereços';

  @override
  String get profilePaymentMethods => 'Formas de pagamento';

  @override
  String get profileDependents => 'Gerenciar dependentes';

  @override
  String get profileVans => 'Vans';

  @override
  String get profileContracts => 'Contratos';

  @override
  String get profileProfessionalData => 'Dados profissionais';

  @override
  String get profileAssistantInvite => 'Convite do motorista';

  @override
  String get profileSettings => 'Configurações';

  @override
  String get profilePrivacySecurity => 'Privacidade e segurança';

  @override
  String get profileSignOutTitle => 'Sair da conta?';

  @override
  String get profileSignOutMessage =>
      'Sua sessão neste aparelho será encerrada. Você pode entrar de novo quando quiser.';

  @override
  String get profileSignOutCancel => 'Cancelar';

  @override
  String get profileFieldName => 'Nome';

  @override
  String get profileFieldEmail => 'E-mail';

  @override
  String get profileFieldPhone => 'Telefone';

  @override
  String get profileFieldDocument => 'Documento';

  @override
  String get profileFieldBirthDate => 'Data de nascimento';

  @override
  String get profileFieldGender => 'Gênero';

  @override
  String get profileGenderMale => 'Masculino';

  @override
  String get profileGenderFemale => 'Feminino';

  @override
  String get profileGenderOther => 'Outro';

  @override
  String get profileFieldEmpty => '—';

  @override
  String get profileSectionAccount => 'Conta';

  @override
  String get profileSectionServices => 'Serviços';

  @override
  String get profileSectionPreferences => 'Preferências';

  @override
  String get profileAssistantStatusUnlinked => 'Sem vínculo';

  @override
  String get profileAssistantStatusPending => 'Convite pendente';

  @override
  String get profileAssistantStatusActive => 'Ativo';

  @override
  String get profileAssistantStatusInactive => 'Inativo';
}
