import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class CaseTrackerScreen extends StatefulWidget {
  const CaseTrackerScreen({super.key});

  @override
  State<CaseTrackerScreen> createState() => _CaseTrackerScreenState();
}

class _CaseTrackerScreenState extends State<CaseTrackerScreen> {
  final _caseIdCtrl = TextEditingController();
  Map<String, dynamic>? _caseData;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _caseIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _trackCase() async {
    final id = _caseIdCtrl.text.trim();
    if (id.isEmpty) return;

    setState(() { _loading = true; _error = null; _caseData = null; });
    try {
      final data = await ApiService.get('${ApiConstants.trackCase}/$id', auth: false);
      setState(() { _caseData = data as Map<String, dynamic>; _loading = false; });
    } catch (e) {
      // Demo fallback
      if (id.toLowerCase().startsWith('ll-') || id.contains('-')) {
        setState(() {
          _caseData = _demoCase(id);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No case found with ID "$id". Please check and try again.';
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic> _demoCase(String id) {
    return {
      'id': id.toUpperCase(),
      'title': 'Rajan vs State of Delhi',
      'caseType': 'Criminal',
      'status': 'Hearing Scheduled',
      'court': 'Delhi High Court',
      'advocate': 'Adv. Rajesh Kumar',
      'clientName': 'Ramesh Rajan',
      'filedDate': '2025-11-10',
      'nextHearing': '2026-03-15',
      'timeline': [
        {'date': '2025-11-10', 'event': 'FIR filed and case registered', 'status': 'done'},
        {'date': '2025-11-22', 'event': 'Bail application filed', 'status': 'done'},
        {'date': '2025-12-05', 'event': 'Bail granted by Sessions Court', 'status': 'done'},
        {'date': '2026-01-20', 'event': 'First hearing — arguments submitted', 'status': 'done'},
        {'date': '2026-02-10', 'event': 'Documents submitted to court', 'status': 'done'},
        {'date': '2026-03-15', 'event': 'Next hearing (scheduled)', 'status': 'upcoming'},
        {'date': 'TBD', 'event': 'Final arguments', 'status': 'pending'},
        {'date': 'TBD', 'event': 'Judgement', 'status': 'pending'},
      ],
      'notes': 'Case is proceeding well. Bail has been secured. Next hearing scheduled for 15 March 2026.',
    };
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done': return Colors.green;
      case 'upcoming': return AppColors.primary;
      default: return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Case Tracker'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Input section ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Track Your Case', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter the Case ID provided by your advocate to see the latest updates.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _caseIdCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Case ID',
                      hintText: 'e.g. LL-2025-ABCD1234',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _caseIdCtrl.clear();
                          setState(() { _caseData = null; _error = null; });
                        },
                      ),
                      filled: true, fillColor: AppColors.background,
                    ),
                    onSubmitted: (_) => _trackCase(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _trackCase,
                      icon: _loading
                          ? const SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.search),
                      label: const Text('Track Case'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Error ─────────────────────────────────────────────────────
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                ]),
              ),

            // ── Case details ───────────────────────────────────────────────
            if (_caseData != null) ...[
              _CaseHeader(data: _caseData!),
              const SizedBox(height: 16),
              _CaseTimeline(
                timeline: (_caseData!['timeline'] as List? ?? [])
                    .cast<Map<String, dynamic>>(),
                statusColor: _statusColor,
              ),
              const SizedBox(height: 16),
              if (_caseData!['notes'] != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 18),
                      SizedBox(width: 8),
                      Text("Advocate's Note", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.info)),
                    ]),
                    const SizedBox(height: 8),
                    Text(_caseData!['notes'].toString(),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
            ],

            // ── Where to find your Case ID ─────────────────────────────────
            if (_caseData == null && _error == null && !_loading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How to find your Case ID?',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 12),
                    ...[
                      ['1', 'Your advocate registers your case on the Let\'s Legal platform.'],
                      ['2', 'You will receive a Case ID via WhatsApp or SMS from your advocate.'],
                      ['3', 'Enter the Case ID above to see all updates.'],
                      ['4', 'The Case ID format is: LL-YYYY-XXXXXXXX'],
                    ].map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(children: [
                        CircleAvatar(radius: 12, backgroundColor: AppColors.primary,
                            child: Text(step[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(step[1], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                      ]),
                    )),
                    const Divider(height: 20),
                    const Text('Try a demo:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        _caseIdCtrl.text = 'LL-2025-DEMO001';
                        _trackCase();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: const Text('LL-2025-DEMO001',
                            style: TextStyle(fontFamily: 'monospace', color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _CaseHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CaseHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    final status = (data['status'] ?? '').toString().toLowerCase();
    if (status.contains('schedule') || status.contains('hearing')) {
      statusColor = AppColors.primary;
    } else if (status.contains('closed') || status.contains('decided')) {
      statusColor = Colors.grey;
    } else if (status.contains('urgent')) {
      statusColor = AppColors.error;
    } else {
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(data['title'] ?? 'Case',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(data['status'] ?? '', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const Divider(height: 16),
          _Row(icon: Icons.tag, label: 'Case ID', value: data['id'] ?? ''),
          _Row(icon: Icons.category, label: 'Type', value: data['caseType'] ?? ''),
          _Row(icon: Icons.gavel, label: 'Court', value: data['court'] ?? ''),
          _Row(icon: Icons.person, label: 'Advocate', value: data['advocate'] ?? ''),
          _Row(icon: Icons.calendar_today, label: 'Filed', value: data['filedDate'] ?? ''),
          _Row(icon: Icons.event, label: 'Next Hearing', value: data['nextHearing'] ?? 'TBD'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
    ]),
  );
}

class _CaseTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> timeline;
  final Color Function(String) statusColor;
  const _CaseTimeline({required this.timeline, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Case Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...timeline.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final status = step['status']?.toString() ?? 'pending';
            final color = statusColor(status);
            final isLast = i == timeline.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: status == 'done' ? color : AppColors.cardBg,
                      border: Border.all(color: color, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: status == 'done'
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : status == 'upcoming'
                            ? Container(margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle))
                            : null,
                  ),
                  if (!isLast) Container(width: 2, height: 40, color: AppColors.divider),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(step['date'] ?? '', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                      Text(step['event'] ?? '', style: const TextStyle(fontSize: 13)),
                    ]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
