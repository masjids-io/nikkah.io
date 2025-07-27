import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? chatPartner;

  const ChatScreen({super.key, this.chatPartner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading messages
    await Future.delayed(const Duration(seconds: 1));

    // Sample messages for demonstration
    final sampleMessages = [
      ChatMessage(
        id: '1',
        text: 'Assalamu alaikum! How are you?',
        isFromMe: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '2',
        text: 'Wa alaikum assalam! I\'m doing well, thank you. How about you?',
        isFromMe: true,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        text: 'I\'m good too! I really enjoyed reading your profile.',
        isFromMe: false,
        timestamp:
            DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '4',
        text: 'Thank you! I found your profile very interesting as well.',
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: '5',
        text: 'Would you like to know more about my family background?',
        isFromMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: MessageStatus.sent,
      ),
    ];

    setState(() {
      _messages = sampleMessages;
      _isLoading = false;
    });

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isFromMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate message delivery
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final messageIndex = _messages.indexWhere((m) => m.id == newMessage.id);
        if (messageIndex != -1) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            status: MessageStatus.sent,
          );
        }
      });
    });

    // Simulate message being delivered
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        final messageIndex = _messages.indexWhere((m) => m.id == newMessage.id);
        if (messageIndex != -1) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            status: MessageStatus.delivered,
          );
        }
      });
    });

    // Simulate message being read
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        final messageIndex = _messages.indexWhere((m) => m.id == newMessage.id);
        if (messageIndex != -1) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            status: MessageStatus.read,
          );
        }
      });
    });

    // Simulate reply after some time
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final replyMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _getRandomReply(),
          isFromMe: false,
          timestamp: DateTime.now(),
          status: MessageStatus.read,
        );

        setState(() {
          _messages.add(replyMessage);
        });
        _scrollToBottom();
      }
    });
  }

  String _getRandomReply() {
    final replies = [
      'That sounds great!',
      'I would love to know more about that.',
      'Thank you for sharing that with me.',
      'That\'s very interesting!',
      'I appreciate you telling me about that.',
      'We seem to have a lot in common.',
      'I\'m looking forward to learning more about you.',
    ];
    return replies[DateTime.now().millisecond % replies.length];
  }

  @override
  Widget build(BuildContext context) {
    final chatPartner = widget.chatPartner ??
        {
          'name': 'Sarah Ahmed',
          'age': 25,
          'location': 'London, UK',
        };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                chatPartner['name'].substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatPartner['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${chatPartner['age']} years old • ${chatPartner['location']}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showChatOptions,
            tooltip: 'Chat Options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  )
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessagesList(),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to begin chatting',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showDate = index == 0 ||
            !_isSameDay(message.timestamp, _messages[index - 1].timestamp);

        return Column(
          children: [
            if (showDate) _buildDateDivider(message.timestamp),
            _buildMessageBubble(message),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment:
          message.isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isFromMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isFromMe
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isFromMe
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: message.isFromMe
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isFromMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (message.isFromMe) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatus(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xFF2E7D32);
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              tooltip: 'Send Message',
            ),
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2E7D32)),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to profile view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View Profile coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              onTap: () {
                Navigator.of(context).pop();
                _showBlockConfirmation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report User'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Chat'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
            'Are you sure you want to block this user? You won\'t be able to message them anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User blocked successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
            'Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isFromMe;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isFromMe,
    required this.timestamp,
    required this.status,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isFromMe,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isFromMe: isFromMe ?? this.isFromMe,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}
