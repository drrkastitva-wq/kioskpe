import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class FindAdvocateScreen extends StatefulWidget {
  const FindAdvocateScreen({super.key});

  @override
  State<FindAdvocateScreen> createState() => _FindAdvocateScreenState();
}

class _FindAdvocateScreenState extends State<FindAdvocateScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCourt;
  String? _selectedArea;
  List<Map<String, dynamic>> _advocates = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = false;
  String? _error;

  static const _courts = [
    'Supreme Court', 'Delhi High Court', 'Bombay High Court', 'Calcutta High Court',
    'Madras High Court', 'Allahabad High Court', 'District Court', 'Sessions Court',
    'Family Court', 'Consumer Forum', 'Tribunal',
  ];

  static const _areas = [
    'Criminal Law', 'Civil Law', 'Family Law', 'Property Law',
    'Corporate Law', 'Consumer Law', 'Labour Law', 'Tax Law',
    'Constitutional Law', 'Cyber Law',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAdvocates();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAdvocates() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.get(ApiConstants.advocates);
      final list = data['advocates'] as List? ?? <dynamic>[];
      setState(() {
        _advocates = list.map((e) => e as Map<String, dynamic>).toList();
        _filtered = List.from(_advocates);
        _loading = false;
      });
    } catch (_) {
      // Fallback to offline seed data
      setState(() {
        _advocates = _offlineAdvocates;
        _filtered = List.from(_offlineAdvocates);
        _loading = false;
        _error = null;
      });
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _advocates.where((a) {
        final name = (a['fullName'] ?? '').toString().toLowerCase();
        final court = (a['courtPreference'] ?? '').toString().toLowerCase();
        final specs = (a['specializations'] as List? ?? []).join(' ').toLowerCase();
        final matchQ = q.isEmpty || name.contains(q) || court.contains(q) || specs.contains(q);
        final matchCourt = _selectedCourt == null ||
            (a['courtPreference'] ?? '').toString().contains(_selectedCourt!);
        final matchArea = _selectedArea == null ||
            (a['specializations'] as List? ?? []).any((s) => s.toString().contains(_selectedArea!));
        return matchQ && matchCourt && matchArea;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find an Advocate'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Search + filters ────────────────────────────────────────────
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, court, or specialization…',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true, fillColor: Colors.white.withOpacity(0.12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _FilterDropdown(
                      hint: 'Court',
                      value: _selectedCourt,
                      items: _courts,
                      onChanged: (v) {
                        setState(() => _selectedCourt = v);
                        _applyFilters();
                      },
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _FilterDropdown(
                      hint: 'Practice Area',
                      value: _selectedArea,
                      items: _areas,
                      onChanged: (v) {
                        setState(() => _selectedArea = v);
                        _applyFilters();
                      },
                    )),
                    if (_selectedCourt != null || _selectedArea != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          setState(() { _selectedCourt = null; _selectedArea = null; });
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: AppColors.textHint),
                            SizedBox(height: 12),
                            Text('No advocates found', style: TextStyle(color: AppColors.textSecondary)),
                            Text('Try adjusting your filters', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchAdvocates,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _AdvocateCard(advocate: _filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Advocate card ─────────────────────────────────────────────────────────────

class _AdvocateCard extends StatelessWidget {
  final Map<String, dynamic> advocate;
  const _AdvocateCard({required this.advocate});

  @override
  Widget build(BuildContext context) {
    final specs = (advocate['specializations'] as List? ?? []).cast<String>();
    final isVerified = advocate['verificationStatus'] == 'approved';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    (advocate['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(
                          advocate['fullName'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        )),
                        if (isVerified)
                          const Tooltip(
                            message: 'Verified by Bar Council',
                            child: Icon(Icons.verified, color: Colors.blue, size: 18),
                          ),
                      ]),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.gavel, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(child: Text(
                          advocate['courtPreference'] ?? 'Not specified',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        )),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: specs.take(4).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showProfile(context),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendRequest(context),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Contact'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AdvocateProfileSheet(advocate: advocate),
    );
  }

  void _sendRequest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request sent to ${advocate['fullName']}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _AdvocateProfileSheet extends StatelessWidget {
  final Map<String, dynamic> advocate;
  const _AdvocateProfileSheet({required this.advocate});

  @override
  Widget build(BuildContext context) {
    final specs = (advocate['specializations'] as List? ?? []).cast<String>();
    return DraggableScrollableSheet(
      initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Center(child: CircleAvatar(
            radius: 36, backgroundColor: AppColors.primary.withOpacity(0.12),
            child: Text((advocate['fullName'] ?? '?').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.primary)),
          )),
          const SizedBox(height: 12),
          Center(child: Text(advocate['fullName'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
          if (advocate['verificationStatus'] == 'approved')
            const Center(child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text('Bar Council Verified', style: TextStyle(color: Colors.blue, fontSize: 12)),
              ]),
            )),
          const Divider(height: 28),
          _ProfileRow(icon: Icons.gavel, label: 'Court', value: advocate['courtPreference'] ?? 'N/A'),
          _ProfileRow(icon: Icons.badge, label: 'Bar Council ID', value: advocate['barCouncilId'] ?? 'N/A'),
          _ProfileRow(icon: Icons.email, label: 'Email', value: advocate['email'] ?? 'N/A'),
          _ProfileRow(icon: Icons.phone, label: 'Mobile', value: advocate['mobile'] ?? 'N/A'),
          if (specs.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Practice Areas', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6,
                children: specs.map((s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                )).toList()),
          ],
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request sent to ${advocate['fullName']}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Send Legal Help Request'),
          )),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      ]),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({required this.hint, required this.value,
      required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: AppColors.primary,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
        onChanged: onChanged,
        items: [
          DropdownMenuItem(value: null, child: Text('All $hint',
              style: const TextStyle(color: Colors.white70))),
          ...items.map((i) => DropdownMenuItem(value: i, child: Text(i))),
        ],
      ),
    );
  }
}

// ─── Offline seed data ─────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _offlineAdvocates = [
  {
    'id': 'test-user-001', 'fullName': 'Adv. Rajesh Kumar',
    'email': 'test@letslegal.in', 'mobile': '9876543210',
    'courtPreference': 'Delhi High Court',
    'specializations': ['Criminal Law', 'Civil Law', 'Family Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-DL-2018-12345',
  },
  {
    'id': 'adv-002', 'fullName': 'Adv. Priya Sharma',
    'email': 'priya@example.com', 'mobile': '9988776655',
    'courtPreference': 'Supreme Court of India',
    'specializations': ['Constitutional Law', 'Cyber Law', 'Corporate Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-SC-2015-07890',
  },
  {
    'id': 'adv-003', 'fullName': 'Adv. Arun Gupta',
    'email': 'arun@example.com', 'mobile': '8877665544',
    'courtPreference': 'Bombay High Court',
    'specializations': ['Property Law', 'Tax Law', 'Consumer Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-MH-2016-34567',
  },
  {
    'id': 'adv-004', 'fullName': 'Adv. Sunita Rao',
    'email': 'sunita@example.com', 'mobile': '7766554433',
    'courtPreference': 'Family Court',
    'specializations': ['Family Law', 'Labour Law', 'Criminal Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-KA-2019-56789',
  },
  {
    'id': 'adv-005', 'fullName': 'Adv. Mohan Das',
    'email': 'mohan@example.com', 'mobile': '6655443322',
    'courtPreference': 'Allahabad High Court',
    'specializations': ['Civil Law', 'Environmental Law', 'Property Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-UP-2017-23456',
  },
  {
    'id': 'adv-006', 'fullName': 'Adv. Fatima Khan',
    'email': 'fatima@example.com', 'mobile': '9900112233',
    'courtPreference': 'District Court',
    'specializations': ['Criminal Law', 'Consumer Law', 'Immigration Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-DL-2020-78901',
  },
  {
    'id': 'adv-007', 'fullName': 'Adv. Vikram Mehta',
    'email': 'vikram@example.com', 'mobile': '8800991122',
    'courtPreference': 'Sessions Court',
    'specializations': ['Criminal Law', 'Cyber Law', 'Banking Law'],
    'verificationStatus': 'approved', 'barCouncilId': 'BCI-GJ-2014-45678',
  },
];
