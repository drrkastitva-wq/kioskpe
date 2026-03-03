class DiaryEntryModel {
  final String id;
  final String userId;
  final String entryDate;
  final String title;
  final String description;
  final String? linkedCaseId;
  final String? linkedCaseTitle;
  final String? entryType; // hearing, meeting, task, note, call

  DiaryEntryModel({
    required this.id,
    required this.userId,
    required this.entryDate,
    required this.title,
    required this.description,
    this.linkedCaseId,
    this.linkedCaseTitle,
    this.entryType,
  });

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      entryDate: json['entryDate'] ?? json['entry_date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      linkedCaseId: json['linkedCaseId']?.toString() ?? json['linked_case_id']?.toString(),
      linkedCaseTitle: json['linkedCaseTitle'] ?? json['linked_case_title'],
      entryType: json['entryType'] ?? json['entry_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'entryDate': entryDate,
    'title': title,
    'description': description,
    'linkedCaseId': linkedCaseId,
    'entryType': entryType,
  };
}
