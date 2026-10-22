enum EventStatus { noVenue, pending, active, suspended, cancelled }

class Event {
    final String? id;
    final String title;
    final String description;
    final DateTime start;
    final DateTime end;
    final String? creatorName;
    final EventStatus status;
    final String? allocationId;
    final String? venueName;
    final String? requesterName;

    Event({
        this.id,
        required this.title,
        required this.description,
        required this.start,
        required this.end,
        this.creatorName,
        this.status = EventStatus.noVenue,
        this.allocationId,
        this.venueName,
        this.requesterName,
    });

    bool get isCancelled => status == EventStatus.cancelled;

    bool get isSuspended => status == EventStatus.suspended;

    bool get hasEnded => !end.isAfter(DateTime.now());

    bool get isInProgress {
        final now = DateTime.now();
        return status == EventStatus.active && !start.isAfter(now) && end.isAfter(now);
    }

    bool get isFinished => isCancelled || (status == EventStatus.active && hasEnded);

    bool get canEdit => !isFinished;

    bool get canSuspend => status == EventStatus.active && !hasEnded;

    bool get canReactivate => isSuspended && !hasEnded;

    bool get showsAllocationReminder => status == EventStatus.noVenue && start.isAfter(DateTime.now());

    factory Event.fromJson(Map<String, dynamic> json) {
        return Event(
            id: json['id'],
            title: json['title'] ?? '',
            description: json['description'] ?? '',
            start: DateTime.parse(json['start']),
            end: DateTime.parse(json['end']),
            status: _parseEventStatus(json['status']),
            allocationId: json['allocationId'],
            venueName: json['venueName'] ?? json['venue']?['name'],
            requesterName: json['requesterName'],
        );
    }

    static EventStatus _parseEventStatus(String? status) {
        switch (status) {
            case 'AGUARDANDO_APROVACAO':
                return EventStatus.pending;
            case 'ATIVO':
                return EventStatus.active;
            case 'SUSPENSO':
                return EventStatus.suspended;
            case 'CANCELADO':
                return EventStatus.cancelled;
            default:
                return EventStatus.noVenue;
        }
    }
    Map<String, dynamic> toRequestJson() {
        return {
            'title': title,
            'description': description,
            'start': start.toIso8601String(),
            'end': end.toIso8601String(),
        };
    }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${_twoDigits(d.day)}/${_twoDigits(d.month)}/${d.year}';

String formatTime(DateTime d) => '${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';

String formatDateTime(DateTime d) => '${formatDate(d)} ${formatTime(d)}';

String formatPeriod(DateTime start, DateTime end) {
    final sameDay = start.year == end.year && start.month == end.month && start.day == end.day;
    if (sameDay) {
    return '${formatDate(start)}, ${formatTime(start)} – ${formatTime(end)}';
  }
    return '${formatDateTime(start)} – ${formatDateTime(end)}';
}
