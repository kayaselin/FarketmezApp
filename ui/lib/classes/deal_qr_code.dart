class CampaignQRCode {
  int qrCodeId;
  int institutionalId;
  String uniqueIdentifier;
  DateTime generatedTime;
  DateTime expirationTime;
  int userId;
  String status;

  CampaignQRCode({
    required this.qrCodeId,
    required this.institutionalId,
    required this.uniqueIdentifier,
    required this.generatedTime,
    required this.expirationTime,
    required this.userId,
    required this.status,
  });

  factory CampaignQRCode.fromJson(Map<String, dynamic> json) {
    return CampaignQRCode(
      qrCodeId: json['qr_code_id'],
      institutionalId: json['institutional_id'],
      uniqueIdentifier: json['unique_identifier'],
      generatedTime: DateTime.parse(json['generated_time']),
      expirationTime: DateTime.parse(json['expiration_time']),
      userId: json['user_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code_id': qrCodeId,
      'institutional_id': institutionalId,
      'unique_identifier': uniqueIdentifier,
      'generated_time': generatedTime.toIso8601String(),
      'expiration_time': expirationTime.toIso8601String(),
      'user_id': userId,
      'status': status,
    };
  }
}
