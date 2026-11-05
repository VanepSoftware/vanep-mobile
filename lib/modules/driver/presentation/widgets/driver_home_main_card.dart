import 'package:flutter/material.dart';

import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

// Destinos do card são injetados pela navegação; regras ficam no domínio.
abstract interface class DriverHomeNavigation {
  void openShortcut(Shortcut shortcut);
  void openRegularization();
  void correctAndResubmit();
  void openChecklist(String tripId);
  void callContact(String tripId);
}

class DriverHomeMainCard extends StatelessWidget {
  const DriverHomeMainCard({super.key, required this.data, required this.phase,
    required this.cubit, required this.navigation, required this.enabled});
  final DriverHomeData data;
  final HomePhase phase;
  final DriverHomeCubit cubit;
  final DriverHomeNavigation navigation;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final trip = data.todayTrip;
    final (title, description) = switch (phase) {
      HomePhase.blocked => ('Regularização necessária', data.blockReason),
      HomePhase.incomplete => ('Complete seu cadastro',
        'Acesse Documentos para concluir as informações pendentes.'),
      HomePhase.underReview => ('Cadastro em análise',
        'Aguarde a análise dos documentos enviados.'),
      HomePhase.rejected => ('Cadastro rejeitado',
        data.rejectionReason ?? 'Consulte os documentos para verificar o motivo.'),
      HomePhase.inProgress => ('Em rota', trip!.label),
      HomePhase.beforeDeparture => ('Antes de sair', trip!.label),
      HomePhase.shiftCompleted => ('Turno concluído',
        'Próximo turno: ${data.laterShiftLabel}'),
      HomePhase.buildingRoute => ('Vamos montar sua rota',
        'Seu cadastro está aprovado. Adicione alunos para organizar sua rota.'),
      HomePhase.noRouteToday => ('Sem rota hoje',
        'Acompanhe e organize seu negócio pelos atalhos abaixo.'),
    };
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 16),
        ...switch (phase) {
          HomePhase.blocked => <Widget>[
            FilledButton(onPressed: navigation.openRegularization,
              child: const Text('Regularizar')),
          ],
          HomePhase.incomplete => <Widget>[
            FilledButton(onPressed: () => navigation.openShortcut(Shortcut.documents),
              child: const Text('Completar cadastro')),
          ],
          HomePhase.rejected => <Widget>[
            FilledButton(onPressed: navigation.correctAndResubmit,
              child: const Text('Corrigir e reenviar')),
          ],
          HomePhase.beforeDeparture => <Widget>[
            OutlinedButton(onPressed: enabled
              ? () => navigation.openChecklist(trip!.id) : null,
              child: const Text('Checklist')),
            FilledButton(onPressed: enabled ? cubit.startRoute : null,
              child: const Text('Iniciar rota')),
          ],
          HomePhase.inProgress => <Widget>[
            OutlinedButton(onPressed: () => navigation.openChecklist(trip!.id),
              child: const Text('Checklist')),
            if (data.contactLabel != null)
              OutlinedButton(onPressed: () => navigation.callContact(trip!.id),
                child: Text('Ligar: ${data.contactLabel}')),
            if (data.nextConfirmation case final StopConfirmation next)
              SlideStopConfirmation(
                key: ValueKey((next.tripId, next.stopId, next.studentId, next.action)),
                confirmation: next, enabled: enabled,
                onConfirmed: () => cubit.confirmBySlide(next)),
          ],
          HomePhase.buildingRoute => <Widget>[
            FilledButton(onPressed: () => navigation.openShortcut(Shortcut.students),
              child: const Text('Adicionar alunos')),
          ],
          _ => <Widget>[],
        },
      ],
    );
    // Rejeição preserva a estrutura de análise, com card vermelho e motivo.
    if (phase == HomePhase.rejected) {
      return Card(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(padding: const EdgeInsets.all(16), child: content));
    }
    return VanepCard(child: content);
  }
}
