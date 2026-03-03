import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/diary_entry_model.dart';
import '../services/api_service.dart';

class DiaryProvider extends ChangeNotifier {
  List<DiaryEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<DiaryEntryModel> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get(ApiConstants.diary);
      final list = (data['entries'] ?? data['data'] ?? data) as List<dynamic>;
      _entries = list
          .map((e) => DiaryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load diary entries.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addEntry(Map<String, dynamic> payload) async {
    try {
      final data = await ApiService.post(ApiConstants.diary, payload);
      final entry = DiaryEntryModel.fromJson(
        data['entry'] as Map<String, dynamic>? ?? data,
      );
      _entries.insert(0, entry);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      await ApiService.delete('${ApiConstants.diary}/$id');
      _entries.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
