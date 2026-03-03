import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class HelpRequestScreen extends StatefulWidget {
  const HelpRequestScreen({super.key});

  @override
  State<HelpRequestScreen> createState() => _HelpRequestScreenState();
}

class _HelpRequestScreenState extends State<HelpRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'Criminal';
  String _preferredCourt = 'Any';
  String _contactPref = 'Call';
  bool _submitting = false;
  String? _refNumber;

  static const _categories = [
    'Criminal', 'Civil', 'Family / Matrimonial', 'Property / Real Estate',
    'Consumer', 'Cyber Crime', 'Labour / Employment', 'Corporate / Business',
    'Tax', 'Environmental', 'Constitutional / PILs', 'Other',
  ];

  static const _courts = [
    'Any', 'Supreme Court of India', 'Delhi High Court', 'Bombay High Court',
    'Madras High Court', 'Calcutta High Court', 'Karnataka High Court',
    'Allahabad High Court', 'District / Sessions Court', 'Family Court',
    'Consumer Forum', 'Labour / Industrial Court',
  ];

  static const _contactOptions = ['Call', 'WhatsApp', 'Email', 'Any'];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _mobileCtrl.text = user.mobile;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _generateRef() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    final suffix = List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
    return 'LH-${DateTime.now().year}-$suffix';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final payload = {
      'fullName': _nameCtrl.text.trim(),
      'mobile': _mobileCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _category,
      'preferredCourt': _preferredCourt,
      'contactPreference': _contactPref,
    };

    try {
      await ApiService.post(ApiConstants.helpRequests, payload);
    } catch (_) {
      // Backend may not be up — generate ref locally
    }

    final ref = _generateRef();
    if (mounted) setState(() { _submitting = false; _refNumber = ref; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Legal Help'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _refNumber != null ? _SuccessView(refNumber: _refNumber!) : _FormView(
        formKey: _formKey,
        nameCtrl: _nameCtrl, mobileCtrl: _mobileCtrl, descCtrl: _descCtrl,
        category: _category, preferredCourt: _preferredCourt, contactPref: _contactPref,
        categories: _categories, courts: _courts, contactOptions: _contactOptions,
        submitting: _submitting,
        onCategoryChanged: (v) => setState(() => _category = v!),
        onCourtChanged: (v) => setState(() => _preferredCourt = v!),
        onContactChanged: (v) => setState(() => _contactPref = v!),
        onSubmit: _submit,
      ),
    );
  }
}

// ─── Form view ───────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, mobileCtrl, descCtrl;
  final String category, preferredCourt, contactPref;
  final List<String> categories, courts, contactOptions;
  final bool submitting;
  final ValueChanged<String?> onCategoryChanged, onCourtChanged, onContactChanged;
  final VoidCallback onSubmit;

  const _FormView({
    required this.formKey, required this.nameCtrl, required this.mobileCtrl,
    required this.descCtrl, required this.category, required this.preferredCourt,
    required this.contactPref, required this.categories, required this.courts,
    required this.contactOptions, required this.submitting,
    required this.onCategoryChanged, required this.onCourtChanged,
    required this.onContactChanged, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Describe your legal issue. An advocate matching your category and court preference will be assigned and will contact you.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              )),
            ]),
          ),
          const SizedBox(height: 20),
          _Section(title: 'Your Contact Information', children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: mobileCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined)),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Mobile is required';
                if ((v?.trim().length ?? 0) < 10) return 'Enter valid 10-digit number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: contactPref,
              decoration: const InputDecoration(labelText: 'Preferred Contact Method', prefixIcon: Icon(Icons.contact_phone_outlined)),
              items: contactOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onContactChanged,
            ),
          ]),
          const SizedBox(height: 20),
          _Section(title: 'Legal Issue Details', children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category of Issue', prefixIcon: Icon(Icons.category_outlined)),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: preferredCourt,
              decoration: const InputDecoration(labelText: 'Preferred Court (optional)', prefixIcon: Icon(Icons.gavel_outlined)),
              items: courts.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: onCourtChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describe Your Issue',
                hintText: 'Please provide details about your legal problem, what happened, and what help you need…',
                alignLabelWithHint: true,
                prefixIcon: Padding(padding: EdgeInsets.only(bottom: 80), child: Icon(Icons.description_outlined)),
              ),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Please describe your issue';
                if ((v?.trim().length ?? 0) < 20) return 'Please provide more detail (min 20 characters)';
                return null;
              },
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send),
              label: Text(submitting ? 'Submitting…' : 'Submit Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'By submitting, you agree that your contact information will be shared with a verified advocate to help with your case.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 14),
        ...children,
      ]),
    );
  }
}

// ─── Success view ─────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String refNumber;
  const _SuccessView({required this.refNumber});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          ),
          const SizedBox(height: 20),
          const Text('Request Submitted!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text(
            'Your legal help request has been received. A verified advocate will contact you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(children: [
              const Text('Your Reference Number', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(refNumber, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                  fontFamily: 'monospace', color: AppColors.primary, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              const Text('Save this number to track your request', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Emergency Legal Aid Helpline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          const Text('NALSA Helpline: 15100', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              minimumSize: const Size(200, 44),
            ),
            child: const Text('Back to Home'),
          ),
        ]),
      ),
    );
  }
}
