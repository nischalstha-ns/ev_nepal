import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool aiAccent;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.aiAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: br,
            border: aiAccent
                ? const Border(
                    top: BorderSide(color: AppColors.primary, width: 2),
                    left: BorderSide(color: Color(0x14000000)),
                    right: BorderSide(color: Color(0x14000000)),
                    bottom: BorderSide(color: Color(0x14000000)),
                  )
                : Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool aiAccent;
  final Color? borderAccentColor;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.aiAccent = false,
    this.borderAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(12);

    // If aiAccent is enabled, use Stack to add colored top border
    if (aiAccent) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: br,
          border: Border.all(color: const Color(0x28BDCABA)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF334155).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Colored top border
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: borderAccentColor ?? AppColors.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(br.topLeft.x)),
                ),
              ),
            ),
            // Content
            ClipRRect(
              borderRadius: br,
              child: padding != null ? Padding(padding: padding!, child: child) : child,
            ),
          ],
        ),
      );
    }

    // Standard card without accent
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: br,
        border: Border.all(color: const Color(0x28BDCABA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF334155).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Widget? leading;

  const StatusBadge({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.leading,
  });

  factory StatusBadge.online(String label) => StatusBadge(
        label: label,
        bgColor: const Color(0xFFDCFCE7),
        textColor: AppColors.success,
        leading: const _PulseDot(color: AppColors.success),
      );

  factory StatusBadge.warning(String label) => StatusBadge(
        label: label,
        bgColor: const Color(0xFFFEF9C3),
        textColor: AppColors.warning,
        leading: Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.warning)),
      );

  factory StatusBadge.error(String label) => StatusBadge(
        label: label,
        bgColor: AppColors.errorContainer,
        textColor: AppColors.onErrorContainer,
      );

  factory StatusBadge.info(String label) => StatusBadge(
        label: label,
        bgColor: AppColors.surfaceContainerHigh,
        textColor: AppColors.onSurface,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading case final l?) ...[l, const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color)),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final bool aiAccent;
  final Widget? trailing;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.aiAccent = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      aiAccent: aiAccent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
