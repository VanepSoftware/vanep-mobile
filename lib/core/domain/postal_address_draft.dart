import 'package:equatable/equatable.dart';

const brazilianZipDigitCount = 8;

class PostalAddressLimits {
  const PostalAddressLimits._();

  static const int street = 255;
  static const int number = 16;
  static const int complement = 128;
  static const int neighborhood = 128;
}

enum PostalAddressIssue { cityRequired, streetRequired, zipCodeInvalid }

String extractZipDigits(String raw) => raw.replaceAll(RegExp(r'\D'), '');

String limitZipDigits(String raw) {
  final digits = extractZipDigits(raw);
  if (digits.length <= brazilianZipDigitCount) return digits;
  return digits.substring(0, brazilianZipDigitCount);
}

String limitText(String raw, int maxLength) {
  if (raw.length <= maxLength) return raw;
  return raw.substring(0, maxLength);
}

String? blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

class PostalAddressDraft extends Equatable {
  const PostalAddressDraft({
    this.zipCode = '',
    this.cityToken = '',
    this.cityName = '',
    this.uf = '',
    this.street = '',
    this.neighborhood = '',
    this.number = '',
    this.complement = '',
    this.isCityUnlocked = false,
    this.isNeighborhoodLocked = false,
    this.isZipCodeUnknown = false,
  });

  factory PostalAddressDraft.fromParts({
    String? zipCode,
    String? cityToken,
    String? cityName,
    String? uf,
    String? street,
    String? neighborhood,
    String? number,
    String? complement,
  }) {
    return PostalAddressDraft(
      zipCode: limitZipDigits(zipCode ?? ''),
      cityToken: cityToken ?? '',
      cityName: cityName ?? '',
      uf: uf ?? '',
      street: street ?? '',
      neighborhood: neighborhood ?? '',
      number: number ?? '',
      complement: complement ?? '',
    );
  }

  final String zipCode;
  final String cityToken;
  final String cityName;
  final String uf;
  final String street;
  final String neighborhood;
  final String number;
  final String complement;
  final bool isCityUnlocked;
  final bool isNeighborhoodLocked;
  final bool isZipCodeUnknown;

  bool get isCityLocked => cityToken.isNotEmpty && !isCityUnlocked;

  bool get isBlank =>
      zipCode.isEmpty &&
      cityToken.isEmpty &&
      cityName.isEmpty &&
      uf.isEmpty &&
      street.trim().isEmpty &&
      neighborhood.trim().isEmpty &&
      number.trim().isEmpty &&
      complement.trim().isEmpty;

  Set<PostalAddressIssue> get issues => {
    if (cityToken.isEmpty) PostalAddressIssue.cityRequired,
    if (street.trim().isEmpty) PostalAddressIssue.streetRequired,
    if (zipCode.length != brazilianZipDigitCount)
      PostalAddressIssue.zipCodeInvalid,
  };

  bool get isComplete => issues.isEmpty;

  bool get isSavable => isComplete && !isZipCodeUnknown;

  bool sameContentAs(PostalAddressDraft other) {
    return zipCode == other.zipCode &&
        cityToken == other.cityToken &&
        cityName == other.cityName &&
        uf == other.uf &&
        street.trim() == other.street.trim() &&
        neighborhood.trim() == other.neighborhood.trim() &&
        number.trim() == other.number.trim() &&
        complement.trim() == other.complement.trim();
  }

  PostalAddressDraft copyWith({
    String? zipCode,
    String? cityToken,
    String? cityName,
    String? uf,
    String? street,
    String? neighborhood,
    String? number,
    String? complement,
    bool? isCityUnlocked,
    bool? isNeighborhoodLocked,
    bool? isZipCodeUnknown,
  }) {
    return PostalAddressDraft(
      zipCode: zipCode ?? this.zipCode,
      cityToken: cityToken ?? this.cityToken,
      cityName: cityName ?? this.cityName,
      uf: uf ?? this.uf,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      isCityUnlocked: isCityUnlocked ?? this.isCityUnlocked,
      isNeighborhoodLocked: isNeighborhoodLocked ?? this.isNeighborhoodLocked,
      isZipCodeUnknown: isZipCodeUnknown ?? this.isZipCodeUnknown,
    );
  }

  PostalAddressDraft withZipCode(String raw) {
    final digits = limitZipDigits(raw);
    return copyWith(
      zipCode: digits,
      isZipCodeUnknown: false,
      isCityUnlocked: isCityUnlocked || digits.length < brazilianZipDigitCount,
    );
  }

  PostalAddressDraft withStreet(String value) {
    return copyWith(street: limitText(value, PostalAddressLimits.street));
  }

  PostalAddressDraft withNeighborhood(String value) {
    return copyWith(
      neighborhood: limitText(value, PostalAddressLimits.neighborhood),
    );
  }

  PostalAddressDraft withNumber(String value) {
    return copyWith(number: limitText(value, PostalAddressLimits.number));
  }

  PostalAddressDraft withComplement(String value) {
    return copyWith(
      complement: limitText(value, PostalAddressLimits.complement),
    );
  }

  PostalAddressDraft withCepLookup({
    required String cityToken,
    required String cityName,
    required String uf,
    String? street,
    String? neighborhood,
  }) {
    final brought = limitText(
      neighborhood?.trim() ?? '',
      PostalAddressLimits.neighborhood,
    );
    return copyWith(
      cityToken: cityToken,
      cityName: cityName,
      uf: uf,
      street: limitText(street ?? '', PostalAddressLimits.street),
      neighborhood: brought,
      isNeighborhoodLocked: brought.isNotEmpty,
      isCityUnlocked: false,
      isZipCodeUnknown: false,
    );
  }

  PostalAddressDraft withCepUnavailable() {
    return copyWith(
      cityToken: '',
      cityName: '',
      uf: '',
      street: '',
      neighborhood: '',
      isNeighborhoodLocked: false,
      isCityUnlocked: true,
    );
  }

  PostalAddressDraft withCepUnknown() {
    return withCepUnavailable().copyWith(isZipCodeUnknown: true);
  }

  PostalAddressDraft withUf(String uf) {
    return copyWith(uf: uf, cityToken: '', cityName: '', isCityUnlocked: true);
  }

  PostalAddressDraft withCity({
    required String token,
    required String name,
    required String uf,
  }) {
    return copyWith(cityToken: token, cityName: name, uf: uf);
  }

  PostalAddressDraft unlockCity() => copyWith(isCityUnlocked: true);

  @override
  List<Object?> get props => [
    zipCode,
    cityToken,
    cityName,
    uf,
    street,
    neighborhood,
    number,
    complement,
    isCityUnlocked,
    isNeighborhoodLocked,
    isZipCodeUnknown,
  ];
}
