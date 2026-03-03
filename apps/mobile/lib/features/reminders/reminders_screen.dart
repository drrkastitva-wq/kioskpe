import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/reminder_model.dart';
import '../../../core/providers/reminder_provider.dart';
import '../../../core/providers/case_provider.dart';
import '../../../shared/widgets/common_widgets.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().fetchReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rp = context.watch<ReminderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reminders)),
      body: rp.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rp.reminders.isEmpty
              ? const EmptyState(
                  icon: Icons.alarm_off_outlined,
                  message: 'No reminders yet',
                  subMessage: 'Add a reminder to stay on top of deadlines.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: rp.reminders.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (_, i) =>
                      _ReminderCard(reminder: rp.reminders[i]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(context),
        icon: const Icon(Icons.add_alarm),
        label: const Text(AppStrings.newReminder),
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddReminderSheet(),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(reminder.priority);
    return LegalCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.alarm_outlined, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 3),
                if (reminder.description != null &&
                    reminder.description!.isNotEmpty)
                  Text(reminder.description!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 13,
                        color: reminder.isOverdue
                            ? AppColors.error
                            : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(reminder.dueDate),
                      style: TextStyle(
                          fontSize: 12,
                          color: reminder.isOverdue
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: reminder.isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal),
                    ),
                    if (reminder.isOverdue) ...[
                      const SizedBox(width: 6),
                      const Text('OVERDUE',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              StatusChip(label: reminder.priority, color: color),
              const SizedBox(height: 8),
              if (reminder.status == 'pending')
                GestureDetector(
                  onTap: () =>
                      context.read<ReminderProvider>().markDone(reminder.id),
                  child: const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 24),
                )
              else
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt != null ? DateFormat('d MMM yyyy, HH:mm').format(dt) : d;
  }
}

class _AddReminderSheet extends StatefulWidget {
  const _AddReminderSheet();

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  DateTime? _dueDate;
  String? _linkedCaseId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and due date are required')));
      return;
    }
    final ok = await context.read<ReminderProvider>().addReminder({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'dueDate': _dueDate!.toIso8601String(),
      'priority': _priority,
      'status': 'pending',
      'caseId': _linkedCaseId,
    });
    if (!mounted) return;
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cases = context.watch<CaseProvider>().cases;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Reminder',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Title *',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ['low', 'medium', 'high', 'urgent']
                .map((p) => DropdownMenuItem(
                    value: p, child: Text(p.toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => _priority = v ?? 'medium'),
          ),
          const SizedBox(height: 14),
          if (cases.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _linkedCaseId,
              decoration: const InputDecoration(
                  labelText: 'Link to Case (optional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...cases.map((c) =>
                    DropdownMenuItem(value: c.id, child: Text(c.caseNumber))),
              ],
              onChanged: (v) => setState(() => _linkedCaseId = v),
            ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              final dt = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime(2035),
              );
              if (dt != null) setState(() => _dueDate = dt);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Due Date *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                _dueDate != null
                    ? DateFormat('d MMM yyyy').format(_dueDate!)
                    : 'Pick a date',
                style: TextStyle(
                    color: _dueDate != null
                        ? AppColors.textPrimary
                        : AppColors.textHint),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Save Reminder'),
          ),
        ],
      ),
    );
  }
}
