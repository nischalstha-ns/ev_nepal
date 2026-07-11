import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/branded_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _demoUserId = '11111111-1111-1111-1111-111111111111';

  String get _userId => AuthService.currentUserId ?? _demoUserId;

  bool _loading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getNotifications(_userId);
      if (mounted) {
        setState(() {
          _notifications = data
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await NotificationService.markRead(id);
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        final n = _notifications[idx];
        _notifications[idx] = AppNotification(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }
    });
  }

  Future<void> _markAllRead() async {
    await NotificationService.markAllRead(_userId);
    setState(() {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        userId: n.userId,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
      )).toList();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'success': return Icons.check_circle_outline;
      case 'warning': return Icons.warning_amber_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      default: return AppColors.secondaryBlue;
    }
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 5, itemHeight: 72),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_off_outlined,
                          size: 56, color: AppColors.outlineVariant),
                      const SizedBox(height: 12),
                      Text('No notifications',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              )),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final color = _colorForType(n.type);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SurfaceCard(
                          padding: const EdgeInsets.all(14),
                          child: InkWell(
                            onTap: n.isRead ? null : () => _markRead(n.id),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_iconForType(n.type),
                                      color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n.title,
                                          style: TextStyle(
                                            fontWeight: n.isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            fontSize: 14,
                                          )),
                                      const SizedBox(height: 2),
                                      Text(n.body,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.onSurfaceVariant,
                                          )),
                                      const SizedBox(height: 4),
                                      Text(_timeAgo(n.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.outline,
                                          )),
                                    ],
                                  ),
                                ),
                                if (!n.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
