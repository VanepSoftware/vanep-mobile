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
  String get loginHeading => 'Bem-vindo de volta';

  @override
  String get loginSubtitle => 'Entre com seu e-mail e senha para continuar';

  @override
  String get loginEmailHint => 'seu@email.com';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get loginOrDivider => 'ou';

  @override
  String get loginNoAccount => 'Não tem uma conta?';

  @override
  String get loginFailed => 'Não foi possível entrar. Tente novamente.';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginErrorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get loginErrorEmailNotVerified => 'Confirme seu e-mail para entrar.';

  @override
  String get loginErrorAccountLocked =>
      'Muitas tentativas sem sucesso. Tente de novo em alguns minutos.';

  @override
  String get loginErrorAccountDisabled => 'Esta conta foi desativada.';

  @override
  String get authErrorTooManyRequests =>
      'Muitas requisições. Aguarde um instante e tente de novo.';

  @override
  String get loginWithGoogle => 'Entrar com Google';

  @override
  String get loginErrorGoogle =>
      'Não foi possível entrar com o Google. Tente novamente.';

  @override
  String get signupGoogleRegisteredSignIn =>
      'Cadastro concluído! Entre com o Google para continuar.';

  @override
  String get signupCreateAccount => 'Criar conta';

  @override
  String get signupChooseTypeTitle => 'Como você quer usar a Vanep?';

  @override
  String get signupTypeClient => 'Sou cliente (responsável)';

  @override
  String get signupTypeDriver => 'Sou motorista';

  @override
  String get signupTypeAssistant => 'Sou assistente';

  @override
  String get signupChooseTypeSubtitle =>
      'Escolha o tipo de conta que combina com você.';

  @override
  String get signupTypeClientDescription =>
      'Encontre e contrate transporte escolar para seus dependentes.';

  @override
  String get signupTypeDriverDescription =>
      'Ofereça transporte escolar com a sua van.';

  @override
  String get signupTypeAssistantDescription =>
      'Acompanhe os alunos durante as rotas de um motorista.';

  @override
  String get signupAlreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get signupSectionAccess => 'Dados de acesso';

  @override
  String get signupSectionPersonal => 'Dados pessoais';

  @override
  String get signupSectionProfessional => 'Dados profissionais';

  @override
  String get signupContinue => 'Continuar';

  @override
  String signupStepProgress(int current, int total) {
    return 'Etapa $current de $total';
  }

  @override
  String get signupStepAccessSubtitle =>
      'Você vai usar o e-mail e a senha para entrar no app.';

  @override
  String get signupStepPersonalSubtitle =>
      'Precisamos desses dados para identificar a sua conta.';

  @override
  String get signupStepProfessionalSubtitle =>
      'Conte um pouco sobre o seu serviço de transporte.';

  @override
  String get signupStepConfirmationTitle => 'Revise e confirme';

  @override
  String get signupStepConfirmationSubtitle =>
      'Confira os dados da conta e aceite os termos para concluir.';

  @override
  String get signupNameHint => 'Seu nome completo';

  @override
  String get signupPasswordHint => 'Crie uma senha';

  @override
  String get signupFieldPasswordConfirmation => 'Confirmar senha';

  @override
  String get signupPasswordConfirmationHint => 'Repita a senha';

  @override
  String passwordRequirementMinLength(int min) {
    return 'Mínimo de $min caracteres';
  }

  @override
  String get passwordRequirementUppercase => 'Uma letra maiúscula';

  @override
  String get passwordRequirementSpecial =>
      'Um caractere especial (ex.: ! @ # \$)';

  @override
  String get accountIssuePasswordWeak =>
      'A senha não atende a todos os requisitos.';

  @override
  String get accountIssuePasswordMismatch => 'As senhas não coincidem.';

  @override
  String get signupDocumentHint => '000.000.000-00';

  @override
  String get signupPhoneHint => '(00) 00000-0000';

  @override
  String get signupBirthDateHint => 'dd/mm/aaaa';

  @override
  String get signupBasePriceHint => '0,00';

  @override
  String get signupExperienceYearsHint => '0';

  @override
  String get signupCnpjHint => '00.000.000/0000-00';

  @override
  String get signupTitleClient => 'Cadastro de cliente';

  @override
  String get signupTitleDriver => 'Cadastro de motorista';

  @override
  String get signupTitleAssistant => 'Cadastro de assistente';

  @override
  String get signupFieldName => 'Nome';

  @override
  String get signupFieldDocument => 'CPF';

  @override
  String get signupFieldPhone => 'Telefone';

  @override
  String get signupFieldBirthDate => 'Data de nascimento';

  @override
  String get signupFieldGender => 'Sexo';

  @override
  String get signupFieldCnpj => 'CNPJ (próprio ou da empresa)';

  @override
  String get signupFieldExperienceYears => 'Anos de experiência';

  @override
  String get signupFieldBasePrice => 'Valor base (R\$)';

  @override
  String get signupAcceptTerms => 'Aceito os termos de uso';

  @override
  String emailCodeSentTo(String email) {
    return 'Enviamos um código de 6 dígitos para $email.';
  }

  @override
  String emailCodeEnterFor(String email) {
    return 'Digite o código de 6 dígitos que foi enviado para $email. Se ele expirou ou não chegou, peça um novo abaixo.';
  }

  @override
  String get emailVerificationTitle => 'Confirme seu e-mail';

  @override
  String get verificationCodeLabel => 'Código';

  @override
  String get verificationCodeHint => '000000';

  @override
  String get emailVerificationSubmit => 'Confirmar';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String resendCodeIn(int seconds) {
    return 'Reenviar código em ${seconds}s';
  }

  @override
  String get codeResent => 'Enviamos um novo código.';

  @override
  String get emailVerifiedSignIn => 'E-mail confirmado! Entre para continuar.';

  @override
  String get accountIssueCodeInvalid => 'Informe os 6 dígitos do código.';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get passwordResetTitle => 'Recuperar senha';

  @override
  String get passwordResetEmailHint =>
      'Informe o e-mail da sua conta. Se ela existir, enviaremos um código para você criar uma nova senha.';

  @override
  String get passwordResetSendCode => 'Enviar código';

  @override
  String passwordResetCodeSentTo(String email) {
    return 'Se houver uma conta com $email, enviamos um código de 6 dígitos.';
  }

  @override
  String get passwordResetCodeTitle => 'Crie uma nova senha';

  @override
  String get passwordResetNewPasswordHint => 'Digite a nova senha';

  @override
  String get passwordResetNewPasswordLabel => 'Nova senha';

  @override
  String get passwordResetSubmit => 'Redefinir senha';

  @override
  String get passwordResetDone => 'Senha redefinida! Entre com a nova senha.';

  @override
  String get accountIssueRequired => 'Preencha este campo.';

  @override
  String get accountIssueEmailInvalid => 'E-mail inválido.';

  @override
  String get accountIssueDocumentInvalid =>
      'CPF inválido. Verifique os números informados.';

  @override
  String get accountIssueNumberInvalid => 'Informe um número válido.';

  @override
  String accountIssuePasswordTooShort(int min) {
    return 'A senha deve ter ao menos $min caracteres.';
  }

  @override
  String get accountIssueTermsNotAccepted =>
      'É necessário aceitar os termos de uso.';

  @override
  String get accountIssueBasePriceNotPositive =>
      'O valor base deve ser maior que zero.';

  @override
  String get accountIssueEmailDuplicate =>
      'Já existe uma conta com este e-mail.';

  @override
  String get accountIssueDocumentDuplicate =>
      'Já existe uma conta com este CPF.';

  @override
  String get accountIssueRejected => 'Confira este campo.';

  @override
  String get accountErrorCheckFields => 'Confira os campos destacados.';

  @override
  String get accountErrorInvalidCode => 'Código inválido ou expirado.';

  @override
  String get accountErrorInvalidSignupTicket =>
      'Seu cadastro com o Google expirou. Entre com o Google novamente.';

  @override
  String get accountErrorNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get accountErrorUnexpected => 'Algo deu errado. Tente novamente.';

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
  String get comingSoon => 'Em breve';

  @override
  String get navContracts => 'Contratos';

  @override
  String get navDependents => 'Dependentes';

  @override
  String get navProposals => 'Propostas';

  @override
  String get navProposalsAndContracts => 'Propostas e contratos';

  @override
  String get clientHomeNoLinkedVanTitle => 'Nenhuma van vinculada';

  @override
  String get clientHomeNoLinkedVanMessage =>
      'Você ainda não tem uma van. Procure uma que atenda a sua região.';

  @override
  String get clientHomeFindVanButton => 'Procurar van';

  @override
  String get driverVansMyVans => 'Minhas vans';

  @override
  String get homeMenuTooltip => 'Abrir menu';

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
  String get navStudents => 'Alunos';

  @override
  String get profilePersonalData => 'Dados pessoais';

  @override
  String get personalDataSubtitle =>
      'Confira e atualize os dados da sua conta e o endereço da sua casa.';

  @override
  String get profilePaymentMethods => 'Formas de pagamento';

  @override
  String get profileDependents => 'Gerenciar dependentes';

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
  String get profilePendingEmailMenuSubtitle => 'Confirme seu novo e-mail';

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

  @override
  String get serviceAreasTitle => 'Onde você atende';

  @override
  String get serviceAreasSubtitle =>
      'Cadastre até 10 regiões. Quanto mais específico, mais fácil um cliente te encontrar.';

  @override
  String get serviceAreasSearchHint => 'Buscar bairro, quadra ou região';

  @override
  String get serviceAreasEmpty => 'Nenhuma região cadastrada ainda.';

  @override
  String get serviceAreasMaxReached => 'Você atingiu o máximo de 10 regiões.';

  @override
  String get serviceAreasSave => 'Salvar regiões';

  @override
  String get serviceAreasSaved => 'Regiões salvas.';

  @override
  String get serviceAreasRemove => 'Remover região';

  @override
  String get serviceAreasCityWideHint => 'Cidade inteira — pouco específico';

  @override
  String get serviceAreasOnboardingTitle => 'Falta dizer onde você atende';

  @override
  String get serviceAreasOnboardingBody =>
      'Sem isso, nenhum cliente encontra você na busca. Leva menos de um minuto.';

  @override
  String get serviceAreasOnboardingStart => 'Cadastrar agora';

  @override
  String get serviceAreasOnboardingSkip => 'Depois';

  @override
  String get serviceAreaFailureDistrictRequired =>
      'Esta cidade exige escolher um bairro ou região, não a cidade inteira.';

  @override
  String get serviceAreaFailureTooMany =>
      'Você pode cadastrar no máximo 10 regiões.';

  @override
  String get serviceAreaFailurePlaceNotResolved =>
      'Não foi possível interpretar este local. Escolha outra sugestão.';

  @override
  String get serviceAreaFailureRateLimited =>
      'Muitas consultas. Aguarde um momento e tente novamente.';

  @override
  String get serviceAreaFailureNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get serviceAreaFailureUnexpected =>
      'Algo deu errado. Tente novamente.';

  @override
  String get placeAutocompleteNoResults => 'Nenhum lugar encontrado.';

  @override
  String get placeAutocompleteNetworkError =>
      'Não foi possível buscar lugares. Tente novamente.';

  @override
  String get placeAutocompleteKeyError =>
      'A busca de lugares está indisponível no momento.';

  @override
  String get placeAutocompleteRetry => 'Tentar novamente';

  @override
  String get driverSearchTitle => 'Buscar motorista';

  @override
  String get driverSearchHint => 'Endereço ou escola';

  @override
  String get driverSearchEmpty => 'Nenhum motorista atende este local ainda.';

  @override
  String get driverSearchPlaceNotResolved =>
      'Não foi possível interpretar este local. Escolha outra sugestão.';

  @override
  String get driverSearchRateLimited =>
      'Muitas buscas. Aguarde um momento e tente novamente.';

  @override
  String get driverSearchNetworkError =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get driverSearchUnexpectedError =>
      'Algo deu errado na busca. Tente novamente.';

  @override
  String get driverSearchCoversWholeCity => 'Atende a cidade inteira';

  @override
  String get dependentsSubtitle =>
      'Cadastre e gerencie as pessoas que viajam na van.';

  @override
  String get dependentsEmpty => 'Você ainda não cadastrou nenhum dependente.';

  @override
  String get dependentsAdd => 'Adicionar dependente';

  @override
  String get dependentsRetry => 'Tentar novamente';

  @override
  String get dependentsLoadError =>
      'Não foi possível carregar seus dependentes.';

  @override
  String get dependentsDefaultBadge => 'Padrão';

  @override
  String get dependentsSetDefault => 'Definir como padrão';

  @override
  String get dependentsDefaultUpdated => 'Dependente padrão atualizado.';

  @override
  String dependentsAgeYears(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString anos',
      one: '1 ano',
      zero: 'menos de 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get dependentFormNewTitle => 'Novo dependente';

  @override
  String get dependentFormEditTitle => 'Editar dependente';

  @override
  String get dependentFormSave => 'Salvar';

  @override
  String get dependentFormSaved => 'Dependente salvo.';

  @override
  String get dependentFieldName => 'Nome';

  @override
  String get dependentFieldBirthDate => 'Data de nascimento';

  @override
  String get dependentFieldBirthDateEmpty => 'Selecionar data';

  @override
  String get dependentFieldBirthDateClear => 'Limpar data';

  @override
  String get dependentFieldGender => 'Sexo';

  @override
  String get dependentErrorNameRequired => 'Informe o nome do dependente.';

  @override
  String get dependentErrorBirthDateFuture =>
      'A data de nascimento não pode ser no futuro.';

  @override
  String get dependentErrorBirthDateInvalid => 'Data de nascimento inválida.';

  @override
  String get dependentFailureValidation =>
      'Não foi possível salvar. Revise os dados e tente novamente.';

  @override
  String get dependentFailureNotFound => 'Este dependente não existe mais.';

  @override
  String get dependentFailureNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get dependentFailureUnexpected => 'Algo deu errado. Tente novamente.';

  @override
  String get dependentFormSubtitle =>
      'Informe os dados de quem viaja na van. Só o nome é obrigatório.';

  @override
  String get dependentFailureCityNotFound =>
      'Não encontramos essa cidade. Escolha o município novamente.';

  @override
  String get dependentFieldAddress => 'Endereço';

  @override
  String get dependentFieldAddressEmpty => 'Nenhum endereço informado.';

  @override
  String get dependentFieldAddressRemove => 'Remover endereço';

  @override
  String get profileGenderUnspecified => 'Prefiro não informar';

  @override
  String get personalAddressCardTitle => 'Endereço';

  @override
  String get personalAddressEmpty => 'Nenhum endereço cadastrado.';

  @override
  String get postalAddressFieldNumber => 'Número';

  @override
  String get postalAddressFieldComplement => 'Complemento';

  @override
  String get postalAddressFieldStreet => 'Rua';

  @override
  String get postalAddressFieldNeighborhood => 'Bairro';

  @override
  String get postalAddressFieldZip => 'CEP';

  @override
  String get postalAddressFieldUf => 'UF';

  @override
  String get postalAddressFieldMunicipality => 'Município';

  @override
  String get postalAddressCitySearchHint => 'Buscar município';

  @override
  String get personalAddressClearAction => 'Limpar endereço';

  @override
  String get personalAddressClearTitle => 'Limpar endereço?';

  @override
  String get personalAddressClearMessage =>
      'O endereço residencial será removido da conta.';

  @override
  String get personalAddressClearConfirm => 'Limpar';

  @override
  String get personalAddressClearSuccess => 'Endereço removido.';

  @override
  String get personalAddressFailureCityNotFound =>
      'Cidade não encontrada no catálogo.';

  @override
  String get personalAddressFailureValidation =>
      'Revise os campos do endereço e tente novamente.';

  @override
  String get personalAddressFailureNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get personalAddressFailureUnexpected =>
      'Algo deu errado. Tente novamente.';

  @override
  String get personalAddressRegisterAction => 'Cadastrar endereço';

  @override
  String get personalAddressCardMenuTooltip => 'Mais opções';

  @override
  String get personalAddressEditAction => 'Editar endereço';

  @override
  String get postalAddressHintUf => 'UF';

  @override
  String get personalAddressFormTitleNew => 'Cadastrar endereço';

  @override
  String get personalAddressFormTitleEdit => 'Editar endereço';

  @override
  String get personalAddressFormSubtitle =>
      'Informe seu CEP e complete os dados do endereço.';

  @override
  String get personalAddressSaveAction => 'Salvar endereço';

  @override
  String get postalAddressHintZip => '00000-000';

  @override
  String get postalAddressHintStreet => 'Nome da rua ou avenida';

  @override
  String get postalAddressHintNumber => 'Nº';

  @override
  String get postalAddressHintComplement => 'Apto, bloco, referência';

  @override
  String get postalAddressHintNeighborhood => 'Ex: Centro';

  @override
  String get postalAddressHintCity => 'Selecione a cidade';

  @override
  String get postalAddressFieldRequiredError => 'Campo obrigatório.';

  @override
  String get postalAddressChooseUfFirst => 'Selecione o estado primeiro';

  @override
  String get postalAddressLookingUpCep => 'Consultando CEP';

  @override
  String get postalAddressCityPickerTitle => 'Selecionar cidade';

  @override
  String get postalAddressNoCitiesFound => 'Nenhuma cidade encontrada.';

  @override
  String get cepFailureInvalidFormat => 'CEP deve ter 8 dígitos.';

  @override
  String get cepFailureNotFound => 'CEP não encontrado.';

  @override
  String get cepFailureCityNotInCatalog =>
      'Município deste CEP não está no catálogo.';

  @override
  String get cepFailureRateLimited =>
      'Muitas consultas de CEP. Aguarde um momento.';

  @override
  String get cepFailureUnavailable =>
      'Consulta de CEP indisponível. Preencha na mão.';

  @override
  String get cepFailureNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get cepFailureUnexpected => 'Algo deu errado. Tente novamente.';

  @override
  String get ibgeLocationsFailureUfMissing => 'Escolha uma UF.';

  @override
  String get ibgeLocationsFailureUfNotFound => 'UF não encontrada.';

  @override
  String get ibgeLocationsFailureNetwork =>
      'Sem conexão com o servidor. Tente novamente.';

  @override
  String get ibgeLocationsFailureUnexpected =>
      'Algo deu errado. Tente novamente.';

  @override
  String get placesCityUnmatched =>
      'Este município não corresponde ao catálogo. Escolha outra sugestão.';
}
