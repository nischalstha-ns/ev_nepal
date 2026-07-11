import 'package:flutter/material.dart';

class BrandedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool showProfileAvatar;

  const BrandedAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.leading,
    this.bottom,
    this.showProfileAvatar = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    if (showBackButton) {
      leadingWidget = null;
    } else if (leading != null) {
      leadingWidget = leading;
    } else if (showProfileAvatar) {
      leadingWidget = GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/user/profile'),
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            child: const Icon(Icons.person, color: Color(0xFF2E7D32), size: 20),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: leadingWidget,
      leadingWidth: showBackButton ? null : 52,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }
}
