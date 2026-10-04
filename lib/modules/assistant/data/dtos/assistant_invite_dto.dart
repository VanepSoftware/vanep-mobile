import '../../domain/entities/assistant_invite.dart';

class AssistantInviteDto extends AssistantInvite {
  const AssistantInviteDto({
    required super.token,
    required super.driverName,
    super.driverPhoto,
    super.driverRating,
    super.vehicleDescription,
    required super.expiresAt,
    required super.status,
  });

  factory AssistantInviteDto.fromJson(Map<String, Object?> json) {
    final driverMap = json['driver'] as Map<String, Object?>?;
    final driverName = driverMap?['name'] as String? ??
        json['driverName'] as String? ??
        '';
    final driverPhoto =
        driverMap?['photo'] as String? ?? json['driverPhoto'] as String?;
    final driverRating = (driverMap?['rating'] as num?)?.toDouble() ??
        (json['driverRating'] as num?)?.toDouble();

    final expiresRaw = json['expiresAt'] as String?;
    final expiresAt = expiresRaw != null
        ? DateTime.tryParse(expiresRaw) ?? DateTime.now()
        : DateTime.now();

    return AssistantInviteDto(
      token: json['token'] as String? ?? '',
      driverName: driverName,
      driverPhoto: driverPhoto,
      driverRating: driverRating,
      vehicleDescription: json['vehicleDescription'] as String?,
      expiresAt: expiresAt,
      status: json['status'] as String? ?? 'PENDING',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'token': token,
      'driverName': driverName,
      if (driverPhoto != null) 'driverPhoto': driverPhoto,
      if (driverRating != null) 'driverRating': driverRating,
      if (vehicleDescription != null) 'vehicleDescription': vehicleDescription,
      'expiresAt': expiresAt.toIso8601String(),
      'status': status,
    };
  }
}
