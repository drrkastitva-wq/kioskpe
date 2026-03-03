import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/reminder_model.dart';
import '../services/api_service.dart';

class ReminderProvider extends ChangeNotifier {
  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ReminderModel> get pendingReminders =>
      _reminders.where((r) => r.status == 'pending').toList();

  List<ReminderModel> get overdueReminders =>
      _reminders.where((r) => r.isOverdue).toList();

  Future<void> fetchReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get(ApiConstants.reminders);
      final list = (data['reminders'] ?? data['data'] ?? data) as List<dynamic>;
      _reminders = list
          .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load reminders.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addReminder(Map<String, dynamic> payload) async {
    try {
      final data = await ApiService.post(ApiConstants.reminders, payload);
      final r = ReminderModel.fromJson(
        data['reminder'] as Map<String, dynamic>? ?? data,
      );
      _reminders.insert(0, r);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markDone(String id) async {
    try {
      await ApiService.put('${ApiConstants.reminders}/$id', {'status': 'done'});
      final idx = _reminders.indexWhere((r) => r.id == id);
      if (idx >= 0) {
        final old = _reminders[idx];
        _reminders[idx] = ReminderModel(
          id: old.id,
          caseId: old.caseId,
          caseTitle: old.caseTitle,
          assignedUserId: old.assignedUserId,
          title: old.title,
          dueDate: old.dueDate,
          priority: old.priority,
          status: 'done',
          reminderChannel: old.reminderChannel,
          description: old.description,
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
