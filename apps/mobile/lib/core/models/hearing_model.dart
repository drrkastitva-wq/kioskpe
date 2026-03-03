class HearingModel {
  final String id;
  final String caseId;
  final String? caseTitle;
  final String? caseNumber;
  final String hearingDate;
  final String? courtHall;
  final String? purpose;
  final String? outcomeNotes;
  final String? nextDate;

  HearingModel({
    required this.id,
    required this.caseId,
    this.caseTitle,
    this.caseNumber,
    required this.hearingDate,
    this.courtHall,
    this.purpose,
    this.outcomeNotes,
    this.nextDate,
  });

  factory HearingModel.fromJson(Map<String, dynamic> json) {
    return HearingModel(
      id: json['id']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? json['case_id']?.toString() ?? '',
      caseTitle: json['caseTitle'] ?? json['case_title'],
      caseNumber: json['caseNumber'] ?? json['case_number'],
      hearingDate: json['hearingDate'] ?? json['hearing_date'] ?? '',
      courtHall: json['courtHall'] ?? json['court_hall'],
      purpose: json['purpose'],
      outcomeNotes: json['outcomeNotes'] ?? json['outcome_notes'],
      nextDate: json['nextDate'] ?? json['next_date'],
    );
  }

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'hearingDate': hearingDate,
    'courtHall': courtHall,
    'purpose': purpose,
    'outcomeNotes': outcomeNotes,
    'nextDate': nextDate,
  };
}
