import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/cases/screens/cases_list_screen.dart';
import '../features/cases/screens/case_detail_screen.dart';
import '../features/cases/screens/add_case_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/directories/directories_screen.dart';
import '../features/calendar/court_calendar_screen.dart';
import '../features/library/library_screen.dart';
import '../features/profile/profile_screen.dart';
// Client screens
import '../features/client/home/client_home_screen.dart';
import '../features/client/advocates/find_advocate_screen.dart';
import '../features/client/cases/case_tracker_screen.dart';
import '../features/client/laws/laws_browser_screen.dart';
import '../features/client/profile/client_profile_screen.dart';
import '../features/client/help/help_request_screen.dart';

// ─── Advocate shell ───────────────────────────────────────────────────────────
class _AdvocateShell extends StatefulWidget {
  final Widget child;
  const _AdvocateShell({required this.child});

  @override
  State<_AdvocateShell> createState() => _AdvocateShellState();
}

class _AdvocateShellState extends State<_AdvocateShell> {
  int _currentIndex = 0;

  final _tabs = const [
    '/dashboard',
    '/cases',
    '/diary',
    '/reminders',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'Cases'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm_outlined), activeIcon: Icon(Icons.alarm), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Client shell ─────────────────────────────────────────────────────────────
class _ClientShell extends StatefulWidget {
  final Widget child;
  const _ClientShell({required this.child});

  @override
  State<_ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<_ClientShell> {
  int _currentIndex = 0;

  final _tabs = const [
    '/client/home',
    '/client/advocates',
    '/client/track',
    '/client/laws',
    '/client/profile',
  ];

  void _updateIndex(String location) {
    final idx = _tabs.indexWhere((t) => location.startsWith(t));
    if (idx >= 0 && idx != _currentIndex) setState(() => _currentIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    // Sync tab highlight with current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = GoRouterState.of(context).matchedLocation;
      _updateIndex(loc);
    });

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          context.go(_tabs[i]);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Advocates'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes_outlined), activeIcon: Icon(Icons.track_changes), label: 'Track Case'),
          BottomNavigationBarItem(icon: Icon(Icons.balance_outlined), activeIcon: Icon(Icons.balance), label: 'Laws'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Router ───────────────────────────────────────────────────────────────────
GoRouter buildRouter(AuthProvider auth) {
  final advocateShellKey = GlobalKey<NavigatorState>();
  final clientShellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final path = state.matchedLocation;
      final onAuth = path == '/login' || path == '/register';

      if (!loggedIn && !onAuth) return '/login';

      if (loggedIn && onAuth) {
        return auth.isClient ? '/client/home' : '/dashboard';
      }

      // Prevent clients accessing advocate routes
      if (loggedIn && auth.isClient && !path.startsWith('/client') && !onAuth) {
        return '/client/home';
      }

      // Prevent advocates accessing client routes
      if (loggedIn && auth.isAdvocate && path.startsWith('/client')) {
        return '/dashboard';
      }

      return null;
    },
    refreshListenable: auth,
    routes: [
      // ── Auth routes ──────────────────────────────────────────────────────
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // ── Advocate shell ───────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: advocateShellKey,
        builder: (_, __, child) => _AdvocateShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/cases',     builder: (_, __) => const CasesListScreen()),
          GoRoute(path: '/diary',     builder: (_, __) => const DiaryScreen()),
          GoRoute(path: '/reminders', builder: (_, __) => const RemindersScreen()),
          GoRoute(path: '/profile',   builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ── Client shell ─────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: clientShellKey,
        builder: (_, __, child) => _ClientShell(child: child),
        routes: [
          GoRoute(path: '/client/home',      builder: (_, __) => const ClientHomeScreen()),
          GoRoute(path: '/client/advocates', builder: (_, __) => const FindAdvocateScreen()),
          GoRoute(path: '/client/track',     builder: (_, __) => const CaseTrackerScreen()),
          GoRoute(path: '/client/laws',      builder: (_, __) => const LawsBrowserScreen()),
          GoRoute(path: '/client/profile',   builder: (_, __) => const ClientProfileScreen()),
        ],
      ),

      // ── Standalone routes (no shell bottom nav) ──────────────────────────
      GoRoute(path: '/client/calendar', builder: (_, __) => const CourtCalendarScreen()),
      GoRoute(path: '/client/help',     builder: (_, __) => const HelpRequestScreen()),
      GoRoute(path: '/cases/new',   builder: (_, __) => const AddCaseScreen()),
      GoRoute(
        path: '/cases/:id',
        builder: (_, state) => CaseDetailScreen(caseId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(path: '/courts',          builder: (_, __) => const CourtsDirectoryScreen()),
      GoRoute(path: '/bar-associations', builder: (_, __) => const BarAssociationsScreen()),
      GoRoute(path: '/court-calendar',  builder: (_, __) => const CourtCalendarScreen()),
      GoRoute(path: '/bare-acts',       builder: (_, __) => const BareActsScreen()),
      GoRoute(path: '/templates',       builder: (_, __) => const TemplatesScreen()),
    ],
  );
}

