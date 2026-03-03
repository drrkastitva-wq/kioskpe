class ReminderModel {
  final String id;
  final String? caseId;
  final String? caseTitle;
  final String? assignedUserId;
  final String title;
  final String dueDate;
  final String priority; // low, medium, high, urgent
  final String status;   // pending, done
  final String? reminderChannel;
  final String? description;

  ReminderModel({
    required this.id,
    this.caseId,
    this.caseTitle,
    this.assignedUserId,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.status,
    this.reminderChannel,
    this.description,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      caseId: json['caseId']?.toString() ?? json['case_id']?.toString(),
      caseTitle: json['caseTitle'] ?? json['case_title'],
      assignedUserId: json['assignedUserId']?.toString() ?? json['assigned_user_id']?.toString(),
      title: json['title'] ?? '',
      dueDate: json['dueDate'] ?? json['due_date'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'pending',
      reminderChannel: json['reminderChannel'] ?? json['reminder_channel'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'title': title,
    'dueDate': dueDate,
    'priority': priority,
    'status': status,
    'reminderChannel': reminderChannel,
    'description': description,
  };

  bool get isOverdue {
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    return due.isBefore(DateTime.now()) && status == 'pending';
  }
}
