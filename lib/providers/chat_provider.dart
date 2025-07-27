import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _currentConversationID;
  String? _currentUserID;
  String? _error;
  bool _isTyping = false;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get currentConversationID => _currentConversationID;
  String? get currentUserID => _currentUserID;
  String? get error => _error;
  bool get isTyping => _isTyping;

  // Initialize chat for a conversation
  Future<void> initializeChat(String conversationID) async {
    try {
      _currentConversationID = conversationID;
      _error = null;
      _isLoading = true;
      notifyListeners();

      // Get current user ID
      final userData = await AuthService.getCurrentUser();
      _currentUserID = userData['id'].toString();

      // Connect to WebSocket
      await _chatService.connect(_currentUserID!);

      // Set up WebSocket callbacks
      _chatService.onMessageReceived = _handleNewMessage;
      _chatService.onConnectionStatusChanged = _handleConnectionStatus;
      _chatService.onError = _handleError;

      // Join conversation
      await _chatService.joinConversation(conversationID);

      // Load existing messages
      await loadMessages();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load messages for the current conversation
  Future<void> loadMessages({int limit = 50, int offset = 0}) async {
    if (_currentConversationID == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final messages = await _chatService.getMessagesByConversation(
        _currentConversationID!,
        limit,
        offset,
      );

      if (offset == 0) {
        _messages = messages;
      } else {
        _messages.insertAll(0, messages);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message
  Future<void> sendMessage(
    String content, {
    String messageType = 'text',
    String mediaURL = '',
    List<int> metadata = const [],
    String? replyToMessageID,
  }) async {
    if (_currentUserID == null || _currentConversationID == null) {
      _error = 'Not connected to chat';
      notifyListeners();
      return;
    }

    try {
      final message = await _chatService.sendMessage(
        _currentUserID!,
        _currentConversationID!,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      );

      // Add message to local list for immediate UI feedback
      _messages.add(message);
      notifyListeners();

      // Mark message as read by sender
      await markMessageAsRead(message.id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageID) async {
    if (_currentUserID == null) return;

    try {
      await _chatService.markMessageAsRead(messageID, _currentUserID!);

      // Update local message status
      final index = _messages.indexWhere((msg) => msg.id == messageID);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      // Silently handle read receipt errors
      debugPrint('Failed to mark message as read: $e');
    }
  }

  // Send typing indicator
  void sendTypingIndicator(bool isTyping) {
    if (_currentConversationID == null) return;

    _isTyping = isTyping;
    _chatService.sendTypingIndicator(_currentConversationID!, isTyping);
    notifyListeners();
  }

  // Handle new message from WebSocket
  void _handleNewMessage(Message message) {
    // Only add message if it's for the current conversation
    if (message.conversationID == _currentConversationID) {
      _messages.add(message);
      notifyListeners();

      // Mark as read if it's from another user
      if (message.senderID != _currentUserID) {
        markMessageAsRead(message.id);
      }
    }
  }

  // Handle connection status changes
  void _handleConnectionStatus(String status) {
    _isConnected = status == 'connected';
    notifyListeners();
  }

  // Handle errors
  void _handleError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Disconnect and cleanup
  void disconnect() {
    _chatService.disconnect();
    _messages.clear();
    _isLoading = false;
    _isConnected = false;
    _currentConversationID = null;
    _currentUserID = null;
    _error = null;
    _isTyping = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
