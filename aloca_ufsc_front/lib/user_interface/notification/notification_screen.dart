import 'package:flutter/material.dart';

import '../../shell.dart';
import '../../theme.dart';
import '../event/event_detail_screen.dart';
import '../event/event_form_screen.dart';
import '../../models/notification_model.dart';
import 'package:aloca_ufsc_front/main.dart';

const int _allocationTabIndex = 2;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _notifications.isEmpty;
      _error = null;
    });
    
    // Substituído para o uso do appState e padrão Result
    final result = await appState.fetchNotifications();
    
    if (!mounted) return;
    
    setState(() {
      if (result.isError) {
        _error = result.error.toString().replaceFirst('Exception: ', '');
      } else {
        _notifications = result.data ?? [];
      }
      _loading = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(AppNotification n) async {
    final result = await appState.deleteNotification(n.id!);
    if (result.isError) {
      _showMessage(result.error.toString().replaceFirst('Exception: ', ''));
    }
    _load();
  }

  Future<void> _markAllAsRead() async {
    final result = await appState.markAllNotificationsAsRead();
    if (result.isError) {
      _showMessage(result.error.toString().replaceFirst('Exception: ', ''));
    }
    _load();
  }

  Future<void> _clearRead() async {
    final result = await appState.deleteReadNotifications();
    if (result.isError) {
      _showMessage(result.error.toString().replaceFirst('Exception: ', ''));
    }
    _load();
  }

  Future<void> _open(AppNotification n) async {
    if (!n.read) {
      appState.markNotificationAsRead(n.id!).then((result) {
        if (result.isOk) _load();
      });
    }
    
    final action = await showModalBottomSheet<_Action>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _ActionsSheet(notification: n),
    );
    
    if (action == null || !mounted) return;

    switch (action) {
      case _Action.viewEvent:
        await _openEvent(n.eventId!, edit: false);
      case _Action.editEvent:
        await _openEvent(n.eventId!, edit: true);
      case _Action.goToAllocations:
        RootShell.of(context).switchTab(_allocationTabIndex);
      case _Action.delete:
        await _delete(n);
    }
  }

  Future<void> _openEvent(String eventId, {required bool edit}) async {
    final result = await appState.fetchEvent(eventId);
    
    if (!mounted) return;
    
    if (result.isError) {
      _showMessage(result.error.toString().replaceFirst('Exception: ', ''));
      _load();
      return;
    }
    
    final event = result.data!;
    
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => edit ? EventFormScreen(event: event) : EventDetailScreen(event: event),
    ));
    
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => !n.read);
    final hasRead = _notifications.any((n) => n.read);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (hasUnread || hasRead)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'readAll') _markAllAsRead();
                if (value == 'clearRead') _clearRead();
              },
              itemBuilder: (context) => [
                if (hasUnread) const PopupMenuItem(value: 'readAll', child: Text('Marcar todas como lidas')),
                if (hasRead) const PopupMenuItem(value: 'clearRead', child: Text('Limpar lidas')),
              ],
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }
    if (_notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 72, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Nenhuma notificação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Você está em dia!', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final unread = _notifications.where((n) => !n.read).toList();
    final read = _notifications.where((n) => n.read).toList();
    
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.paddingOf(context).bottom),
        children: [
          if (unread.isNotEmpty) ...[
            const _SectionTitle('Novas'),
            for (final n in unread) _tile(n),
          ],
          if (read.isNotEmpty) ...[
            const _SectionTitle('Anteriores'),
            for (final n in read) _tile(n),
          ],
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Arraste uma notificação para o lado para excluí-la.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(AppNotification n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() => _notifications.removeWhere((x) => x.id == n.id));
        _delete(n);
      },
      child: _NotificationCard(notification: n, onTap: () => _open(n)),
    );
  }
}

enum _Action { viewEvent, editEvent, goToAllocations, delete }

class _ActionsSheet extends StatelessWidget {
  final AppNotification notification;

  const _ActionsSheet({required this.notification});

  List<(IconData, String, _Action)> get _actions {
    final hasEvent = notification.eventId != null;
    switch (notification.kind) {
      case NotificationKind.noVenue3Days:
      case NotificationKind.noVenue24Hours:
        return [
          (Icons.meeting_room_outlined, 'Solicitar espaço', _Action.goToAllocations),
          if (hasEvent) (Icons.event_note, 'Ver evento', _Action.viewEvent),
        ];
      case NotificationKind.suspendedDatePassed:
        return [
          if (hasEvent) (Icons.edit_calendar, 'Editar data do evento', _Action.editEvent),
          if (hasEvent) (Icons.event_note, 'Ver evento', _Action.viewEvent),
        ];
      case NotificationKind.newVenue:
        return [(Icons.meeting_room_outlined, 'Ver espaços', _Action.goToAllocations)];
      case NotificationKind.general:
        return [if (hasEvent) (Icons.event_note, 'Ver evento', _Action.viewEvent)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = notificationStyle(notification.kind);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KindIcon(kind: notification.kind),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(style.title, style: TextStyle(fontWeight: FontWeight.w600, color: style.color)),
                      const SizedBox(height: 4),
                      Text(notification.message, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(formatRelativeTime(notification.createdAt),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final (icon, label, action) in _actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, action),
                  icon: Icon(icon),
                  label: Text(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, _Action.delete),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir notificação'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.read;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: unread ? AppColors.secondaryBlue : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KindIcon(kind: notification.kind),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: TextStyle(fontWeight: unread ? FontWeight.w600 : FontWeight.normal),
                    ),
                    const SizedBox(height: 4),
                    Text(formatRelativeTime(notification.createdAt),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (unread)
                const Padding(
                  padding: EdgeInsets.only(left: 8, top: 4),
                  child: Icon(Icons.circle, size: 10, color: AppColors.mainBlue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KindIcon extends StatelessWidget {
  final NotificationKind kind;

  const _KindIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    final style = notificationStyle(kind);
    return CircleAvatar(
      radius: 20,
      backgroundColor: style.color.withAlpha(30),
      child: Icon(style.icon, color: style.color, size: 22),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

({IconData icon, Color color, String title}) notificationStyle(NotificationKind kind) {
  switch (kind) {
    case NotificationKind.noVenue24Hours:
      return (icon: Icons.alarm, color: Colors.red.shade600, title: 'Evento em menos de 24 horas');
    case NotificationKind.noVenue3Days:
      return (icon: Icons.schedule, color: Colors.orange.shade700, title: 'Evento em breve');
    case NotificationKind.suspendedDatePassed:
      return (icon: Icons.pause_circle_outline, color: Colors.amber.shade800, title: 'Evento suspenso');
    case NotificationKind.newVenue:
      return (icon: Icons.meeting_room_outlined, color: AppColors.mainBlue, title: 'Novo espaço');
    case NotificationKind.general:
      return (icon: Icons.notifications_outlined, color: AppColors.textSecondary, title: 'Aviso');
  }
}
