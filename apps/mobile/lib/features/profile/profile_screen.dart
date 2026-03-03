import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      (user?.fullName.isNotEmpty ?? false)
                          ? user!.fullName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                          fontSize: 42,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Advocate · ${user?.stateBarCouncil ?? ''}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _VerificationBadge(status: user?.verificationStatus ?? 'pending'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info section
            _infoCard(context, [
              _row(Icons.email_outlined, 'Email', user?.email ?? '-'),
              _row(Icons.phone_outlined, 'Mobile', user?.mobile ?? '-'),
              _row(Icons.badge_outlined, 'Bar Council ID',
                  user?.barCouncilId ?? '-'),
              _row(Icons.account_balance_outlined, 'State Bar Council',
                  user?.stateBarCouncil ?? '-'),
              _row(Icons.calendar_today_outlined, 'Enrollment Year',
                  user?.enrollmentYear ?? '-'),
              _row(Icons.person_outline, 'Role', user?.role ?? '-'),
            ]),
            const SizedBox(height: 16),

            // Options
            _menuItem(Icons.folder_outlined, 'My Cases', AppColors.primary,
                () => context.go('/cases')),
            _menuItem(Icons.alarm_outlined, 'My Reminders', AppColors.warning,
                () => context.go('/reminders')),
            _menuItem(Icons.book_outlined, 'My Diary', AppColors.info,
                () => context.go('/diary')),
            _menuItem(Icons.settings_outlined, 'Settings', AppColors.textSecondary,
                () {}),
            const SizedBox(height: 16),

            // Logout
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Logout',
                  style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: items),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final String status;
  const _VerificationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        color = AppColors.success;
        icon = Icons.verified;
        label = 'Verified Advocate';
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        label = 'Verification Failed';
        break;
      default:
        color = AppColors.warning;
        icon = Icons.pending_outlined;
        label = 'Verification Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
