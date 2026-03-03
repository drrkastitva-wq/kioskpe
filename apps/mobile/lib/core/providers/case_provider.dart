import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/case_model.dart';
import '../services/api_service.dart';

class CaseProvider extends ChangeNotifier {
  List<CaseModel> _cases = [];
  CaseModel? _selectedCase;
  bool _isLoading = false;
  String? _error;

  List<CaseModel> get cases => _cases;
  CaseModel? get selectedCase => _selectedCase;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CaseModel> get activeCases =>
      _cases.where((c) => c.status == 'active').toList();

  List<CaseModel> get todayHearings {
    final today = DateTime.now();
    return _cases.where((c) {
      if (c.nextHearingDate == null) return false;
      final d = DateTime.tryParse(c.nextHearingDate!);
      return d != null &&
          d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).toList();
  }

  Future<void> fetchCases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.get(ApiConstants.cases);
      final list = (data['cases'] ?? data['data'] ?? data) as List<dynamic>;
      _cases = list.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Failed to load cases.';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCase(Map<String, dynamic> payload) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.post(ApiConstants.cases, payload);
      final newCase = CaseModel.fromJson(
        data['case'] as Map<String, dynamic>? ?? data,
      );
      _cases.insert(0, newCase);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCase(String id, Map<String, dynamic> payload) async {
    try {
      final data = await ApiService.put('${ApiConstants.cases}/$id', payload);
      final updated = CaseModel.fromJson(
        data['case'] as Map<String, dynamic>? ?? data,
      );
      final idx = _cases.indexWhere((c) => c.id == id);
      if (idx >= 0) _cases[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void selectCase(CaseModel c) {
    _selectedCase = c;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
