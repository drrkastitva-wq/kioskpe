import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/diary_entry_model.dart';
import '../../../core/providers/diary_provider.dart';
import '../../../core/providers/case_provider.dart';
import '../../../shared/widgets/common_widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiaryProvider>().fetchEntries();
    });
  }

  List<DiaryEntryModel> _entriesForDay(
      List<DiaryEntryModel> all, DateTime day) {
    return all.where((e) {
      final d = DateTime.tryParse(e.entryDate);
      return d != null && isSameDay(d, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dp = context.watch<DiaryProvider>();
    final dayEntries =
        _entriesForDay(dp.entries, _selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.diary)),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (f) => setState(() => _calendarFormat = f),
            eventLoader: (day) => _entriesForDay(dp.entries, day),
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppColors.accent, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              formatButtonTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          const Divider(height: 1),

          // Entries for selected day
          Expanded(
            child: dp.isLoading
                ? const Center(child: CircularProgressIndicator())
                : dayEntries.isEmpty
                    ? EmptyState(
                        icon: Icons.book_outlined,
                        message:
                            'No entries for ${DateFormat('d MMM').format(_selectedDay ?? DateTime.now())}',
                        subMessage: 'Tap + to add a diary entry.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayEntries.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) =>
                            _DiaryEntryCard(entry: dayEntries[i]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntrySheet(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addEntry),
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddDiaryEntrySheet(selectedDate: _selectedDay ?? DateTime.now()),
    );
  }
}

class _DiaryEntryCard extends StatelessWidget {
  final DiaryEntryModel entry;
  const _DiaryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final typeColors = {
      'hearing': AppColors.primary,
      'meeting': AppColors.info,
      'call': AppColors.success,
      'task': AppColors.warning,
      'note': AppColors.textSecondary,
    };
    final color =
        typeColors[entry.entryType?.toLowerCase() ?? ''] ?? AppColors.textSecondary;

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
            child: Icon(_typeIcon(entry.entryType), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    if (entry.entryType != null)
                      StatusChip(
                          label: entry.entryType!, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(entry.description,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                if (entry.linkedCaseTitle != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.link,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(entry.linkedCaseTitle!,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'hearing': return Icons.gavel_outlined;
      case 'meeting': return Icons.people_outline;
      case 'call': return Icons.phone_outlined;
      case 'task': return Icons.check_circle_outline;
      default: return Icons.note_outlined;
    }
  }
}

class _AddDiaryEntrySheet extends StatefulWidget {
  final DateTime selectedDate;
  const _AddDiaryEntrySheet({required this.selectedDate});

  @override
  State<_AddDiaryEntrySheet> createState() => _AddDiaryEntrySheetState();
}

class _AddDiaryEntrySheetState extends State<_AddDiaryEntrySheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _entryType = 'note';
  String? _linkedCaseId;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty) return;
    final ok = await context.read<DiaryProvider>().addEntry({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'entryDate': widget.selectedDate.toIso8601String(),
      'entryType': _entryType,
      'linkedCaseId': _linkedCaseId,
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
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.divider,
                borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text('Add Diary Entry',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(widget.selectedDate),
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _entryType,
            decoration: const InputDecoration(labelText: 'Entry Type'),
            items: ['note', 'hearing', 'meeting', 'call', 'task']
                .map((t) => DropdownMenuItem(
                    value: t, child: Text(t.toUpperCase())))
                .toList(),
            onChanged: (v) => setState(() => _entryType = v ?? 'note'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title)),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 38),
                child: Icon(Icons.notes_outlined),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (cases.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _linkedCaseId,
              decoration: const InputDecoration(
                  labelText: 'Link to Case (optional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...cases.map((c) => DropdownMenuItem(
                    value: c.id, child: Text(c.caseNumber))),
              ],
              onChanged: (v) => setState(() => _linkedCaseId = v),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _submit,
              child: const Text('Save Entry')),
        ],
      ),
    );
  }
}
