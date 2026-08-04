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
  String driverShiftStartsAt(String time) {
    return 'Seu expediente começa às $time';
  }

  @override
  String get driverShiftOff => 'Fora do expediente';

  @override
  String get driverShiftOn => 'Em expediente';

  @override
  String driverStudentsOnRouteToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alunos na rota de hoje',
      one: '1 aluno na rota de hoje',
    );
    return '$_temp0';
  }

  @override
  String get driverStartRoute => 'Iniciar rota';

  @override
  String get driverEndRoute => 'Encerrar rota';

  @override
  String get driverShareLiveLocation =>
      'Compartilhar localização em tempo real';

  @override
  String get navProposals => 'Propostas';

  @override
  String get navStudents => 'Alunos';

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

  @override
  String get profileSave => 'Salvar';

  @override
  String get profileChangeEmailTitle => 'Alterar e-mail';

  @override
  String get profileChangeEmailSubmit => 'Alterar e-mail';

  @override
  String get profileEmailChangeConfirmationTitle => 'Verifique seu e-mail';

  @override
  String profileEmailChangeConfirmationMessage(String email) {
    return 'Enviamos um link de confirmação para $email. Abra-o para concluir a alteração do seu e-mail.';
  }

  @override
  String profilePendingEmailBanner(String email) {
    return 'Confirme o novo e-mail enviado para $email.';
  }

  @override
  String profileCooldownDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get profileEditSaveSuccess => 'Dados pessoais salvos.';

  @override
  String profileEditErrorCooldown(String date) {
    return 'Você poderá alterar de novo em $date.';
  }

  @override
  String get profileEditErrorEmailDuplicate => 'Este e-mail já está em uso.';

  @override
  String get profileEditErrorFieldNull => 'Este campo é obrigatório.';

  @override
  String get profileEditErrorPhoneBlank => 'Informe um telefone válido.';

  @override
  String get profileEditErrorEmailSame => 'Esse já é o seu e-mail atual.';

  @override
  String get profileEditErrorEmailInvalid => 'Informe um e-mail válido.';

  @override
  String get profileEditErrorEmailRequired => 'O e-mail é obrigatório.';

  @override
  String profileEditErrorNameTooLong(int max) {
    return 'O nome deve ter no máximo $max caracteres.';
  }

  @override
  String profileEditErrorPhoneTooLong(int max) {
    return 'O telefone deve ter no máximo $max caracteres.';
  }

  @override
  String profileEditErrorEmailTooLong(int max) {
    return 'O e-mail deve ter no máximo $max caracteres.';
  }

  @override
  String get profileEditErrorNetwork =>
      'Não foi possível atualizar o perfil. Verifique a conexão e tente novamente.';

  @override
  String get profileEditErrorUnexpected => 'Algo deu errado. Tente novamente.';

  @override
  String get profileEditLoadError =>
      'Não foi possível carregar seus dados pessoais. Puxe para tentar novamente.';

  @override
  String get profileEditRetry => 'Tentar novamente';
}
