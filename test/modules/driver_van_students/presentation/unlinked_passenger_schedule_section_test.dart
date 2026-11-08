import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/places/place_search_session.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_cubit.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/cubit/unlinked_passenger_form_state.dart';
import 'package:vanep_mobile/modules/driver_van_students/presentation/pages/unlinked_passenger_form_page.dart';

import '../../../core/ui/localized_harness.dart';
import '../driver_van_students_mocks.dart';

void main() {
  testWidgets(
    'checking a day applies the default and a later default leaves a custom time',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final autocomplete = MockPlaceAutocompleteController();
      when(() => autocomplete.session).thenReturn(PlaceSearchSession());
      when(() => autocomplete.dispose()).thenAnswer((_) {});
      final cubit = UnlinkedPassengerFormCubit(
        vehicleToken: 'van-1',
        autocomplete: autocomplete,
        resolveSchool: MockResolveSchool(),
        lookupCep: MockLookupCep(),
        listStates: MockListStates(),
        listCities: MockListCities(),
        createUnlinkedPassenger: MockCreateUnlinkedPassenger(),
      );

      await tester.pumpWidget(
        localizedHarness(
          BlocProvider<UnlinkedPassengerFormCubit>(
            create: (_) => cubit,
            child:
                BlocBuilder<
                  UnlinkedPassengerFormCubit,
                  UnlinkedPassengerFormState
                >(
                  builder: (context, state) => Scaffold(
                    body: SingleChildScrollView(
                      child: UnlinkedPassengerScheduleSection(state: state),
                    ),
                  ),
                ),
          ),
        ),
      );

      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('Definir'), findsNothing);

      await tester.tap(find.byType(WeekLegCellButton).at(0));
      await tester.pump();

      expect(find.text('08:00'), findsNWidgets(2));
      expect(find.text('Definir'), findsNothing);

      const custom = ClockTime(hour: 7, minute: 15);
      const nextDefault = ClockTime(hour: 7, minute: 45);
      cubit
        ..changeTime(Weekday.monday, RouteLeg.outbound, custom)
        ..changeDefaultTime(RouteLeg.outbound, nextDefault);
      await tester.pump();

      expect(find.text('07:15'), findsOneWidget);
      expect(find.text('07:45'), findsOneWidget);
      expect(find.text('08:00'), findsNothing);

      await tester.tap(find.byType(WeekLegCellButton).at(1));
      await tester.pump();

      expect(find.text('07:15'), findsOneWidget);
      expect(find.text('07:45'), findsNWidgets(2));
    },
  );
}
