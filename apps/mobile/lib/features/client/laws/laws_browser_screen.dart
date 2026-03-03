import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LawsBrowserScreen extends StatefulWidget {
  const LawsBrowserScreen({super.key});

  @override
  State<LawsBrowserScreen> createState() => _LawsBrowserScreenState();
}

class _LawsBrowserScreenState extends State<LawsBrowserScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';

  static const List<Map<String, dynamic>> _laws = [
    // Constitutional
    {'title': 'Constitution of India', 'year': '1950', 'category': 'Constitutional',
     'summary': 'The supreme law of India, establishing the framework of government and fundamental rights.',
     'keySections': ['Part III – Fundamental Rights', 'Part IV – Directive Principles', 'Article 19 – Freedom of speech', 'Article 21 – Right to life']},
    {'title': 'Right to Information Act', 'year': '2005', 'category': 'Constitutional',
     'summary': 'Empowers citizens to request information from public authorities within 30 days.',
     'keySections': ['Section 3 – Right to information', 'Section 6 – Filing RTI request', 'Section 20 – Penalties for PIO']},
    // Criminal
    {'title': 'Bharatiya Nyaya Sanhita (BNS)', 'year': '2023', 'category': 'Criminal',
     'summary': 'Replaced the Indian Penal Code, 1860. Defines crimes and punishments in India.',
     'keySections': ['Section 103 – Murder', 'Section 115 – Grievous hurt', 'Section 316 – Cheating', 'Section 351 – Criminal intimidation']},
    {'title': 'Bharatiya Nagarik Suraksha Sanhita (BNSS)', 'year': '2023', 'category': 'Criminal',
     'summary': 'Replaced CrPC, 1973. Governs criminal procedure including FIR, bail, and trial processes.',
     'keySections': ['Section 173 – FIR', 'Section 479 – Bail conditions', 'Section 35 – Arrest without warrant']},
    {'title': 'Indian Evidence Act / Bharatiya Sakshya Adhiniyam', 'year': '2023', 'category': 'Criminal',
     'summary': 'Governs admissibility of evidence in Indian courts.',
     'keySections': ['Section 65B – Electronic evidence', 'Section 45 – Expert opinion', 'Section 25 – Confession to police']},
    {'title': 'Prevention of Corruption Act', 'year': '1988', 'category': 'Criminal',
     'summary': 'Penalises corruption by public servants and bribery.',
     'keySections': ['Section 7 – Taking gratification', 'Section 13 – Criminal misconduct', 'Section 19 – Sanction for prosecution']},
    // Civil
    {'title': 'Code of Civil Procedure (CPC)', 'year': '1908', 'category': 'Civil',
     'summary': 'Governs procedure for civil courts; suits, appeals, and execution of decrees.',
     'keySections': ['Order 1 – Parties to suits', 'Order 39 – Temporary injunctions', 'Order 47 – Review of judgements']},
    {'title': 'Limitation Act', 'year': '1963', 'category': 'Civil',
     'summary': 'Specifies time limits within which legal actions must be filed.',
     'keySections': ['Section 3 – Dismissal of time-barred suits', 'Article 54 – Specific performance (3 years)', 'Article 65 – Property suits (12 years)']},
    {'title': 'Specific Relief Act', 'year': '1963', 'category': 'Civil',
     'summary': 'Provides for specific performance of contracts and injunctions as civil remedies.',
     'keySections': ['Section 10 – Specific performance of contracts', 'Section 37 – Temporary injunctions', 'Section 41 – Perpetual injunctions']},
    // Family
    {'title': 'Hindu Marriage Act', 'year': '1955', 'category': 'Family',
     'summary': 'Governs marriage, divorce, and matrimonial rights for Hindus.',
     'keySections': ['Section 5 – Conditions for marriage', 'Section 13 – Divorce grounds', 'Section 25 – Permanent alimony', 'Section 26 – Custody of children']},
    {'title': 'Protection of Women from Domestic Violence Act', 'year': '2005', 'category': 'Family',
     'summary': 'Provides civil remedies to women against domestic violence.',
     'keySections': ['Section 12 – Application to Magistrate', 'Section 18 – Protection orders', 'Section 22 – Compensation orders']},
    {'title': 'Hindu Succession Act', 'year': '1956', 'category': 'Family',
     'summary': 'Governs inheritance and succession of property for Hindus, including daughters\' rights (2005 amendment).',
     'keySections': ['Section 6 – Coparcenary (daughters equal share)', 'Section 8 – General rules of succession', 'Section 14 – Property of female Hindu']},
    {'title': 'Special Marriage Act', 'year': '1954', 'category': 'Family',
     'summary': 'Inter-religion and civil marriage law, not dependent on religious affiliation.',
     'keySections': ['Section 4 – Conditions for special marriage', 'Section 27 – Divorce by mutual consent', 'Section 36 – Alimony pendente lite']},
    {'title': 'Muslim Personal Law (Shariat) Application Act', 'year': '1937', 'category': 'Family',
     'summary': 'Applies Islamic law to Muslims in India for marriage, inheritance, and personal matters.',
     'keySections': ['Section 2 – Application of Shariat', 'Triple Talaq abolished by SC 2017']},
    // Property
    {'title': 'Transfer of Property Act', 'year': '1882', 'category': 'Property',
     'summary': 'Governs the transfer of property by act of parties including sale, mortgage, and lease.',
     'keySections': ['Section 54 – Sale of immovable property', 'Section 58 – Mortgage', 'Section 105 – Lease', 'Section 122 – Gift']},
    {'title': 'Registration Act', 'year': '1908', 'category': 'Property',
     'summary': 'Mandates registration of documents relating to immovable property.',
     'keySections': ['Section 17 – Compulsory registration', 'Section 18 – Optional registration', 'Section 77 – Effect of non-registration']},
    {'title': 'Real Estate (Regulation and Development) Act – RERA', 'year': '2016', 'category': 'Property',
     'summary': 'Regulates real estate sector, protects home buyers and boosts investment.',
     'keySections': ['Section 3 – Registration of projects', 'Section 31 – Filing complaint', 'Section 18 – Refund by promoter']},
    // Consumer
    {'title': 'Consumer Protection Act', 'year': '2019', 'category': 'Consumer',
     'summary': 'Protects consumer rights and establishes three-tier redressal forums.',
     'keySections': ['Section 2 – Definitions (consumer, deficiency)', 'Section 34 – District Commission', 'Section 58 – State Commission', 'Section 67 – National Commission']},
    {'title': 'Food Safety & Standards Act', 'year': '2006', 'category': 'Consumer',
     'summary': 'Regulates food standards and safety across India.',
     'keySections': ['Section 26 – Responsibilities of food business operators', 'Section 59 – Penalty for unsafe food']},
    // Cyber
    {'title': 'Information Technology Act', 'year': '2000', 'category': 'Cyber',
     'summary': 'Primary law for cybercrime and electronic commerce in India.',
     'keySections': ['Section 43 – Penalty for unauthorised access', 'Section 66 – Computer related offences', 'Section 66A – (struck down)', 'Section 66C – Identity theft', 'Section 67 – Obscene material online']},
    {'title': 'Digital Personal Data Protection Act', 'year': '2023', 'category': 'Cyber',
     'summary': 'Framework for processing personal data of Indians digitally.',
     'keySections': ['Section 4 – Lawful processing', 'Section 8 – Consent', 'Section 17 – Duties of data principal', 'Section 33 – Penalties']},
    // Labour
    {'title': 'Code on Wages', 'year': '2019', 'category': 'Labour',
     'summary': 'Consolidates 4 wage-related laws: Minimum Wages, Payment of Wages, Equal Remuneration, Payment of Bonus.',
     'keySections': ['Section 6 – National Floor Wage', 'Section 9 – Fixing minimum wages', 'Section 13 – Overtime wages']},
    {'title': 'Sexual Harassment of Women at Workplace Act (POSH)', 'year': '2013', 'category': 'Labour',
     'summary': 'Protects women from sexual harassment at workplace and mandates Internal Complaints Committees.',
     'keySections': ['Section 2 – Definitions', 'Section 4 – Internal Committee', 'Section 11 – Inquiry into complaint', 'Section 26 – Penalties for employer']},
    {'title': 'Maternity Benefit Act', 'year': '1961', 'category': 'Labour',
     'summary': 'Regulates maternity benefits for women employees (26 weeks paid leave).',
     'keySections': ['Section 5 – Right to payment of maternity benefit', 'Section 27 – Effect on other laws']},
    // Environmental
    {'title': 'Environment Protection Act', 'year': '1986', 'category': 'Environment',
     'summary': 'Umbrella legislation for environmental protection in India.',
     'keySections': ['Section 5 – Directions by Central Govt', 'Section 15 – Penalty for contravention', 'Section 19 – Cognisance of offences']},
    {'title': 'Wildlife Protection Act', 'year': '1972', 'category': 'Environment',
     'summary': 'Provides protection to wild animals, birds, and plants.',
     'keySections': ['Section 9 – Prohibition of hunting', 'Section 44 – Dealers in wildlife articles', 'Section 51 – Penalties']},
    // Corporate
    {'title': 'Companies Act', 'year': '2013', 'category': 'Corporate',
     'summary': 'Governs incorporation, regulation, and winding up of companies in India.',
     'keySections': ['Section 7 – Incorporation documents', 'Section 166 – Duties of directors', 'Section 135 – Corporate Social Responsibility', 'Section 447 – Fraud']},
    {'title': 'Insolvency and Bankruptcy Code (IBC)', 'year': '2016', 'category': 'Corporate',
     'summary': 'Consolidates laws on insolvency of companies and individuals.',
     'keySections': ['Section 7 – Insolvency application by creditor', 'Section 10 – Application by corporate debtor', 'Section 96 – Moratorium for individuals']},
    // Tax
    {'title': 'Income Tax Act', 'year': '1961', 'category': 'Tax',
     'summary': 'Levies, administers, and collects income tax from individuals and businesses.',
     'keySections': ['Section 4 – Charge of income tax', 'Section 10 – Exemptions', 'Section 80C – Deductions', 'Section 139 – Return of income']},
    {'title': 'Goods and Services Tax (GST) Laws', 'year': '2017', 'category': 'Tax',
     'summary': 'Comprehensive indirect tax on supply of goods and services across India.',
     'keySections': ['CGST Act 2017', 'IGST Act 2017', 'Section 9 – Levy on supply', 'Section 37 – Outward supply returns']},
  ];

  static const List<String> _categories = [
    'All', 'Constitutional', 'Criminal', 'Civil', 'Family', 'Property',
    'Consumer', 'Cyber', 'Labour', 'Environment', 'Corporate', 'Tax',
  ];

  static const Map<String, Color> _catColors = {
    'Constitutional': Color(0xFF1565C0),
    'Criminal': Color(0xFFC62828),
    'Civil': Color(0xFF2E7D32),
    'Family': Color(0xFF6A1B9A),
    'Property': Color(0xFFE65100),
    'Consumer': Color(0xFF00695C),
    'Cyber': Color(0xFF0277BD),
    'Labour': Color(0xFF558B2F),
    'Environment': Color(0xFF1B5E20),
    'Corporate': Color(0xFF37474F),
    'Tax': Color(0xFF4A148C),
  };

  List<Map<String, dynamic>> get _filtered {
    return _laws.where((law) {
      final matchCat = _selectedCategory == 'All' || law['category'] == _selectedCategory;
      final q = _query.toLowerCase();
      final matchQ = q.isEmpty ||
          law['title'].toString().toLowerCase().contains(q) ||
          law['summary'].toString().toLowerCase().contains(q) ||
          law['year'].toString().contains(q);
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laws & Acts'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search laws, acts, sections…',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat;
                final color = cat == 'All' ? AppColors.primary : (_catColors[cat] ?? AppColors.primary);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: color,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
                    backgroundColor: AppColors.cardBg,
                  ),
                );
              },
            ),
          ),
          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(children: [
              Text('${filtered.length} law${filtered.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          // Laws list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.search_off, size: 48, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text('No results for "$_query"', style: const TextStyle(color: AppColors.textSecondary)),
                    ]),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _LawTile(law: filtered[i], catColors: _catColors),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LawTile extends StatelessWidget {
  final Map<String, dynamic> law;
  final Map<String, Color> catColors;
  const _LawTile({required this.law, required this.catColors});

  @override
  Widget build(BuildContext context) {
    final color = catColors[law['category']?.toString() ?? ''] ?? AppColors.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Icon(Icons.balance, color: color, size: 22)),
        ),
        title: Text(law['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Row(children: [
          Text(law['year'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(law['category'] ?? '',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ),
        ]),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Text(law['summary'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 10),
          const Text('Key Sections / Highlights:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          ...(law['keySections'] as List<dynamic>? ?? []).map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              Expanded(child: Text(s.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ]),
          )),
        ],
      ),
    );
  }
}
