import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/case_provider.dart';
import '../../../core/models/case_model.dart';
import '../../../shared/widgets/common_widgets.dart';

class CasesListScreen extends StatefulWidget {
  const CasesListScreen({super.key});

  @override
  State<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends State<CasesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseProvider>().fetchCases();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CaseModel> _filtered(List<CaseModel> cases, String status) {
    List<CaseModel> base = status == 'all'
        ? cases
        : cases.where((c) => c.status == status).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.caseNumber.toLowerCase().contains(q) ||
          c.clientName.toLowerCase().contains(q)).toList();
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = context.watch<CaseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search cases...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(AppStrings.cases),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            }),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CaseProvider>().fetchCases(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: caseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _caseList(_filtered(caseProvider.cases, 'all')),
                _caseList(_filtered(caseProvider.cases, 'active')),
                _caseList(_filtered(caseProvider.cases, 'pending')),
                _caseList(_filtered(caseProvider.cases, 'closed')),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cases/new'),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newCase),
      ),
    );
  }

  Widget _caseList(List<CaseModel> cases) {
    if (cases.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_outlined,
        message: 'No cases found',
        subMessage: 'Tap + to enroll a new case',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      separatorBuilder: (_, __) => const SizedBox(height: 0),
      itemBuilder: (_, i) => _CaseCard(c: cases[i]),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final CaseModel c;
  const _CaseCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final color = caseStatusColor(c.status);
    return LegalCard(
      onTap: () => context.push('/cases/${c.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(label: c.status, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.tag, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(c.caseNumber,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(c.clientName,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          if (c.courtName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.account_balance_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(c.courtName!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
          if (c.nextHearingDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppColors.info),
                  const SizedBox(width: 5),
                  Text(
                    'Next Hearing: ${c.nextHearingDate}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
