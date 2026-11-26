import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vanep_mobile/modules/driver/domain/value_objects/shortcut.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/cubit/van_central_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_central/presentation/pages/van_assistants_page.dart';

/// Home navigation of the driver shell: opens the screens that already exist
/// and leaves the others on the coming soon page.
class ShellDriverHomeNavigation extends PendingDriverHomeNavigation {
  const ShellDriverHomeNavigation(super.context);

  @override
  void openShortcut(Shortcut shortcut) {
    if (shortcut != Shortcut.assistants) return super.openShortcut(shortcut);
    openAssistantsThenRefresh();
  }

  Future<void> openAssistantsThenRefresh() async {
    final central = context.read<VanCentralCubit>();
    await openVanAssistants(context);
    await central.refresh();
  }
}
