/// Códigos de erro estáveis emitidos pela API (`ProblemDetail.code` e
/// `errors[].code`).
///
/// Centraliza os contratos do backend (`vanep-api-java`) para evitar strings
/// soltas nos mappers de falha.
abstract final class ApiErrorCodes {
  // Genéricos / transporte HTTP
  static const validationFailed = 'validation.failed';
  static const requestBodyUnreadable = 'request.body_unreadable';
  static const requestParameterInvalid = 'request.parameter_invalid';
  static const requestRouteNotFound = 'request.route_not_found';
  static const requestMethodNotAllowed = 'request.method_not_allowed';
  static const requestMediaTypeUnsupported = 'request.media_type_unsupported';
  static const requestMediaTypeNotAcceptable =
      'request.media_type_not_acceptable';
  static const requestPayloadTooLarge = 'request.payload_too_large';
  static const requestRateLimited = 'request.rate_limited';
  static const requestConflict = 'request.conflict';
  static const requestUnprocessable = 'request.unprocessable';
  static const requestError = 'request.error';
  static const internalError = 'internal.error';

  // Autenticação e autorização
  static const authUnauthenticated = 'auth.unauthenticated';
  static const authForbidden = 'auth.forbidden';
  static const authErrorInvalidCode = 'auth.error.invalid_code';
  static const authErrorInvalidSignupTicket =
      'auth.error.invalid_signup_ticket';
  static const authErrorValidation = 'auth.error.validation';
  static const authSignupEmailDuplicate = 'auth.signup.email.duplicate';
  static const authSignupDocumentDuplicate = 'auth.signup.document.duplicate';

  // Perfil do usuário
  static const userAccountNotFound = 'user.account.not_found';
  static const userDriverProfileNotFound = 'user.driver_profile.not_found';
  static const userTypeForbidden = 'user.type.forbidden';
  static const userProfileNameCooldown = 'user.profile.name.cooldown';
  static const userProfilePhoneCooldown = 'user.profile.phone.cooldown';
  static const userProfileEmailCooldown = 'user.profile.email.cooldown';
  static const userProfileEmailResendCooldown =
      'user.profile.email.resend.cooldown';
  static const userProfileEmailSame = 'user.profile.email.same';
  static const userProfileFieldNull = 'user.profile.field.null';
  static const userProfilePhoneBlank = 'user.profile.phone.blank';
  static const userProfileEmailInvalid = 'user.profile.email.invalid';
  static const userProfileEmailRequired = 'user.profile.email.required';
  static const userProfileNameTooLong = 'user.profile.name.too_long';
  static const userProfilePhoneTooLong = 'user.profile.phone.too_long';
  static const userProfileEmailTooLong = 'user.profile.email.too_long';

  // Localização, endereços, cidades e CEP
  static const locationCityUnmatched = 'location.city.unmatched';
  static const locationCountryUnsupported = 'location.country.unsupported';
  static const locationStateUnsupported = 'location.state.unsupported';
  static const locationComponentUnknownType = 'location.component.unknown_type';
  static const locationPlaceNotResolvable = 'location.place.not_resolvable';
  static const locationPlaceNotFound = 'location.place.not_found';
  static const locationPlaceLookupFailed = 'location.place.lookup_failed';
  static const locationPlaceRateLimited = 'location.place.rate_limited';
  static const locationAddressNotSet = 'location.address.not_set';
  static const locationAddressStreetRequired =
      'location.address.street_required';
  static const cityNotFound = 'city.not_found';
  static const cityUfRequired = 'city.uf.required';
  static const stateNotFound = 'state.not_found';
  static const stateUfNotFound = 'state.uf.not_found';
  static const cepInvalid = 'cep.invalid';
  static const cepNotFound = 'cep.not_found';
  static const cepIbgeNotFound = 'cep.ibge.not_found';
  static const cepRateLimited = 'cep.rate_limited';
  static const cepLookupFailed = 'cep.lookup_failed';

  // Áreas de atuação do motorista
  static const driverServiceAreaAreasRequired =
      'driver_service_area.areas.required';
  static const driverServiceAreaAreasTooMany =
      'driver_service_area.areas.too_many';
  static const driverServiceAreaDistrictRequired =
      'driver_service_area.district_required';
  static const driverServiceAreaAreaTokenUnknown =
      'driver_service_area.area_token.unknown';
  static const driverServiceAreaItemInvalid =
      'driver_service_area.item.invalid';
  static const driverServiceAreaPlaceIdTooLong =
      'driver_service_area.place_id.too_long';
  static const driverServiceAreaAreaTokenTooLong =
      'driver_service_area.area_token.too_long';
  static const driverServiceAreaSessionTokenTooLong =
      'driver_service_area.session_token.too_long';

  // Assistente
  static const assistantInviteEmailNotFound =
      'assistant.invite.email_not_found';
  static const assistantInviteWrongUserType =
      'assistant.invite.wrong_user_type';
  static const assistantInviteCooldown = 'assistant.invite.cooldown';
  static const assistantInviteNotUnlinked = 'assistant.invite.not_unlinked';
  static const assistantInviteNotFound = 'assistant.invite.not_found';
  static const assistantInviteForbidden = 'assistant.invite.forbidden';
  static const assistantInviteNotPending = 'assistant.invite.not_pending';
  static const assistantInviteExpired = 'assistant.invite.expired';
  static const assistantInviteEmailInvalid = 'assistant.invite.email.invalid';
  static const assistantInviteEmailRequired = 'assistant.invite.email.required';
  static const assistantProfileNotFound = 'assistant.profile.not_found';
  static const assistantNotFound = 'assistant.not_found';
  static const assistantLinkForbidden = 'assistant.link.forbidden';
  static const assistantLinkNotActive = 'assistant.link.not_active';
  static const assistantLinkNotInactive = 'assistant.link.not_inactive';

  // Escolas
  static const schoolNotFound = 'school.not_found';
  static const schoolAlreadyActive = 'school.already_active';
  static const schoolNameBlank = 'school.name.blank';
  static const schoolPlaceNotASchool = 'school.place.not_a_school';

  // Dependentes e endereços relacionados
  static const dependentNotFound = 'dependent.not_found';
  static const dependentAlreadyActive = 'dependent.already_active';
  static const dependentOpenContract = 'dependent.open_contract';
  static const dependentOpenNegotiation = 'dependent.open_negotiation';
  static const dependentForbidden = 'dependent.forbidden';
  static const dependentDocumentDuplicate = 'dependent.document.duplicate';
  static const dependentSchoolDaysWeekdayDuplicate =
      'dependent.school_days.weekday_duplicate';
  static const dependentNameBlank = 'dependent.name.blank';
  static const dependentFieldNull = 'dependent.field.null';
  static const dependentSchoolTokenBlank = 'dependent.school_token.blank';
  static const dependentClientTokenRequired = 'dependent.client_token.required';
  static const addressNotFound = 'address.not_found';
  static const addressAlreadyOwned = 'address.already_owned';
  static const clientNotFound = 'client.not_found';
  static const clientProfileNotFound = 'client.profile.not_found';

  // Mídia e documentos do motorista
  static const mediaFileRequired = 'media.file.required';
  static const mediaFileTooLarge = 'media.file.too_large';
  static const mediaFileUnreadable = 'media.file.unreadable';
  static const mediaMimeNotAllowed = 'media.mime.not_allowed';
  static const mediaNotFound = 'media.not_found';
  static const documentSubmissionPendingExists =
      'document.submission.pending_exists';
  static const documentSubmissionReviewed = 'document.submission.reviewed';

  // Motoristas e veículos
  static const driverNotFound = 'driver.not_found';
  static const driverNotApproved = 'driver.not_approved';
  static const driverAlreadyActive = 'driver.already_active';
  static const vehicleNotFound = 'vehicle.not_found';
  static const vehicleAlreadyActive = 'vehicle.already_active';
  static const vehicleDriverNotFound = 'vehicle.driver.not_found';
  static const vehiclePlateDuplicate = 'vehicle.plate.duplicate';

  // Conversas
  static const conversationNotFound = 'conversation.not_found';
  static const conversationMessageBodyRequired =
      'conversation.message.body.required';
  static const conversationMessageBodyTooLong =
      'conversation.message.body.too_long';

  // Alunos do motorista / passageiros avulsos / família
  static const driverStudentVehicleNotFound =
      'driver_student.vehicle.not_found';
  static const unlinkedPassengerNotFound = 'unlinked_passenger.not_found';
  static const unlinkedPassengerSchoolNotFound =
      'unlinked_passenger.school.not_found';
  static const unlinkedPassengerVehicleNotOwned =
      'unlinked_passenger.vehicle.not_owned';
  static const unlinkedPassengerFieldNull = 'unlinked_passenger.field.null';
  static const unlinkedPassengerNameRequired =
      'unlinked_passenger.name.required';
  static const familyInviteNotFound = 'family_invite.not_found';
  static const familyInviteDependentNotFound =
      'family_invite.dependent.not_found';
  static const familyInviteAlreadyLinked = 'family_invite.already_linked';
  static const familyInviteLinkBlocked = 'family_invite.link_blocked';
  static const familyInviteConcurrentRequest =
      'family_invite.concurrent_request';
  static const familyMatchNotPending = 'family_match.not_pending';
  static const familyMatchAlreadyPending = 'family_match.already_pending';
  static const familyMatchDependentAlreadyLinked =
      'family_match.dependent_already_linked';

  // Negociações (pedidos, propostas, contratos, vínculo cliente-motorista)
  static const serviceRequestNotFound = 'service_request.not_found';
  static const serviceRequestDependentNotFound =
      'service_request.dependent.not_found';
  static const serviceRequestDriverNotFound =
      'service_request.driver.not_found';
  static const serviceRequestOpenExists = 'service_request.open_exists';
  static const serviceRequestOpenLimit = 'service_request.open_limit';
  static const serviceRequestLinkHasContract =
      'service_request.link.has_contract';
  static const serviceRequestLinkBlocked = 'service_request.link.blocked';
  static const serviceRequestNotOpen = 'service_request.not_open';
  static const serviceRequestNotReady = 'service_request.not_ready';
  static const serviceRequestDriverNotAvailable =
      'service_request.driver.not_available';
  static const serviceRequestDayLegRequired =
      'service_request.day.leg_required';
  static const serviceRequestDayNoSchool = 'service_request.day.no_school';
  static const serviceRequestDayWeekdayDuplicate =
      'service_request.day.weekday_duplicate';
  static const serviceRequestItemDependentDuplicate =
      'service_request.item.dependent_duplicate';

  static const proposalNotFound = 'proposal.not_found';
  static const proposalVehicleNotFound = 'proposal.vehicle.not_found';
  static const proposalSentConflict = 'proposal.sent_conflict';
  static const proposalAcceptStale = 'proposal.accept.stale';
  static const proposalNotCurrent = 'proposal.not_current';
  static const proposalRequestNotOpen = 'proposal.request.not_open';
  static const proposalExpired = 'proposal.expired';
  static const proposalItemDependentUnavailable =
      'proposal.item.dependent_unavailable';
  static const proposalItemsMismatch = 'proposal.items.mismatch';
  static const proposalSlotsNotRequested = 'proposal.slots.not_requested';
  static const proposalPeriodInvalid = 'proposal.period.invalid';
  static const proposalPeriodTooLong = 'proposal.period.too_long';
  static const proposalInstallmentsBelowOneCent =
      'proposal.installments.below_one_cent';
  static const proposalAdjustmentEmpty = 'proposal.adjustment.empty';

  static const contractNotFound = 'contract.not_found';
  static const contractActiveConflict = 'contract.active_conflict';
  static const contractStatusInvalidTransition =
      'contract.status.invalid_transition';
  static const contractStatusRequired = 'contract.status.required';
  static const contractStatusRequiresSuccessor =
      'contract.status.requires_successor';
  static const contractLinkBlocked = 'contract.link.blocked';
  static const contractDriverNotApproved = 'contract.driver.not_approved';
  static const contractPeriodInvalid = 'contract.period.invalid';
  static const contractPeriodTooLong = 'contract.period.too_long';
  static const contractInstallmentsBelowOneCent =
      'contract.installments.below_one_cent';
  static const contractItemAddressRequired = 'contract.item.address_required';
  static const contractItemDependentNotInLink =
      'contract.item.dependent_not_in_link';
  static const contractItemDuplicateDependent =
      'contract.item.duplicate_dependent';
  static const contractItemSchoolRequired = 'contract.item.school_required';
  static const contractItemSlotConflict = 'contract.item.slot_conflict';

  static const clientDriverNotFound = 'client_driver.not_found';
  static const clientDriverClientNotFound = 'client_driver.client.not_found';
  static const clientDriverDriverNotFound = 'client_driver.driver.not_found';
  static const clientDriverAlreadyBlocked = 'client_driver.already_blocked';
  static const clientDriverDuplicatePair = 'client_driver.duplicate_pair';
  static const clientDriverNotBlocked = 'client_driver.not_blocked';
  static const clientDriverDriverNotApproved =
      'client_driver.driver.not_approved';
  static const clientDriverBlockHasContract =
      'client_driver.block.has_contract';
  static const clientDriverUnblockNotBlocker =
      'client_driver.unblock.not_blocker';
}
