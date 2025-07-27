import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'https://api.nikkah.io';
  static const String wsUrl = 'wss://api.nikkah.io/ws';

  WebSocketChannel? _channel;
  String? _currentConversationID;
  String? _currentUserID;
  bool _isConnected = false;

  // Callbacks for real-time updates
  Function(Message)? onMessageReceived;
  Function(String)? onConnectionStatusChanged;
  Function(String)? onError;

  // Connect to WebSocket
  Future<void> connect(String userID) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final wsUri = Uri.parse('$wsUrl?token=$token&user_id=$userID');
      _channel = WebSocketChannel.connect(wsUri);
      _currentUserID = userID;
      _isConnected = true;

      // Listen for incoming messages
      _channel!.stream.listen(
        (data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          _isConnected = false;
          onError?.call('WebSocket error: $error');
        },
        onDone: () {
          _isConnected = false;
          onConnectionStatusChanged?.call('disconnected');
        },
      );

      onConnectionStatusChanged?.call('connected');
    } catch (e) {
      _isConnected = false;
      onError?.call('Connection failed: $e');
      rethrow;
    }
  }

  // Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _currentConversationID = null;
    onConnectionStatusChanged?.call('disconnected');
  }

  // Join a conversation
  Future<void> joinConversation(String conversationID) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    _currentConversationID = conversationID;

    final joinMessage = {
      'type': 'join_conversation',
      'conversation_id': conversationID,
    };

    _channel!.sink.add(jsonEncode(joinMessage));
  }

  // Send message via WebSocket
  Future<Message> sendMessage(
    String senderID,
    String conversationID,
    String content,
    String messageType,
    String mediaURL,
    List<int> metadata,
    String? replyToMessageID,
  ) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    final message = {
      'type': 'send_message',
      'sender_id': senderID,
      'conversation_id': conversationID,
      'content': content,
      'message_type': messageType,
      'media_url': mediaURL,
      'metadata': metadata,
      'reply_to_message_id': replyToMessageID,
    };

    _channel!.sink.add(jsonEncode(message));

    // Create a temporary message object for immediate UI feedback
    return Message(
      id: const Uuid().v4(),
      senderID: senderID,
      conversationID: conversationID,
      content: content,
      messageType: messageType,
      mediaURL: mediaURL.isNotEmpty ? mediaURL : null,
      metadata: metadata.isNotEmpty ? metadata : null,
      replyToMessageID: replyToMessageID,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  // Get messages via REST API (for initial load)
  Future<List<Message>> getMessagesByConversation(
    String conversationID,
    int limit,
    int offset,
  ) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.get(
        Uri.parse(
            '$baseUrl/v1/conversations/$conversationID/messages?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['messages'] as List;
        return messages.map((msg) => Message.fromJson(msg)).toList();
      } else {
        throw Exception('Failed to get messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageID, String readerID) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw Exception('No access token available');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/v1/messages/$messageID/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reader_id': readerID,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark message as read: ${response.body}');
      }

      // Also send via WebSocket for real-time updates
      if (_isConnected && _channel != null) {
        final readMessage = {
          'type': 'mark_read',
          'message_id': messageID,
          'reader_id': readerID,
        };
        _channel!.sink.add(jsonEncode(readMessage));
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle incoming WebSocket messages
  void _handleIncomingMessage(dynamic data) {
    try {
      final message = jsonDecode(data);
      final type = message['type'];

      switch (type) {
        case 'new_message':
          final msg = Message.fromJson(message['message']);
          onMessageReceived?.call(msg);
          break;

        case 'message_read':
          // Handle read receipts
          break;

        case 'typing_indicator':
          // Handle typing indicators
          break;

        case 'error':
          onError?.call(message['error']);
          break;

        default:
          // Handle unknown message types
          break;
      }
    } catch (e) {
      onError?.call('Failed to parse message: $e');
    }
  }

  // Send typing indicator
  void sendTypingIndicator(String conversationID, bool isTyping) {
    if (!_isConnected || _channel == null) return;

    final typingMessage = {
      'type': 'typing_indicator',
      'conversation_id': conversationID,
      'is_typing': isTyping,
    };

    _channel!.sink.add(jsonEncode(typingMessage));
  }

  // Check connection status
  bool get isConnected => _isConnected;

  // Get current conversation ID
  String? get currentConversationID => _currentConversationID;
}
