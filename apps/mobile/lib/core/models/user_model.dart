class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  /// 'advocate' | 'client'
  final String role;
  // Advocate-specific
  final String? barCouncilId;
  final String? stateBarCouncil;
  final String? enrollmentYear;
  final String? courtPreference;
  final List<String> specializations;
  // Client-specific
  final String? city;
  final String? state;
  final String verificationStatus; // pending, approved, rejected
  final String? token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.role,
    this.barCouncilId,
    this.stateBarCouncil,
    this.enrollmentYear,
    this.courtPreference,
    this.specializations = const [],
    this.city,
    this.state,
    required this.verificationStatus,
    this.token,
  });

  bool get isAdvocate => role == 'advocate';
  bool get isClient => role == 'client';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final specRaw = json['specializations'];
    final specs = specRaw is List
        ? specRaw.map((e) => e.toString()).toList()
        : <String>[];
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? json['phone'] ?? '',
      role: json['role'] ?? 'advocate',
      barCouncilId: json['barCouncilId'] ?? json['bar_council_id'],
      stateBarCouncil: json['stateBarCouncil'] ?? json['state_bar_council'],
      enrollmentYear: json['enrollmentYear']?.toString() ?? json['enrollment_year']?.toString(),
      courtPreference: json['courtPreference'] ?? json['courtName'],
      specializations: specs,
      city: json['city'],
      state: json['state'],
      verificationStatus: json['verificationStatus'] ?? json['verification_status'] ?? 'pending',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'mobile': mobile,
    'role': role,
    'barCouncilId': barCouncilId,
    'stateBarCouncil': stateBarCouncil,
    'enrollmentYear': enrollmentYear,
    'courtPreference': courtPreference,
    'specializations': specializations,
    'city': city,
    'state': state,
    'verificationStatus': verificationStatus,
  };
}
