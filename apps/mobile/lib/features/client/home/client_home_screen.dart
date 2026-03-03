import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firstName = (auth.user?.fullName ?? 'there').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, $firstName', style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  const Text('How can we help you today?',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF283593)],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Icon(Icons.balance, color: Colors.white24, size: 120),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Emergency helpline ────────────────────────────────────
                  _EmergencyBanner(),
                  const SizedBox(height: 20),

                  // ── Quick actions ─────────────────────────────────────────
                  _SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _ActionCard(icon: Icons.gavel, label: 'Find a Lawyer',
                          color: AppColors.primary,
                          onTap: () => context.go('/client/advocates')),
                      _ActionCard(icon: Icons.search, label: 'Track My Case',
                          color: const Color(0xFF00897B),
                          onTap: () => context.go('/client/track')),
                      _ActionCard(icon: Icons.menu_book, label: 'Laws & Acts',
                          color: const Color(0xFF5E35B1),
                          onTap: () => context.go('/client/laws')),
                      _ActionCard(icon: Icons.support_agent, label: 'Legal Help',
                          color: AppColors.accent,
                          onTap: () => context.go('/client/help')),
                      _ActionCard(icon: Icons.calendar_month, label: 'Court Calendar',
                          color: const Color(0xFF1B5E20),
                          onTap: () => context.go('/client/calendar')),
                      _ActionCard(icon: Icons.info_outline, label: 'My Rights',
                          color: const Color(0xFF4527A0),
                          onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Know Your Rights ─────────────────────────────────────
                  _SectionHeader(title: 'Know Your Rights', subtitle: 'Essential legal awareness'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _RightsTile(icon: Icons.person_pin, title: 'Right to Equality',
                            desc: 'Article 14: Every person is equal before the law.',
                            color: Color(0xFF1565C0)),
                        _RightsTile(icon: Icons.record_voice_over, title: 'Right to Speech',
                            desc: 'Article 19(1)(a): Freedom of speech and expression.',
                            color: Color(0xFF2E7D32)),
                        _RightsTile(icon: Icons.shield, title: 'Right to Life',
                            desc: 'Article 21: No person shall be deprived of life without due process.',
                            color: Color(0xFF6A1B9A)),
                        _RightsTile(icon: Icons.school, title: 'Right to Education',
                            desc: 'Article 21A: Free education for children aged 6–14.',
                            color: Color(0xFFBF360C)),
                        _RightsTile(icon: Icons.work, title: 'Rights Against Exploitation',
                            desc: 'Article 23: Prohibition of trafficking and forced labour.',
                            color: Color(0xFF00695C)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Free Legal Aid ─────────────────────────────────────
                  _SectionHeader(title: 'Free Legal Aid'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.support_agent,
                    title: 'National Legal Services Authority',
                    subtitle: 'Free legal aid for economically weaker sections, women, SC/ST, children & more.',
                    actionText: 'Call NALSA: 15100',
                    actionColor: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.local_police,
                    title: "Women's Helpline",
                    subtitle: 'Domestic violence, harassment, safety concerns. Available 24×7.',
                    actionText: 'Call: 181',
                    actionColor: const Color(0xFFC62828),
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    icon: Icons.child_care,
                    title: 'Child Helpline',
                    subtitle: 'Support for children in need, abuse or danger.',
                    actionText: 'Call CHILDLINE: 1098',
                    actionColor: const Color(0xFF00838F),
                  ),
                  const SizedBox(height: 24),

                  // ── Common Legal FAQs ─────────────────────────────────
                  _SectionHeader(title: 'Common Legal Questions'),
                  const SizedBox(height: 12),
                  ..._faqs.map((faq) => _FaqTile(question: faq[0], answer: faq[1])),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emergency Legal Help', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Police: 100 · Ambulance: 108 · Legal Aid: 15100',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600,
                fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _RightsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  const _RightsTile({required this.icon, required this.title,
      required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700,
              fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final Color actionColor;
  const _InfoCard({required this.icon, required this.title,
      required this.subtitle, required this.actionText, required this.actionColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: actionColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(actionText, style: TextStyle(color: actionColor,
                    fontWeight: FontWeight.w600, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(widget.question, style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600)),
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(widget.answer,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

const List<List<String>> _faqs = [
  ['What should I do if I am arrested?',
    'You have the right to remain silent and the right to a lawyer. Do not sign any document without a lawyer present. You must be produced before a magistrate within 24 hours of arrest under Article 22.'],
  ['How can I file an FIR?',
    'Visit the nearest police station and give a written complaint. The police must register the FIR for cognizable offences. If they refuse, you can file a complaint with the Superintendent of Police or directly approach a Magistrate.'],
  ['What is a consumer complaint and how do I file one?',
    'If you have been sold a defective product or provided poor service, you can file a complaint at the Consumer Disputes Redressal Forum (CDRF) in your district. Cases up to ₹1 crore go to District Forum, up to ₹10 crore to State Commission, and above that to National Commission.'],
  ['What is RTI (Right to Information)?',
    'Under the RTI Act 2005, any citizen can request information from any public authority. File a written application with the Public Information Officer (PIO) with a ₹10 fee. The authority must respond within 30 days (48 hours for life/liberty matters).'],
  ['How to get legal aid for free?',
    'If you cannot afford a lawyer, contact your District Legal Services Authority (DLSA) or call NALSA at 15100. Free legal aid is available for women, children, SC/ST, persons with disabilities, victims of trafficking, and those with income below ₹1 lakh p.a.'],
  ['What is bail and how do I apply?',
    'Bail is temporary release from custody. For bailable offences, you have a right to bail from the police. For non-bailable offences, you must apply to a court. A lawyer can file a bail application before the Sessions Court or High Court.'],
];
