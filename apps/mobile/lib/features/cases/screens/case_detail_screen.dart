import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/case_model.dart';
import '../../../core/providers/case_provider.dart';
import '../../../shared/widgets/common_widgets.dart';

class CaseDetailScreen extends StatelessWidget {
  final String caseId;
  const CaseDetailScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    final cases = context.watch<CaseProvider>().cases;
    final c = cases.where((x) => x.id == caseId).isNotEmpty
        ? cases.firstWhere((x) => x.id == caseId)
        : null;

    if (c == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Case Details')),
        body: const EmptyState(
          icon: Icons.folder_off_outlined,
          message: 'Case not found',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(c.caseNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/cases/${c.id}/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusChip(
                      label: c.status,
                      color: caseStatusColor(c.status)),
                  const SizedBox(height: 10),
                  Text(
                    c.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(c.caseType,
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Case info
            _section(context, 'Case Information', [
              _row(Icons.tag, 'Case Number', c.caseNumber),
              _row(Icons.category_outlined, 'Type', c.caseType),
              _row(Icons.layers_outlined, 'Stage', c.stage),
              _row(Icons.calendar_today_outlined, 'Filing Date', c.filingDate),
              if (c.nextHearingDate != null)
                _row(Icons.event_outlined, 'Next Hearing', c.nextHearingDate!,
                    highlight: true),
              if (c.courtName != null)
                _row(Icons.account_balance_outlined, 'Court', c.courtName!),
            ]),

            const SizedBox(height: 12),

            // Client info
            _section(context, 'Client Information', [
              _row(Icons.person_outline, 'Client', c.clientName),
              if (c.clientContact != null)
                _row(Icons.phone_outlined, 'Contact', c.clientContact!),
              if (c.oppositeParty != null)
                _row(Icons.people_outline, 'Opposite Party', c.oppositeParty!),
              if (c.oppositeAdvocate != null)
                _row(Icons.balance, 'Opposite Advocate', c.oppositeAdvocate!),
            ]),

            if (c.notes != null && c.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _section(context, 'Notes', [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(c.notes!,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textSecondary)),
                ),
              ]),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Hearing'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/reminders'),
                    icon: const Icon(Icons.alarm_add_outlined, size: 18),
                    label: const Text('Set Reminder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, String title, List<Widget> children) {
    return LegalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 18,
              color: highlight ? AppColors.info : AppColors.textSecondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 13,
                  color: highlight ? AppColors.info : AppColors.textSecondary,
                  fontWeight: highlight ? FontWeight.w600 : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}
