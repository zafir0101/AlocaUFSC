import 'package:flutter/material.dart';

import '../../theme.dart';
import 'notification_screen.dart';
import '../../../main.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final result = await appState.fetchUnreadCount();
      
      if (mounted && result.isOk) {
        setState(() => _unread = result.data ?? 0);
      }
    } catch (_) {
    }
  }

  Future<void> _open() async {
    await Navigator.of(context, rootNavigator: true).push(
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
