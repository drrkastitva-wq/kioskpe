import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/directory_models.dart';
import '../../../shared/widgets/common_widgets.dart';

// ─── Courts Directory ─────────────────────────────────────────────────────────

class CourtsDirectoryScreen extends StatefulWidget {
  const CourtsDirectoryScreen({super.key});

  @override
  State<CourtsDirectoryScreen> createState() => _CourtsDirectoryScreenState();
}

class _CourtsDirectoryScreenState extends State<CourtsDirectoryScreen> {
  List<CourtModel> _courts = [];
  List<CourtModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();
  String? _selectedState;

  final List<String> _indianStates = [
    'All States', 'Andhra Pradesh', 'Delhi', 'Gujarat', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Punjab', 'Rajasthan',
    'Tamil Nadu', 'Telangana', 'Uttar Pradesh', 'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.get(ApiConstants.courts);
      final list =
          (data['courts'] ?? data['data'] ?? data) as List<dynamic>;
      setState(() {
        _courts = list
            .map((e) => CourtModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _filtered = _courts;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _courts.where((c) {
        final matchSearch = q.isEmpty ||
            c.name.toLowerCase().contains(q) ||
            (c.district?.toLowerCase().contains(q) ?? false);
        final matchState = _selectedState == null ||
            _selectedState == 'All States' ||
            c.state == _selectedState;
        return matchSearch && matchState;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.courts)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search courts...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedState ?? 'All States',
                  decoration: const InputDecoration(
                      labelText: 'Filter by State', isDense: true),
                  items: _indianStates
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedState = v);
                    _filter();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.account_balance_outlined,
                        message: 'No courts found',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) =>
                            _CourtCard(court: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final CourtModel court;
  const _CourtCard({required this.court});

  @override
  Widget build(BuildContext context) {
    return LegalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(court.name,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(
                label: court.level.replaceAll('_', ' '),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (court.address != null)
            _info(Icons.location_on_outlined, court.address!),
          _info(Icons.map_outlined, '${court.district ?? ''}, ${court.state}'),
          if (court.contactNumber != null)
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('tel:${court.contactNumber}')),
              child: _info(Icons.phone_outlined, court.contactNumber!,
                  color: AppColors.primary),
            ),
          if (court.website != null)
            GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(court.website!);
                if (uri != null) await launchUrl(uri);
              },
              child: _info(Icons.language, court.website!,
                  color: AppColors.info),
            ),
          if (court.latitude != null && court.longitude != null)
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(
                    'https://maps.google.com/?q=${court.latitude},${court.longitude}');
                await launchUrl(uri);
              },
              child: _info(Icons.directions, 'Open in Google Maps',
                  color: AppColors.success),
            ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 14,
              color: color ?? AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: color ?? AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ─── Bar Associations Directory ───────────────────────────────────────────────

class BarAssociationsScreen extends StatefulWidget {
  const BarAssociationsScreen({super.key});

  @override
  State<BarAssociationsScreen> createState() => _BarAssociationsScreenState();
}

class _BarAssociationsScreenState extends State<BarAssociationsScreen> {
  List<BarAssociationModel> _bars = [];
  List<BarAssociationModel> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = _bars.where((b) =>
          b.name.toLowerCase().contains(q) ||
          (b.district?.toLowerCase().contains(q) ?? false) ||
          b.state.toLowerCase().contains(q)).toList();
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
      final data = await ApiService.get(ApiConstants.barAssociations);
      final list = (data['barAssociations'] ?? data['data'] ?? data) as List;
      setState(() {
        _bars = list.map((e) =>
            BarAssociationModel.fromJson(e as Map<String, dynamic>)).toList();
        _filtered = _bars;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.barAssociations)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                  hintText: 'Search bar associations...',
                  prefixIcon: Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.balance,
                        message: 'No bar associations found')
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (_, i) {
                          final b = _filtered[i];
                          return LegalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.name,
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 6),
                                Text('${b.district ?? ''}, ${b.state}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary)),
                                if (b.contactNumber != null)
                                  GestureDetector(
                                    onTap: () => launchUrl(
                                        Uri.parse('tel:${b.contactNumber}')),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone_outlined,
                                              size: 14, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Text(b.contactNumber!,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary)),
                                        ],
                                      ),
                                    ),
                                  ),
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
