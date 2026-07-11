import 'package:flutter/material.dart';
import '../../models/membership_plan_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/branded_app_bar.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  static const _demoUserId = '11111111-1111-1111-1111-111111111111';

  String get _userId => AuthService.currentUserId ?? _demoUserId;

  bool _loading = true;
  bool _yearly = false;
  List<MembershipPlan> _plans = [];
  String? _currentPlanId;
  bool _subscribing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getMembershipPlans(forRole: 'user'),
        ApiService.getCurrentMembership(_userId),
      ]);
      if (mounted) {
        setState(() {
          _plans = (results[0] as List)
              .map((e) => MembershipPlan.fromJson(e as Map<String, dynamic>))
              .toList();
          final membership = results[1] as Map<String, dynamic>?;
          _currentPlanId = membership?['plan_id'] as String?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _subscribe(MembershipPlan plan) async {
    if (plan.priceMonthly == 0) {
      // Free plan — subscribe directly
      setState(() => _subscribing = true);
      await ApiService.subscribeToPlan(
          userId: _userId,
          planId: plan.id,
          billing: _yearly ? 'yearly' : 'monthly');
      if (mounted) {
        setState(() {
          _currentPlanId = plan.id;
          _subscribing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscribed to ${plan.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      return;
    }

    // Simulated payment dialog
    final price = _yearly ? plan.priceYearly : plan.priceMonthly;
    final billing = _yearly ? 'yearly' : 'monthly';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulated Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan: ${plan.name}'),
            Text('Billing: ${billing[0].toUpperCase()}${billing.substring(1)}'),
            const SizedBox(height: 8),
            Text(
              'NPR ${price.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a simulated payment. In production this would connect to eSewa or Khalti.',
              style: TextStyle(
                  fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm Payment')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _subscribing = true);
    try {
      await ApiService.subscribeToPlan(
          userId: _userId, planId: plan.id, billing: billing);
      if (mounted) {
        setState(() {
          _currentPlanId = plan.id;
          _subscribing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${plan.name} activated! NPR ${price.toStringAsFixed(0)} charged to EV Wallet.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _subscribing = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Membership Plans', showBackButton: true),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 3, itemHeight: 200))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                const Text(
                  'Choose your plan',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Unlock more benefits with a premium plan',
                  style: TextStyle(color: AppColors.onSurfaceVariant),
                ),

                const SizedBox(height: 20),

                // Billing toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Monthly'),
                    const SizedBox(width: 12),
                    Switch(
                      value: _yearly,
                      onChanged: (v) => setState(() => _yearly = v),
                      activeThumbColor: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Yearly'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Save 20%',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ..._plans.map((plan) => _PlanCard(
                      plan: plan,
                      isYearly: _yearly,
                      isCurrent: plan.id == _currentPlanId,
                      isSubscribing: _subscribing,
                      onSubscribe: () => _subscribe(plan),
                    )),
              ],
            ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final MembershipPlan plan;
  final bool isYearly;
  final bool isCurrent;
  final bool isSubscribing;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.isYearly,
    required this.isCurrent,
    required this.isSubscribing,
    required this.onSubscribe,
  });

  Color get _accentColor {
    switch (plan.name) {
      case 'Premium':
        return AppColors.secondaryBlue;
      case 'Platinum':
        return const Color(0xFF6D28D9);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.priceYearly : plan.priceMonthly;
    final isFree = price == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isCurrent ? _accentColor : AppColors.outlineVariant,
            width: isCurrent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isCurrent
              ? _accentColor.withValues(alpha: 0.04)
              : AppColors.surfaceContainerLowest,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _accentColor),
                  ),
                  const Spacer(),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Active',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isFree ? 'Free' : 'NPR ${price.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _accentColor),
              ),
              if (!isFree)
                Text(isYearly ? '/ year' : '/ month',
                    style: const TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 13)),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              ...plan.benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: _accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(b,
                                style: const TextStyle(fontSize: 13))),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: isCurrent
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _accentColor),
                        ),
                        child: const Text('Current Plan'),
                      )
                    : FilledButton(
                        onPressed: isSubscribing ? null : onSubscribe,
                        style: FilledButton.styleFrom(
                            backgroundColor: _accentColor),
                        child: isSubscribing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(isFree
                                ? 'Select Free Plan'
                                : 'Subscribe Now'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
