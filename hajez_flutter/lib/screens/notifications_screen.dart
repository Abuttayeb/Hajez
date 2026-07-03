import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../services/farm_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await FarmService.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = res['data'] as List? ?? [];
      _unreadCount = int.tryParse(res['unread_count'].toString()) ?? 0;
      _loading = false;
    });
  }

  void _markAllRead() async {
    await FarmService.markAllNotificationsRead();
    setState(() {
      _unreadCount = 0;
      _notifications = _notifications.map((n) => {...n as Map, 'is_read': true}).toList();
    });
  }

  void _onTapNotification(Map n) {
    if (n['is_read'] != true && n['is_read'] != 1) {
      FarmService.markNotificationRead(int.tryParse(n['id'].toString()) ?? 0);
      setState(() {
        final i = _notifications.indexOf(n);
        if (i != -1) _notifications[i] = {...n, 'is_read': true};
        if (_unreadCount > 0) _unreadCount--;
      });
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'booking': return Icons.event_available_rounded;
      case 'booking_status': return Icons.update_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
      if (diff.inDays < 7) return 'قبل ${diff.inDays} يوم';
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('قراءة الكل', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.notifications_none_rounded, size: 72, color: AppColors.grey.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text('لا إشعارات بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark)),
                  ]),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = _notifications[i] as Map;
                      final isRead = n['is_read'] == true || n['is_read'] == 1;
                      return GestureDetector(
                        onTap: () => _onTapNotification(n),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isRead ? AppColors.white : AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.25)),
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle),
                              child: Icon(_iconFor(n['type']?.toString()), color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(n['title']?.toString() ?? '', style: TextStyle(fontFamily: 'Cairo', fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 14, color: AppColors.dark)),
                                if ((n['body']?.toString() ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(n['body'].toString(), style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.grey)),
                                ],
                                const SizedBox(height: 5),
                                Text(_timeAgo(n['created_at']?.toString()), style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.grey)),
                              ]),
                            ),
                            if (!isRead)
                              Container(width: 9, height: 9, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
