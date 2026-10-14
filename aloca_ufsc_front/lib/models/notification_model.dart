enum NotificationKind { general, newVenue, noVenue3Days, noVenue24Hours, suspendedDatePassed }

class AppNotification {
  final int id;
  final NotificationKind kind;
  final String message;
  final int? eventId;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    this.kind = NotificationKind.general,
    required this.message,
    this.eventId,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      kind: switch (json['type']) {
        'NOVO_ESPACO' => NotificationKind.newVenue,
        'EVENTO_SEM_ESPACO_3_DIAS' => NotificationKind.noVenue3Days,
        'EVENTO_SEM_ESPACO_24_HORAS' => NotificationKind.noVenue24Hours,
        'EVENTO_SUSPENSO_DATA_PASSADA' => NotificationKind.suspendedDatePassed,
        _ => NotificationKind.general,
      },
      message: json['message'] ?? '',
      eventId: json['eventId'],
      createdAt: DateTime.parse(json['createdAt']),
      read: json['read'] ?? false,
    );
  }
}

String formatRelativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays < 7) return diff.inDays == 1 ? 'há 1 dia' : 'há ${diff.inDays} dias';
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}
