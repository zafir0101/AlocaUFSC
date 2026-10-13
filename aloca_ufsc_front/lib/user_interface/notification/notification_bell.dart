import 'package:flutter/material.dart';

import '../../api/notification_service.dart';
import '../../theme.dart';
import 'notification_screen.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _notificationService = NotificationService();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final count = await _notificationService.fetchUnreadCount();
      if (mounted) setState(() => _unread = count);
    } catch (_) {
      // Sem conexão ou sem login: o sino só fica sem contador.
    }
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
    _loadUnread();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _open,
      tooltip: 'Notificações',
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        child: Icon(
          _unread > 0 ? Icons.notifications : Icons.notifications_outlined,
          size: 26,
          color: AppColors.mainBlue,
        ),
      ),
    );
  }
}
