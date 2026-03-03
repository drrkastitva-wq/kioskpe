import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/case_provider.dart';

const List<String> _caseTypes = [
  'Civil', 'Criminal', 'Family', 'Labour', 'Consumer',
  'Constitutional', 'Revenue', 'Motor Accident', 'Arbitration', 'Other',
];

const List<String> _caseStages = [
  'Filing', 'Admission', 'Issues Framed', 'Evidence',
  'Arguments', 'Judgment Reserved', 'Decreed', 'Appeal', 'Execution',
];

const List<String> _caseStatuses = [
  'active', 'pending', 'urgent', 'closed',
];

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _caseNumberCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _clientContactCtrl = TextEditingController();
  final _courtCtrl = TextEditingController();
  final _oppositePartyCtrl = TextEditingController();
  final _oppositeAdvocateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedType;
  String? _selectedStage;
  String _selectedStatus = 'active';

  DateTime? _filingDate;
  DateTime? _nextHearingDate;

  @override
  void dispose() {
    for (final c in [
      _caseNumberCtrl, _titleCtrl, _clientNameCtrl, _clientContactCtrl,
      _courtCtrl, _oppositePartyCtrl, _oppositeAdvocateCtrl, _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool isHearing) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isHearing) {
          _nextHearingDate = picked;
        } else {
          _filingDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedStage == null || _filingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all required fields and pick Filing Date.')));
      return;
    }
    final ok = await context.read<CaseProvider>().addCase({
      'caseNumber': _caseNumberCtrl.text.trim(),
      'title': _titleCtrl.text.trim(),
      'caseType': _selectedType,
      'stage': _selectedStage,
      'status': _selectedStatus,
      'clientName': _clientNameCtrl.text.trim(),
      'clientContact': _clientContactCtrl.text.trim(),
      'courtName': _courtCtrl.text.trim(),
      'oppositeParty': _oppositePartyCtrl.text.trim(),
      'oppositeAdvocate': _oppositeAdvocateCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'filingDate': _filingDate?.toIso8601String(),
      'nextHearingDate': _nextHearingDate?.toIso8601String(),
    });

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Case enrolled successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CaseProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.newCase)),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionTitle(context, '1. Case Details'),
                const SizedBox(height: 12),
                _field(_caseNumberCtrl, 'Case Number *', Icons.tag,
                    hint: 'e.g. CS/123/2024'),
                const SizedBox(height: 14),
                _field(_titleCtrl, 'Case Title *', Icons.title),
                const SizedBox(height: 14),
                _dropdown('Case Type *', _caseTypes, _selectedType,
                    (v) => setState(() => _selectedType = v)),
                const SizedBox(height: 14),
                _dropdown('Stage *', _caseStages, _selectedStage,
                    (v) => setState(() => _selectedStage = v)),
                const SizedBox(height: 14),
                _dropdown('Status', _caseStatuses, _selectedStatus,
                    (v) => setState(() => _selectedStatus = v ?? 'active')),
                const SizedBox(height: 14),
                _datePicker('Filing Date *', _filingDate, false),
                const SizedBox(height: 14),
                _datePicker('Next Hearing Date', _nextHearingDate, true),
                const SizedBox(height: 22),

                _sectionTitle(context, '2. Court Details'),
                const SizedBox(height: 12),
                _field(_courtCtrl, 'Court Name', Icons.account_balance_outlined),
                const SizedBox(height: 22),

                _sectionTitle(context, '3. Client Details'),
                const SizedBox(height: 12),
                _field(_clientNameCtrl, 'Client Name *', Icons.person_outline),
                const SizedBox(height: 14),
                _field(_clientContactCtrl, 'Client Contact', Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 22),

                _sectionTitle(context, '4. Opposite Party'),
                const SizedBox(height: 12),
                _field(_oppositePartyCtrl, 'Opposite Party', Icons.people_outline),
                const SizedBox(height: 14),
                _field(_oppositeAdvocateCtrl, 'Opposite Advocate', Icons.balance),
                const SizedBox(height: 22),

                _sectionTitle(context, '5. Notes'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Case Notes',
                    alignLabelWithHint: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 54),
                      child: Icon(Icons.notes_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Enroll Case'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.primary, fontWeight: FontWeight.bold));
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? hint,
  }) {
    final required = label.endsWith('*');
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? AppStrings.required : null
          : null,
    );
  }

  Widget _dropdown(String label, List<String> items, String? value, ValueChanged<String?> onChange) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChange,
    );
  }

  Widget _datePicker(String label, DateTime? date, bool isHearing) {
    return InkWell(
      onTap: () => _pickDate(isHearing),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: TextStyle(
              color: date != null ? AppColors.textPrimary : AppColors.textHint),
        ),
      ),
    );
  }
}
