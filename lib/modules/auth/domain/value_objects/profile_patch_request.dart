import 'gender.dart';

class ProfilePatchRequest {
  const ProfilePatchRequest({
    this.name,
    this.phone,
    this.gender,
    this.includesName = false,
    this.includesPhone = false,
    this.includesGender = false,
  });

  final String? name;
  final String? phone;
  final Gender? gender;
  final bool includesName;
  final bool includesPhone;
  final bool includesGender;

  bool get isEmpty => !includesName && !includesPhone && !includesGender;

  Map<String, Object?> toJsonMap() {
    final body = <String, Object?>{};
    if (includesName) {
      body['name'] = name;
    }
    if (includesPhone) {
      body['phone'] = phone;
    }
    if (includesGender) {
      body['gender'] = Gender.toApi(gender);
    }
    return body;
  }
}

class ProfilePatchRequestBuilder {
  String? _name;
  String? _phone;
  Gender? _gender;
  bool _includesName = false;
  bool _includesPhone = false;
  bool _includesGender = false;

  void setName(String name) {
    _includesName = true;
    _name = name;
  }

  void setPhone(String phone) {
    _includesPhone = true;
    _phone = phone;
  }

  void setGender(Gender gender) {
    _includesGender = true;
    _gender = gender;
  }

  ProfilePatchRequest build() {
    return ProfilePatchRequest(
      name: _name,
      phone: _phone,
      gender: _gender,
      includesName: _includesName,
      includesPhone: _includesPhone,
      includesGender: _includesGender,
    );
  }
}
