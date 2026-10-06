import 'package:equatable/equatable.dart';

import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';

class VanPhotoTarget extends Equatable {
  const VanPhotoTarget({required this.vanToken, required this.side});

  final String vanToken;
  final VanPhotoSide side;

  @override
  List<Object?> get props => [vanToken, side];
}
