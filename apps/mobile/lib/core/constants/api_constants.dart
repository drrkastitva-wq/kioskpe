class ApiConstants {
  // ── Production (AWS Lightsail) ─────────────────────────────────────────────
  static const String baseUrl = 'http://65.2.33.48/api';
  // ── Local development (uncomment below and comment above) ─────────────────
  // static const String baseUrl = 'http://localhost:4000/api';
  // On Android emulator use: 'http://10.0.2.2:4000/api'

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String me = '/auth/me';

  // Cases
  static const String cases = '/cases';

  // Hearings
  static const String hearings = '/hearings';

  // Reminders
  static const String reminders = '/reminders';

  // Diary
  static const String diary = '/diary';

  // Courts directory
  static const String courts = '/directories/courts';

  // Police stations
  static const String policeStations = '/directories/police-stations';

  // Bar associations
  static const String barAssociations = '/directories/bar-associations';

  // Court calendar
  static const String holidays = '/calendar/holidays';
  static const String calendarCourts = '/calendar/courts';

  // Bare Acts
  static const String bareActs = '/library/bare-acts';

  // Draft templates
  static const String templates = '/library/templates';

  // Client-facing
  static const String advocates = '/advocates';
  static const String helpRequests = '/client/help-requests';
  static const String trackCase = '/track';
}
