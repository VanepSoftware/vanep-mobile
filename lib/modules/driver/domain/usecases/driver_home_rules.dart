import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';

class DriverHomeRules {
  const DriverHomeRules();

  HomeState resolve(DriverHomeData data) {
    // Bloqueio durante IN_PROGRESS vira banner; a operação nunca para.
    if (data.isOperating) {
      return HomeState(
        HomePhase.inProgress,
        blockBanner: data.isBlocked ? data.blockReason : null,
      );
    }
    // Fora de uma operação ativa, respeita a prioridade dos estados do escopo.
    if (data.isBlocked) return const HomeState(HomePhase.blocked);
    switch (data.registration) {
      case RegistrationStatus.incomplete:
        return const HomeState(HomePhase.incomplete);
      case RegistrationStatus.underReview:
        return const HomeState(HomePhase.underReview);
      case RegistrationStatus.rejected:
        return const HomeState(HomePhase.rejected);
      case RegistrationStatus.approved:
        break;
    }
    if (data.todayTrip?.status == TripStatus.notStarted) {
      return const HomeState(HomePhase.beforeDeparture);
    }
    if (data.todayTrip?.status == TripStatus.completed &&
        data.laterShiftLabel?.trim().isNotEmpty == true) {
      return const HomeState(HomePhase.shiftCompleted);
    }
    if (data.studentCount == 0) {
      return const HomeState(HomePhase.buildingRoute);
    }
    return const HomeState(HomePhase.noRouteToday);
  }

  bool shortcutEnabled(DriverHomeData data, Shortcut shortcut) {
    // Cadastro incompleto: somente Documentos abre, demais ficam apagados.
    // Uma viagem ativa mantém a operação, inclusive em dados inconsistentes.
    return data.isOperating ||
        data.registration != RegistrationStatus.incomplete ||
        shortcut == Shortcut.documents;
  }

  DriverHomeMessage? startDenial(DriverHomeData data) {
    // RN-02: iniciar rota exige APPROVED, também no controlador.
    if (data.registration != RegistrationStatus.approved) {
      return DriverHomeMessage.approvalRequired;
    }
    if (data.isBlocked) return data.blockReason;
    if (data.todayTrip?.status != TripStatus.notStarted) {
      return DriverHomeMessage.noPendingRoute;
    }
    // Fora do expediente apenas avisa: não impede iniciar rota.
    return null;
  }

  int? familyCounter(DriverHomeData data) {
    final families = data.familiesInApp;
    if (data.studentCount <= 0 || families == null) return null;
    return families.clamp(0, data.studentCount);
  }

  bool canConfirm(DriverHomeData data, StopConfirmation expected) {
    final current = data.nextConfirmation;
    // Bloqueio não impede embarque/desembarque de viagem IN_PROGRESS.
    return data.isOperating &&
        current != null &&
        current.tripId == data.todayTrip?.id &&
        current.tripId == expected.tripId &&
        current.stopId == expected.stopId &&
        current.studentId == expected.studentId &&
        current.action == expected.action;
  }
}
