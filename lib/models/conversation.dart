import 'package:uuid/uuid.dart';

class Conversation {
  final String id;
  final List<String> participantIDs;
  final String? lastMessageID;
  final String? lastMessageContent;
  final DateTime? lastMessageTimestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participantIDs,
    this.lastMessageID,
    this.lastMessageContent,
    this.lastMessageTimestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? const Uuid().v4(),
      participantIDs: List<String>.from(json['participant_ids']),
      lastMessageID: json['last_message_id'],
      lastMessageContent: json['last_message_content'],
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIDs,
      'last_message_id': lastMessageID,
      'last_message_content': lastMessageContent,
      'last_message_timestamp': lastMessageTimestamp?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participantIDs,
    String? lastMessageID,
    String? lastMessageContent,
    DateTime? lastMessageTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIDs: participantIDs ?? this.participantIDs,
      lastMessageID: lastMessageID ?? this.lastMessageID,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
