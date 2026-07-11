class MembershipPlan {
  final String id;
  final String name;
  final String forRole;
  final double priceMonthly;
  final double priceYearly;
  final List<String> benefits;
  final bool isActive;

  MembershipPlan({
    required this.id,
    required this.name,
    required this.forRole,
    required this.priceMonthly,
    required this.priceYearly,
    required this.benefits,
    required this.isActive,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    final raw = json['benefits'];
    List<String> benefits = [];
    if (raw is List) {
      benefits = raw.map((e) => e.toString()).toList();
    } else if (raw is String) {
      benefits = [raw];
    }
    return MembershipPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      forRole: json['for_role'] ?? 'user',
      priceMonthly: (json['price_monthly'] as num?)?.toDouble() ?? 0,
      priceYearly: (json['price_yearly'] as num?)?.toDouble() ?? 0,
      benefits: benefits,
      isActive: json['is_active'] == true,
    );
  }
}
