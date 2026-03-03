import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';

const List<String> _stateBarCouncils = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
  'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
  'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
  'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Delhi', 'Jammu & Kashmir',
];

const List<String> _practiceAreas = [
  'Criminal Law', 'Civil Law', 'Family Law', 'Property Law',
  'Corporate Law', 'Consumer Law', 'Labour Law', 'Tax Law',
  'Constitutional Law', 'Cyber Law', 'Intellectual Property',
  'Environmental Law', 'Banking Law', 'Immigration Law',
];

const List<String> _courts = [
  'Supreme Court of India',
  'Delhi High Court', 'Bombay High Court', 'Calcutta High Court',
  'Madras High Court', 'Allahabad High Court', 'Karnataka High Court',
  'Rajasthan High Court', 'Gujarat High Court', 'MP High Court',
  'District Court', 'Sessions Court', 'Family Court', 'Consumer Forum',
  'Magistrate Court', 'Tribunal',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Shared
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Advocate-specific
  final _barCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String? _selectedState;
  String? _selectedCourt;
  final List<String> _selectedAreas = [];

  // Client-specific
  final _cityCtrl = TextEditingController();
  String? _clientState;

  // Flow state
  String? _userType; // null | 'advocate' | 'client'
  bool _obscure = true;
  int _step = 0;

  int get _totalSteps => _userType == 'advocate' ? 3 : 2;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _mobileCtrl.dispose();
    _passwordCtrl.dispose(); _barCtrl.dispose(); _yearCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ─── Submit handlers ───────────────────────────────────────────────────────

  Future<void> _registerAdvocate() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      password: _passwordCtrl.text,
      barCouncilId: _barCtrl.text.trim(),
      stateBarCouncil: _selectedState ?? '',
      enrollmentYear: _yearCtrl.text.trim(),
      courtPreference: _selectedCourt,
      specializations: List.from(_selectedAreas),
    );
    if (!mounted) return;
    if (ok) { context.go('/dashboard'); }
    else { _showError(auth.error ?? AppStrings.error); }
  }

  Future<void> _registerClient() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.registerClient(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      mobile: _mobileCtrl.text.trim(),
      password: _passwordCtrl.text,
      city: _cityCtrl.text.trim(),
      state: _clientState,
    );
    if (!mounted) return;
    if (ok) { context.go('/client/home'); }
    else { _showError(auth.error ?? AppStrings.error); }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  void _next() {
    if (_userType == null) return;
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    if (_userType == 'advocate' && _step == 1 && _selectedState == null) {
      _showError('Please select your State Bar Council');
      return;
    }
    setState(() => _step++);
  }

  void _submit() {
    if (_userType == 'advocate') { _registerAdvocate(); }
    else { _registerClient(); }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: BackButton(onPressed: () {
          if (_step > 0 || _userType != null) {
            setState(() { if (_step > 0) { _step--; } else { _userType = null; } });
          } else {
            context.pop();
          }
        }),
      ),
      body: Column(
        children: [
          if (_userType != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  return Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              i <= _step ? AppColors.primary : AppColors.divider,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                        if (i < _totalSteps - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: i < _step ? AppColors.primary : AppColors.divider,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (_userType == null) _buildTypePicker(),
                    if (_userType == 'advocate') ...[
                      if (_step == 0) ..._personalFields(),
                      if (_step == 1) ..._barCouncilFields(),
                      if (_step == 2) _advocateVerificationNote(),
                    ],
                    if (_userType == 'client') ...[
                      if (_step == 0) ..._clientPersonalFields(),
                      if (_step == 1) _clientConfirmation(),
                    ],
                    const SizedBox(height: 24),
                    if (_userType != null) ...[
                      if (_step < _totalSteps - 1)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _next,
                            child: const Text('Continue'),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submit,
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : Text(_userType == 'advocate'
                                    ? 'Submit Registration'
                                    : 'Create My Account'),
                          ),
                        ),
                      if (_step > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _step--),
                              child: const Text('Back'),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text.rich(TextSpan(children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ])),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Type picker ───────────────────────────────────────────────────────────

  Widget _buildTypePicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('I am a…', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text("Choose how you want to use Let's Legal",
          style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 28),
      _typeCard(
        icon: Icons.gavel,
        iconColor: AppColors.primary,
        title: 'Advocate / Lawyer',
        subtitle: 'Manage cases, clients, hearings and legal diary. '
            'Requires Bar Council verification.',
        onTap: () => setState(() { _userType = 'advocate'; _step = 0; }),
      ),
      const SizedBox(height: 16),
      _typeCard(
        icon: Icons.person_search,
        iconColor: AppColors.accent,
        title: 'Client / Citizen',
        subtitle: 'Find lawyers, track your case, browse laws and get '
            'free legal guidance. No documents required.',
        onTap: () => setState(() { _userType = 'client'; _step = 0; }),
      ),
    ],
  );

  Widget _typeCard({required IconData icon, required Color iconColor,
      required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          )),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ]),
      ),
    );
  }

  // ─── Advocate fields ───────────────────────────────────────────────────────

  List<Widget> _personalFields() => [
    Text('Personal Details', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 4),
    Text('Basic information about you', style: Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height: 20),
    TextFormField(
      controller: _nameCtrl,
      decoration: const InputDecoration(labelText: AppStrings.fullName, prefixIcon: Icon(Icons.person_outline)),
      validator: (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: AppStrings.email, prefixIcon: Icon(Icons.email_outlined)),
      validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _mobileCtrl,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: AppStrings.mobile, prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 '),
      validator: (v) => (v == null || v.length < 10) ? 'Enter 10-digit number' : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
    ),
  ];

  List<Widget> _barCouncilFields() => [
    Text('Bar Council Details', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 4),
    Text('Required to verify you as a registered advocate.', style: Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height: 20),
    TextFormField(
      controller: _barCtrl,
      decoration: const InputDecoration(labelText: AppStrings.barCouncilId, prefixIcon: Icon(Icons.badge_outlined), hintText: 'e.g. DL/12345/2018'),
      validator: (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
    ),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(
      value: _selectedState,
      decoration: const InputDecoration(labelText: AppStrings.stateBarCouncil, prefixIcon: Icon(Icons.account_balance_outlined)),
      items: _stateBarCouncils.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _selectedState = v),
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _yearCtrl,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: AppStrings.enrollmentYear, prefixIcon: Icon(Icons.calendar_today_outlined), hintText: 'e.g. 2018'),
      validator: (v) => (v == null || v.length != 4) ? 'Enter valid year' : null,
    ),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(
      value: _selectedCourt,
      decoration: const InputDecoration(labelText: 'Preferred Court', prefixIcon: Icon(Icons.gavel)),
      items: _courts.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (v) => setState(() => _selectedCourt = v),
    ),
    const SizedBox(height: 14),
    Text('Practice Areas', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 8),
    Wrap(
      spacing: 8, runSpacing: 8,
      children: _practiceAreas.map((area) {
        final chosen = _selectedAreas.contains(area);
        return FilterChip(
          label: Text(area),
          selected: chosen,
          onSelected: (v) => setState(() { if (v) _selectedAreas.add(area); else _selectedAreas.remove(area); }),
          selectedColor: AppColors.primary.withOpacity(0.15),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    ),
  ];

  Widget _advocateVerificationNote() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Almost There!', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: 8),
            Text('Verification Note', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.info)),
          ]),
          const SizedBox(height: 10),
          const Text('Your Bar Council ID will be reviewed by our team. Full access to case management and legal library will be activated once verified. This usually takes 24–48 hours.'),
        ]),
      ),
      const SizedBox(height: 20),
      _summaryRow(Icons.person_outline, 'Name', _nameCtrl.text),
      _summaryRow(Icons.email_outlined, 'Email', _emailCtrl.text),
      _summaryRow(Icons.phone_outlined, 'Mobile', '+91 ${_mobileCtrl.text}'),
      _summaryRow(Icons.badge_outlined, 'Bar Council ID', _barCtrl.text),
      _summaryRow(Icons.account_balance_outlined, 'State Bar Council', _selectedState ?? ''),
      _summaryRow(Icons.calendar_today_outlined, 'Enrollment Year', _yearCtrl.text),
      if (_selectedCourt != null) _summaryRow(Icons.gavel, 'Preferred Court', _selectedCourt!),
      if (_selectedAreas.isNotEmpty) _summaryRow(Icons.library_books, 'Practice Areas', _selectedAreas.join(', ')),
    ],
  );

  // ─── Client fields ─────────────────────────────────────────────────────────

  List<Widget> _clientPersonalFields() => [
    Text('Create Your Account', style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 4),
    Text('Free account — no documents required', style: Theme.of(context).textTheme.bodyMedium),
    const SizedBox(height: 20),
    TextFormField(
      controller: _nameCtrl,
      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
      validator: (v) => (v == null || v.isEmpty) ? AppStrings.required : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: AppStrings.email, prefixIcon: Icon(Icons.email_outlined)),
      validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _mobileCtrl,
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 '),
      validator: (v) => (v == null || v.length < 10) ? 'Enter 10-digit number' : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: AppStrings.password,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _cityCtrl,
      decoration: const InputDecoration(labelText: 'City (optional)', prefixIcon: Icon(Icons.location_city_outlined)),
    ),
    const SizedBox(height: 14),
    DropdownButtonFormField<String>(
      value: _clientState,
      decoration: const InputDecoration(labelText: 'State (optional)', prefixIcon: Icon(Icons.map_outlined)),
      items: _stateBarCouncils.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) => setState(() => _clientState = v),
    ),
  ];

  Widget _clientConfirmation() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Review & Done!', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 12),
          Expanded(child: Text('Your account will be activated immediately. You can start finding advocates, tracking cases and browsing laws right away!')),
        ]),
      ),
      const SizedBox(height: 20),
      _summaryRow(Icons.person_outline, 'Name', _nameCtrl.text),
      _summaryRow(Icons.email_outlined, 'Email', _emailCtrl.text),
      _summaryRow(Icons.phone_outlined, 'Mobile', '+91 ${_mobileCtrl.text}'),
      if (_cityCtrl.text.isNotEmpty) _summaryRow(Icons.location_city_outlined, 'City', _cityCtrl.text),
      if (_clientState != null) _summaryRow(Icons.map_outlined, 'State', _clientState!),
    ],
  );

  // ─── Shared helper ─────────────────────────────────────────────────────────

  Widget _summaryRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      Expanded(child: Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
    ]),
  );
}
