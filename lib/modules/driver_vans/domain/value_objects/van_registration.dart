import 'package:equatable/equatable.dart';

enum VanField { plate, brand, model, manufactureYear, color, capacity }

enum VanFieldError { required, invalid }

const int minVanManufactureYear = 1900;

const int maxVanManufactureYear = 2100;

final RegExp vanPlatePattern = RegExp(r'^[A-Z]{3}-?\d[A-Z0-9]\d{2}$');

class VanRegistration extends Equatable {
  const VanRegistration({
    this.plate = '',
    this.brand = '',
    this.model = '',
    this.manufactureYear = '',
    this.color = '',
    this.capacity = '',
  });

  final String plate;
  final String brand;
  final String model;
  final String manufactureYear;
  final String color;
  final String capacity;

  String get normalizedPlate => plate.trim().toUpperCase();

  int? get parsedManufactureYear => int.tryParse(manufactureYear.trim());

  int? get parsedCapacity => int.tryParse(capacity.trim());

  String valueOf(VanField field) {
    return switch (field) {
      VanField.plate => plate,
      VanField.brand => brand,
      VanField.model => model,
      VanField.manufactureYear => manufactureYear,
      VanField.color => color,
      VanField.capacity => capacity,
    };
  }

  VanRegistration copyWithField(VanField field, String value) {
    return VanRegistration(
      plate: field == VanField.plate ? value : plate,
      brand: field == VanField.brand ? value : brand,
      model: field == VanField.model ? value : model,
      manufactureYear: field == VanField.manufactureYear
          ? value
          : manufactureYear,
      color: field == VanField.color ? value : color,
      capacity: field == VanField.capacity ? value : capacity,
    );
  }

  Map<VanField, VanFieldError> validate() {
    final errors = <VanField, VanFieldError>{};
    for (final field in VanField.values) {
      if (valueOf(field).trim().isEmpty) {
        errors[field] = VanFieldError.required;
      }
    }
    if (!errors.containsKey(VanField.plate) &&
        !vanPlatePattern.hasMatch(normalizedPlate)) {
      errors[VanField.plate] = VanFieldError.invalid;
    }
    final year = parsedManufactureYear;
    if (!errors.containsKey(VanField.manufactureYear) &&
        (year == null ||
            year < minVanManufactureYear ||
            year > maxVanManufactureYear)) {
      errors[VanField.manufactureYear] = VanFieldError.invalid;
    }
    final seats = parsedCapacity;
    if (!errors.containsKey(VanField.capacity) &&
        (seats == null || seats < 1)) {
      errors[VanField.capacity] = VanFieldError.invalid;
    }
    return errors;
  }

  @override
  List<Object?> get props => [
    plate,
    brand,
    model,
    manufactureYear,
    color,
    capacity,
  ];
}
