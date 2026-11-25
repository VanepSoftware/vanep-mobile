abstract class DriverProfileVehicle {
  String get token;

  String get brand;

  String get model;

  int get manufactureYear;

  String get color;

  int get capacity;

  bool get hasAssistant;

  String? get photoFrontUrl;

  String? get photoSideUrl;
}

abstract class DriverShiftVacancy {
  String get shift;

  int? get spots;

  String? get status;
}

abstract class DriverRatingBreakdown {
  int get stars;

  int get count;
}

abstract class DriverProfileRating {
  String get authorName;

  String get dateLabel;

  int get stars;

  String get comment;
}

abstract class DriverProfile {
  String get token;

  String get name;

  String? get phone;

  String? get photoUrl;

  double? get rating;

  int? get ratingCount;

  String? get bio;

  int? get experienceYears;

  double? get basePrice;

  bool get available;

  bool get verified;

  String? get workStartTime;

  String? get workEndTime;

  String? get workDays;

  int? get waitToleranceMinutes;

  List<String> get serviceAreas;

  List<DriverProfileVehicle> get vehicles;

  List<DriverShiftVacancy> get shiftVacancies;

  List<DriverRatingBreakdown> get ratingBreakdown;

  List<DriverProfileRating> get ratings;
}
