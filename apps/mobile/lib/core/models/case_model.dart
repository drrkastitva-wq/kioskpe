class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String caseType;
  final String? courtName;
  final String? courtId;
  final String filingDate;
  final String? nextHearingDate;
  final String stage;
  final String status; // active, pending, closed, urgent
  final String clientName;
  final String? clientContact;
  final String? assignedAdvocateId;
  final String? notes;
  final String? oppositeParty;
  final String? oppositeAdvocate;
  final DateTime? createdAt;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.caseType,
    this.courtName,
    this.courtId,
    required this.filingDate,
    this.nextHearingDate,
    required this.stage,
    required this.status,
    required this.clientName,
    this.clientContact,
    this.assignedAdvocateId,
    this.notes,
    this.oppositeParty,
    this.oppositeAdvocate,
    this.createdAt,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id']?.toString() ?? '',
      caseNumber: json['caseNumber'] ?? json['case_number'] ?? '',
      title: json['title'] ?? '',
      caseType: json['caseType'] ?? json['case_type'] ?? '',
      courtName: json['courtName'] ?? json['court_name'],
      courtId: json['courtId']?.toString() ?? json['court_id']?.toString(),
      filingDate: json['filingDate'] ?? json['filing_date'] ?? '',
      nextHearingDate: json['nextHearingDate'] ?? json['next_hearing_date'],
      stage: json['stage'] ?? '',
      status: json['status'] ?? 'active',
      clientName: json['clientName'] ?? json['client_name'] ?? '',
      clientContact: json['clientContact'] ?? json['client_contact'],
      assignedAdvocateId: json['assignedAdvocateId']?.toString() ?? json['assigned_advocate_id']?.toString(),
      notes: json['notes'],
      oppositeParty: json['oppositeParty'] ?? json['opposite_party'],
      oppositeAdvocate: json['oppositeAdvocate'] ?? json['opposite_advocate'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'caseNumber': caseNumber,
    'title': title,
    'caseType': caseType,
    'courtName': courtName,
    'courtId': courtId,
    'filingDate': filingDate,
    'nextHearingDate': nextHearingDate,
    'stage': stage,
    'status': status,
    'clientName': clientName,
    'clientContact': clientContact,
    'assignedAdvocateId': assignedAdvocateId,
    'notes': notes,
    'oppositeParty': oppositeParty,
    'oppositeAdvocate': oppositeAdvocate,
  };
}
