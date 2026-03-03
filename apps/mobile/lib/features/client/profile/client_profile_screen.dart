import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // ── Avatar header ─────────────────────────────────────────
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: Column(children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.fullName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Citizen / Client',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),

                // ── Info ──────────────────────────────────────────────────
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    _InfoRow(icon: Icons.badge_outlined, label: 'Full Name', value: user.fullName),
                    _InfoRow(icon: Icons.email_outlined, label: 'Email', value: user.email),
                    if (user.mobile.isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, label: 'Mobile', value: user.mobile),
                    if ((user.city ?? '').isNotEmpty)
                      _InfoRow(icon: Icons.location_city_outlined, label: 'City', value: user.city!),
                    if ((user.state ?? '').isNotEmpty)
                      _InfoRow(icon: Icons.map_outlined, label: 'State', value: user.state!),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Quick links ───────────────────────────────────────────
                _SectionCard(
                  title: 'Quick Actions',
                  icon: Icons.flash_on_outlined,
                  children: [
                    _ActionTile(icon: Icons.search, label: 'Find an Advocate',
                        color: const Color(0xFF1565C0), onTap: () => context.go('/client/advocates')),
                    _ActionTile(icon: Icons.track_changes, label: 'Track My Case',
                        color: const Color(0xFF00695C), onTap: () => context.go('/client/track')),
                    _ActionTile(icon: Icons.balance, label: 'Browse Laws & Acts',
                        color: const Color(0xFF4A148C), onTap: () => context.go('/client/laws')),
                    _ActionTile(icon: Icons.support_agent, label: 'Request Legal Help',
                        color: AppColors.primary, onTap: () => context.push('/client/help')),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Emergency contacts ─────────────────────────────────────
                _SectionCard(
                  title: 'Emergency Contacts',
                  icon: Icons.emergency_outlined,
                  children: [
                    _EmergencyTile(label: 'NALSA Legal Aid', number: '15100'),
                    _EmergencyTile(label: 'Women Helpline', number: '181'),
                    _EmergencyTile(label: 'Police Control Room', number: '100'),
                    _EmergencyTile(label: 'Child Helpline', number: '1098'),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Account actions ───────────────────────────────────────
                _SectionCard(
                  title: 'Account',
                  icon: Icons.settings_outlined,
                  children: [
                    _ActionTile(
                      icon: Icons.logout,
                      label: 'Logout',
                      color: AppColors.error,
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout?'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                child: const Text('Logout', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Center(
                  child: Text("Let's Legal — Justice for All",
                      style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
          ]),
        ),
        const Divider(height: 0),
        ...children,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  final String label;
  final String number;
  const _EmergencyTile({required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.call, color: AppColors.error, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(number, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.error)),
    );
  }
}
