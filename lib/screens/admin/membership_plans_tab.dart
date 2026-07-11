import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/membership_plan_model.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';

class MembershipPlansTab extends StatefulWidget {
  const MembershipPlansTab({super.key});

  @override
  State<MembershipPlansTab> createState() => _MembershipPlansTabState();
}

class _MembershipPlansTabState extends State<MembershipPlansTab> {
  bool _loading = true;
  List<MembershipPlan> _plans = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMembershipPlans();
      if (mounted) {
        setState(() {
          _plans = data
              .map((e) => MembershipPlan.fromJson(e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive(MembershipPlan plan) async {
    try {
      await Supabase.instance.client
          .from('membership_plans')
          .update({'is_active': !plan.isActive}).eq('id', plan.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAddPlanDialog() {
    final nameCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();
    final yearlyCtrl = TextEditingController();
    String forRole = 'user';
    final benefitCtrls = <TextEditingController>[TextEditingController()];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          title: const Text('Add Membership Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DlgField(ctrl: nameCtrl, label: 'Plan Name'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _DlgField(
                            ctrl: monthlyCtrl,
                            label: 'Monthly (NPR)',
                            number: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _DlgField(
                            ctrl: yearlyCtrl,
                            label: 'Yearly (NPR)',
                            number: true)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: forRole,
                  decoration: const InputDecoration(labelText: 'For Role'),
                  items: ['user', 'operator']
                      .map((r) =>
                          DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setDlg(() => forRole = v ?? 'user'),
                ),
                const SizedBox(height: 10),
                const Text('Benefits:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ...benefitCtrls.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: e.value,
                            decoration: InputDecoration(
                                hintText: 'Benefit ${e.key + 1}',
                                isDense: true),
                          )),
                          if (benefitCtrls.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 18, color: AppColors.danger),
                              onPressed: () => setDlg(() {
                                benefitCtrls[e.key].dispose();
                                benefitCtrls.removeAt(e.key);
                              }),
                            ),
                        ],
                      ),
                    )),
                TextButton.icon(
                  onPressed: () => setDlg(
                      () => benefitCtrls.add(TextEditingController())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Benefit'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final monthly =
                    double.tryParse(monthlyCtrl.text) ?? 0;
                final yearly = double.tryParse(yearlyCtrl.text) ?? 0;
                final benefits = benefitCtrls
                    .map((c) => c.text.trim())
                    .where((b) => b.isNotEmpty)
                    .toList();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await Supabase.instance.client
                    .from('membership_plans')
                    .insert({
                  'name': name,
                  'for_role': forRole,
                  'price_monthly': monthly,
                  'price_yearly': yearly,
                  'benefits': benefits,
                  'is_active': true,
                });
                _load();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Membership Plans',
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlanDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 4, itemHeight: 120))
          : _plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.card_membership,
                          size: 56, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      const Text('No plans yet'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _showAddPlanDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Plan'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plans.length,
                  itemBuilder: (_, i) {
                    final plan = _plans[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(plan.name,
                                          style: tt.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 2),
                                      Text(
                                          'For: ${plan.forRole}  •  Monthly: NPR ${plan.priceMonthly.toStringAsFixed(0)}  •  Yearly: NPR ${plan.priceYearly.toStringAsFixed(0)}',
                                          style: tt.bodySmall),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: plan.isActive,
                                  onChanged: (_) => _toggleActive(plan),
                                  activeThumbColor: AppColors.primary,
                                ),
                              ],
                            ),
                            if (plan.benefits.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: plan.benefits
                                    .map((b) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.surfaceContainerLow,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(b,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ))
                                    .toList(),
                              ),
                            ],
                            if (!plan.isActive)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Inactive',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onErrorContainer,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _DlgField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool number;
  const _DlgField(
      {required this.ctrl, required this.label, this.number = false});

  @override
  Widget build(BuildContext context) => TextField(
        controller: ctrl,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, isDense: true),
      );
}
