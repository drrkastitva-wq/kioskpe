import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/case_provider.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/models/case_model.dart';
import '../../../core/models/reminder_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseProvider>().fetchCases();
      context.read<ReminderProvider>().fetchReminders();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cases = context.watch<CaseProvider>();
    final reminders = context.watch<ReminderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_greeting()},',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Adv. ${auth.user?.fullName.split(' ').first ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.accent,
                                child: Text(
                                  (auth.user?.fullName.isNotEmpty ?? false)
                                      ? auth.user!.fullName[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                          style: const TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => context.push('/reminders'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification warning banner
                  if (auth.user?.verificationStatus == 'pending')
                    _verificationBanner(context),

                  // Stats row
                  _statsRow(context, cases, reminders),
                  const SizedBox(height: 20),

                  // Quick actions
                  _quickActions(context),
                  const SizedBox(height: 20),

                  // Today's hearings
                  SectionHeader(
                    title: AppStrings.todayHearings,
                    actionLabel: 'All Cases',
                    onAction: () => context.go('/cases'),
                  ),
                  const SizedBox(height: 8),
                  _todayHearings(cases),
                  const SizedBox(height: 20),

                  // Pending reminders
                  SectionHeader(
                    title: AppStrings.pendingTasks,
                    actionLabel: 'All',
                    onAction: () => context.go('/reminders'),
                  ),
                  const SizedBox(height: 8),
                  _pendingReminders(reminders),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_outlined, color: AppColors.warning),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your Bar Council ID is under verification. Some features may be restricted.',
              style: TextStyle(fontSize: 13, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context, CaseProvider cases, ReminderProvider reminders) {
    return Row(
      children: [
        _statCard('Active Cases', cases.activeCases.length.toString(),
            Icons.folder_open_outlined, AppColors.primary),
        const SizedBox(width: 12),
        _statCard("Today's Hearings", cases.todayHearings.length.toString(),
            Icons.gavel_outlined, AppColors.info),
        const SizedBox(width: 12),
        _statCard('Reminders', reminders.pendingReminders.length.toString(),
            Icons.alarm_outlined, AppColors.warning),
        const SizedBox(width: 12),
        _statCard('Overdue', reminders.overdueReminders.length.toString(),
            Icons.warning_amber_outlined, AppColors.error),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      _QuickAction(
          Icons.add_circle_outline, 'New Case', AppColors.primary, '/cases/new'),
      _QuickAction(
          Icons.alarm_add_outlined, 'Reminder', AppColors.warning, '/reminders'),
      _QuickAction(
          Icons.book_outlined, 'Diary', AppColors.info, '/diary'),
      _QuickAction(
          Icons.account_balance_outlined, 'Courts', AppColors.success, '/courts'),
      _QuickAction(
          Icons.description_outlined, 'Templates', AppColors.primaryLight, '/templates'),
      _QuickAction(
          Icons.menu_book_outlined, 'Bare Acts', AppColors.accentDark, '/bare-acts'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (_, i) {
            final a = actions[i];
            return GestureDetector(
              onTap: () => context.push(a.route),
              child: Container(
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: a.color.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.icon, color: a.color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: a.color),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _todayHearings(CaseProvider cases) {
    if (cases.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final hearings = cases.todayHearings;
    if (hearings.isEmpty) {
      return const EmptyState(
        icon: Icons.gavel_outlined,
        message: 'No hearings today',
        subMessage: 'Enjoy a quiet day in chambers.',
      );
    }
    return Column(
      children: hearings.take(3).map((c) => _hearingCard(c)).toList(),
    );
  }

  Widget _hearingCard(CaseModel c) {
    return LegalCard(
      onTap: () => context.push('/cases/${c.id}'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gavel_outlined,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(c.caseNumber,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                if (c.courtName != null)
                  Text(c.courtName!,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
          StatusChip(
              label: c.status, color: caseStatusColor(c.status)),
        ],
      ),
    );
  }

  Widget _pendingReminders(ReminderProvider reminders) {
    if (reminders.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final pending = reminders.pendingReminders.take(3).toList();
    if (pending.isEmpty) {
      return const EmptyState(
        icon: Icons.alarm_outlined,
        message: 'No pending reminders',
      );
    }
    return Column(
      children: pending.map((r) => _reminderCard(r)).toList(),
    );
  }

  Widget _reminderCard(ReminderModel r) {
    final color = priorityColor(r.priority);
    return LegalCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.alarm_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  'Due: ${_formatDate(r.dueDate)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: r.isOverdue ? AppColors.error : AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(label: r.priority, color: color),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    return DateFormat('d MMM').format(d);
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _QuickAction(this.icon, this.label, this.color, this.route);
}
