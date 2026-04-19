import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/common_widgets.dart';

// ─── Bare Acts Library ────────────────────────────────────────────────────────

class BareActsScreen extends StatefulWidget {
  const BareActsScreen({super.key});

  @override
  State<BareActsScreen> createState() => _BareActsScreenState();
}

class _BareActsScreenState extends State<BareActsScreen> {
  List<Map<String, dynamic>> _acts = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  // Offline fallback data for common Bare Acts
  final List<Map<String, dynamic>> _offlineActs = [
    {'title': 'Constitution of India', 'year': '1950', 'category': 'Constitutional'},
    {'title': 'Indian Penal Code', 'year': '1860', 'category': 'Criminal'},
    {'title': 'Code of Criminal Procedure', 'year': '1973', 'category': 'Procedural'},
    {'title': 'Indian Evidence Act', 'year': '1872', 'category': 'Evidence'},
    {'title': 'Code of Civil Procedure', 'year': '1908', 'category': 'Civil'},
    {'title': 'Transfer of Property Act', 'year': '1882', 'category': 'Property'},
    {'title': 'Indian Contract Act', 'year': '1872', 'category': 'Contract'},
    {'title': 'Negotiable Instruments Act', 'year': '1881', 'category': 'Commercial'},
    {'title': 'Motor Vehicles Act', 'year': '1988', 'category': 'Transport'},
    {'title': 'Consumer Protection Act', 'year': '2019', 'category': 'Consumer'},
    {'title': 'Right to Information Act', 'year': '2005', 'category': 'Administrative'},
    {'title': 'Arbitration and Conciliation Act', 'year': '1996', 'category': 'Arbitration'},
    {'title': 'Specific Relief Act', 'year': '1963', 'category': 'Civil'},
    {'title': 'Limitation Act', 'year': '1963', 'category': 'Civil'},
    {'title': 'Income Tax Act', 'year': '1961', 'category': 'Taxation'},
    {'title': 'Goods and Services Tax Act', 'year': '2017', 'category': 'Taxation'},
    {'title': 'Companies Act', 'year': '2013', 'category': 'Corporate'},
    {'title': 'Prevention of Corruption Act', 'year': '1988', 'category': 'Criminal'},
    {'title': 'Information Technology Act', 'year': '2000', 'category': 'Cyber'},
    {'title': 'Bharatiya Nyaya Sanhita', 'year': '2023', 'category': 'Criminal'},
    {'title': 'Bharatiya Nagarik Suraksha Sanhita', 'year': '2023', 'category': 'Procedural'},
    {'title': 'Bharatiya Sakshya Adhiniyam', 'year': '2023', 'category': 'Evidence'},
    {'title': 'Hindu Marriage Act', 'year': '1955', 'category': 'Family'},
    {'title': 'Hindu Succession Act', 'year': '1956', 'category': 'Family'},
    {'title': 'Special Marriage Act', 'year': '1954', 'category': 'Family'},
    {'title': 'Muslim Personal Law (Shariat) Application Act', 'year': '1937', 'category': 'Family'},
    {'title': 'Protection of Women from Domestic Violence Act', 'year': '2005', 'category': 'Family'},
    {'title': 'Protection of Children from Sexual Offences Act', 'year': '2012', 'category': 'Criminal'},
    {'title': 'Indian Succession Act', 'year': '1925', 'category': 'Civil'},
    {'title': 'Indian Trusts Act', 'year': '1882', 'category': 'Civil'},
    {'title': 'Indian Partnership Act', 'year': '1932', 'category': 'Commercial'},
    {'title': 'Family Courts Act', 'year': '1984', 'category': 'Family'},
    {'title': 'Guardians and Wards Act', 'year': '1890', 'category': 'Family'},
    {'title': 'Juvenile Justice Act', 'year': '2015', 'category': 'Social'},
    {'title': 'Right of Children to Free and Compulsory Education Act', 'year': '2009', 'category': 'Social'},
    {'title': 'Environment Protection Act', 'year': '1986', 'category': 'Environment'},
    {'title': 'Wildlife Protection Act', 'year': '1972', 'category': 'Environment'},
    {'title': 'Factories Act', 'year': '1948', 'category': 'Labour'},
    {'title': 'Payment of Wages Act', 'year': '1936', 'category': 'Labour'},
    {'title': 'Minimum Wages Act', 'year': '1948', 'category': 'Labour'},
    {'title': 'Industrial Disputes Act', 'year': '1947', 'category': 'Labour'},
    {'title': 'Employees’ Provident Funds and Miscellaneous Provisions Act', 'year': '1952', 'category': 'Labour'},
    {'title': 'Payment of Gratuity Act', 'year': '1972', 'category': 'Labour'},
    {'title': 'Banking Regulation Act', 'year': '1949', 'category': 'Financial'},
    {'title': 'Foreign Exchange Management Act', 'year': '1999', 'category': 'Financial'},
    {'title': 'Prevention of Money Laundering Act', 'year': '2002', 'category': 'Financial'},
    {'title': 'Insolvency and Bankruptcy Code', 'year': '2016', 'category': 'Financial'},
    {'title': 'Competition Act', 'year': '2002', 'category': 'Corporate'},
    {'title': 'Copyright Act', 'year': '1957', 'category': 'Intellectual Property'},
    {'title': 'Patents Act', 'year': '1970', 'category': 'Intellectual Property'},
    {'title': 'Trade Marks Act', 'year': '1999', 'category': 'Intellectual Property'},
    {'title': 'Foreign Contribution (Regulation) Act', 'year': '2010', 'category': 'Social'},
    {'title': 'National Food Security Act', 'year': '2013', 'category': 'Social'},
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = _acts.where((a) =>
          (a['title']?.toString().toLowerCase().contains(q) ?? false) ||
          (a['category']?.toString().toLowerCase().contains(q) ?? false)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.get(ApiConstants.bareActs);
      final list = (data['acts'] ?? data['data'] ?? []) as List;
      if (list.isNotEmpty) {
        setState(() {
          _acts = list.cast<Map<String, dynamic>>();
          _filtered = _acts;
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    // Fallback to offline list
    setState(() {
      _acts = _offlineActs;
      _filtered = _offlineActs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bare Acts Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search acts...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.menu_book_outlined, message: 'No acts found')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) {
                          final act = _filtered[i];
                          return LegalCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.menu_book_outlined,
                                      color: AppColors.primaryLight, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(act['title']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          StatusChip(
                                            label: act['category']?.toString() ?? '',
                                            color: AppColors.info,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(act['year']?.toString() ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textHint),
                              ],
                            ),
                          );
                        }),
          ),
        ],
      ),
    );
  }
}

// ─── Draft Templates ──────────────────────────────────────────────────────────

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _offlineTemplates = [
    {'title': 'Bail Application', 'category': 'Criminal', 'desc': 'Standard bail application under Sec 437/439 CrPC / BNSS'},
    {'title': 'Anticipatory Bail Application', 'category': 'Criminal', 'desc': 'Pre-arrest bail application'},
    {'title': 'Vakalatnama', 'category': 'General', 'desc': 'Standard Vakalatnama format'},
    {'title': 'Legal Notice', 'category': 'General', 'desc': 'General legal notice for disputes'},
    {'title': 'Plaint (Civil Suit)', 'category': 'Civil', 'desc': 'Standard plaint for civil suit under CPC'},
    {'title': 'Written Statement', 'category': 'Civil', 'desc': 'Defendant written statement'},
    {'title': 'Affidavit', 'category': 'General', 'desc': 'General affidavit format'},
    {'title': 'Complaint under Section 12 DV Act', 'category': 'Family', 'desc': 'Domestic violence complaint'},
    {'title': 'Divorce Petition (Mutual Consent)', 'category': 'Family', 'desc': 'Under Sec 13-B Hindu Marriage Act'},
    {'title': 'Consumer Complaint', 'category': 'Consumer', 'desc': 'Complaint to consumer forum'},
    {'title': 'RTI Application', 'category': 'Administrative', 'desc': 'Right to Information application'},
    {'title': 'Appeal (High Court)', 'category': 'Criminal', 'desc': 'Criminal appeal to High Court'},
    {'title': 'Motor Accident Claim Petition', 'category': 'Motor Accident', 'desc': 'MACT claim petition'},
    {'title': 'Stay Application', 'category': 'Civil', 'desc': 'Application for stay/injunction'},
    {'title': 'Condonation of Delay Application', 'category': 'General', 'desc': 'Under Sec 5 Limitation Act'},
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = _templates.where((t) =>
          (t['title']?.toString().toLowerCase().contains(q) ?? false) ||
          (t['category']?.toString().toLowerCase().contains(q) ?? false)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.get(ApiConstants.templates);
      final list = (data['templates'] ?? data['data'] ?? []) as List;
      if (list.isNotEmpty) {
        setState(() {
          _templates = list.cast<Map<String, dynamic>>();
          _filtered = _templates;
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() {
      _templates = _offlineTemplates;
      _filtered = _offlineTemplates;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draft Templates')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.description_outlined,
                        message: 'No templates found')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) {
                          final t = _filtered[i];
                          return LegalCard(
                            onTap: () => _previewTemplate(context, t),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.description_outlined,
                                      color: AppColors.accentDark, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t['title']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(t['desc']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary),
                                          maxLines: 2),
                                      const SizedBox(height: 4),
                                      StatusChip(
                                        label: t['category']?.toString() ?? '',
                                        color: AppColors.primaryLight,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textHint),
                              ],
                            ),
                          );
                        }),
          ),
        ],
      ),
    );
  }

  void _previewTemplate(BuildContext context, Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: ctrl,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(t['title']?.toString() ?? '',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              StatusChip(
                  label: t['category']?.toString() ?? '',
                  color: AppColors.primaryLight),
              const SizedBox(height: 16),
              const Text(
                'IN THE HON\'BLE COURT OF _______________\n'
                'AT _______________\n\n'
                '________________________ ...... Petitioner/Applicant\n'
                'VERSUS\n'
                '________________________ ...... Respondent/Opposite Party\n\n'
                'APPLICATION FOR ________________________\n\n'
                'MOST RESPECTFULLY SHOWETH:\n\n'
                '1. That the Petitioner/Applicant is _________________________\n\n'
                '2. That _______________________________________________\n\n'
                '3. That _______________________________________________\n\n'
                'PRAYER:\n\n'
                'It is, therefore, most respectfully prayed that this Hon\'ble Court may '
                'be pleased to ___________________________________________\n\n'
                'And for this act of kindness the Petitioner/Applicant shall ever pray.\n\n'
                'Place: _______________\n'
                'Date:  _______________\n\n'
                '(Advocate for Petitioner)',
                style: TextStyle(fontSize: 13, height: 1.8),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy),
                label: const Text('Copy Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
