import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isVerified => _user?.verificationStatus == 'approved';
  bool get isAdvocate => _user?.role == 'advocate';
  bool get isClient => _user?.role == 'client';

  // ─── Init (restore session) ───────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
    notifyListeners();
  }

  // ─── Login ────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.post(
        ApiConstants.login,
        {'email': email, 'password': password},
        auth: false,
      );

      final token = data['token']?.toString() ?? '';
      await ApiService.saveToken(token);

      _user = UserModel.fromJson({
        ...data['user'] as Map<String, dynamic>? ?? data,
        'token': token,
      });
      await _persistUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Register (Advocate) ──────────────────────────────────────────────

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String barCouncilId,
    required String stateBarCouncil,
    required String enrollmentYear,
    String? courtPreference,
    List<String>? specializations,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.post(
        ApiConstants.register,
        {
          'fullName': fullName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'barCouncilId': barCouncilId,
          'stateBarCouncil': stateBarCouncil,
          'enrollmentYear': enrollmentYear,
          'courtPreference': courtPreference ?? '',
          'specializations': specializations ?? [],
          'role': 'advocate',
        },
        auth: false,
      );

      final token = data['token']?.toString() ?? '';
      await ApiService.saveToken(token);

      _user = UserModel.fromJson({
        ...data['user'] as Map<String, dynamic>? ?? data,
        'token': token,
      });
      await _persistUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Register (Client) ────────────────────────────────────────────────

  Future<bool> registerClient({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    String? city,
    String? state,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.post(
        ApiConstants.register,
        {
          'fullName': fullName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'city': city ?? '',
          'state': state ?? '',
          'role': 'client',
        },
        auth: false,
      );

      final token = data['token']?.toString() ?? '';
      await ApiService.saveToken(token);

      _user = UserModel.fromJson({
        ...data['user'] as Map<String, dynamic>? ?? data,
        'token': token,
      });
      await _persistUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Network error. Check your connection.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────

  Future<void> logout() async {
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _user = null;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────

  Future<void> _persistUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('current_user', jsonEncode(_user!.toJson()));
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
