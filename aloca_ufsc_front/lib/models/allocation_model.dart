import 'package:flutter/foundation.dart';

enum AllocationStatus { pending, approved, rejected }

AllocationStatus _parseStatus(String status) {
  switch (status.toUpperCase()) {
    case 'APPROVED': return AllocationStatus.approved;
    case 'REJECTED': return AllocationStatus.rejected;
    default: return AllocationStatus.pending;
  }
}

class EventOption {
  final int id;
  final String title;
  final String status;

  EventOption({required this.id, required this.title, required this.status});

  factory EventOption.fromJson(Map<String, dynamic> json) {
    return EventOption(
      id: json['id'],
      title: json['title'],
      status: json['status'],
    );
  }
}

class Allocation {
  final int id;
  final AllocationStatus status;
  final String venueId;
  final String venueName;
  final String venueLocation;
  final int eventId;
  final String eventTitle;
  final String requesterId;
  final String requesterName;
  final DateTime start;
  final DateTime end;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  Allocation({
    required this.id,
    required this.status,
    required this.venueId,
    required this.venueName,
    required this.venueLocation,
    required this.eventId,
    required this.eventTitle,
    required this.requesterId,
    required this.requesterName,
    required this.start,
    required this.end,
    required this.createdAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      id: json['id'],
      status: _parseStatus(json['status']),
      venueId: json['venueId'],
      venueName: json['venueName'],
      venueLocation: json['venueLocation'],
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      requesterId: json['requesterId'],
      requesterName: json['requesterName'],
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
      createdAt: DateTime.parse(json['createdAt']),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}
