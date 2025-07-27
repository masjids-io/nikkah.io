import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String senderID;
  final String conversationID;
  final String content;
  final String messageType;
  final String? mediaURL;
  final List<int>? metadata;
  final String? replyToMessageID;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.senderID,
    required this.conversationID,
    required this.content,
    required this.messageType,
    this.mediaURL,
    this.metadata,
    this.replyToMessageID,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? const Uuid().v4(),
      senderID: json['sender_id'],
      conversationID: json['conversation_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      mediaURL: json['media_url'],
      metadata:
          json['metadata'] != null ? List<int>.from(json['metadata']) : null,
      replyToMessageID: json['reply_to_message_id'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderID,
      'conversation_id': conversationID,
      'content': content,
      'message_type': messageType,
      'media_url': mediaURL,
      'metadata': metadata,
      'reply_to_message_id': replyToMessageID,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? senderID,
    String? conversationID,
    String? content,
    String? messageType,
    String? mediaURL,
    List<int>? metadata,
    String? replyToMessageID,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderID: senderID ?? this.senderID,
      conversationID: conversationID ?? this.conversationID,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaURL: mediaURL ?? this.mediaURL,
      metadata: metadata ?? this.metadata,
      replyToMessageID: replyToMessageID ?? this.replyToMessageID,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}
