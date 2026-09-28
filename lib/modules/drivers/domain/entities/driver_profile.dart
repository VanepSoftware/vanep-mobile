abstract class DriverProfileVehicle {
  String get token;

  String get brand;

  String get model;

  int get manufactureYear;

  String get color;

  int get capacity;

  String? get photoFrontUrl;

  String? get photoSideUrl;
}

abstract class DriverProfile {
  String get token;

  String get name;

  String? get phone;

  String? get photoUrl;

  double? get rating;

  String? get bio;

  int? get experienceYears;

  double? get basePrice;

  bool get available;

  List<String> get serviceAreas;

  List<DriverProfileVehicle> get vehicles;
}
