import 'package:flutter/widgets.dart';

class PersonalDataSlots {
  const PersonalDataSlots({this.header, this.footer = const []});

  final Widget? header;
  final List<Widget> footer;
}

typedef PersonalDataSlotsBuilder =
    PersonalDataSlots Function(BuildContext context);
