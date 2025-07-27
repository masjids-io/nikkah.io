# Chat Implementation with WebSocket Support

This document describes the chat functionality implementation for the Nikkah.io app using WebSockets and the provided ChatService interface.

## Architecture Overview

The chat system is built with the following components:

### 1. Models
- **Message**: Represents individual chat messages with all required fields from the ChatService interface
- **Conversation**: Represents chat conversations between users

### 2. Services
- **ChatService**: Implements the ChatService interface with WebSocket support
- **AuthService**: Handles authentication and token management

### 3. Providers
- **ChatProvider**: Manages chat state and integrates with ChatService

### 4. Screens
- **ChatScreen**: Real-time chat interface with WebSocket connection
- **ConversationListScreen**: List of all conversations

## ChatService Interface Implementation

The ChatService class implements the following interface:

```dart
type ChatService interface {
    SendMessage(senderID uuid.UUID, conversationID uuid.UUID, content string, messageType string, mediaURL string, metadata []byte, replyToMessageID *uuid.UUID) (*domain.Message, error)
    GetMessagesByConversation(conversationID uuid.UUID, limit, offset int) ([]domain.Message, error)
    MarkMessageAsRead(messageID uuid.UUID, readerID uuid.UUID) error
}
```

### Key Features

1. **WebSocket Connection**: Real-time bidirectional communication
2. **Message Sending**: Via WebSocket for immediate delivery
3. **Message Retrieval**: Via REST API for initial load and pagination
4. **Read Receipts**: Automatic marking of messages as read
5. **Typing Indicators**: Real-time typing status updates
6. **Error Handling**: Comprehensive error handling and user feedback
7. **Connection Status**: Visual indicators for connection state

## WebSocket Protocol

### Connection
```
wss://api.nikkah.io/ws?token={access_token}&user_id={user_id}
```

### Message Types

#### Send Message
```json
{
  "type": "send_message",
  "sender_id": "uuid",
  "conversation_id": "uuid",
  "content": "message content",
  "message_type": "text",
  "media_url": "",
  "metadata": [],
  "reply_to_message_id": null
}
```

#### Join Conversation
```json
{
  "type": "join_conversation",
  "conversation_id": "uuid"
}
```

#### Mark Read
```json
{
  "type": "mark_read",
  "message_id": "uuid",
  "reader_id": "uuid"
}
```

#### Typing Indicator
```json
{
  "type": "typing_indicator",
  "conversation_id": "uuid",
  "is_typing": true
}
```

### Incoming Messages

#### New Message
```json
{
  "type": "new_message",
  "message": {
    "id": "uuid",
    "sender_id": "uuid",
    "conversation_id": "uuid",
    "content": "message content",
    "message_type": "text",
    "media_url": null,
    "metadata": null,
    "reply_to_message_id": null,
    "timestamp": "2024-01-01T12:00:00Z",
    "is_read": false,
    "read_at": null
  }
}
```

## Usage

### Starting a Chat
```dart
// Navigate to chat screen
Navigator.pushNamed(
  context,
  '/chat',
  arguments: {
    'conversationID': 'conversation-uuid',
    'chatPartner': {
      'name': 'Partner Name',
      'age': 25,
      'location': 'City, Country',
    },
  },
);
```

### Sending Messages
```dart
// Send a text message
context.read<ChatProvider>().sendMessage('Hello!');

// Send with custom parameters
context.read<ChatProvider>().sendMessage(
  'Hello!',
  messageType: 'text',
  mediaURL: '',
  metadata: [],
  replyToMessageID: null,
);
```

### Listening to Messages
```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    return ListView.builder(
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return MessageBubble(message: message);
      },
    );
  },
);
```

## State Management

The ChatProvider manages the following state:

- **messages**: List of messages in current conversation
- **isLoading**: Loading state for API calls
- **isConnected**: WebSocket connection status
- **currentConversationID**: ID of current conversation
- **currentUserID**: ID of current user
- **error**: Error messages
- **isTyping**: Typing indicator status

## Error Handling

The implementation includes comprehensive error handling:

1. **Connection Errors**: Automatic reconnection attempts
2. **Authentication Errors**: Token refresh and re-authentication
3. **Network Errors**: User-friendly error messages
4. **Message Errors**: Graceful degradation for failed messages

## Security

1. **Authentication**: All WebSocket connections require valid access tokens
2. **Authorization**: Users can only access conversations they're participants in
3. **Input Validation**: All message content is validated before sending
4. **Rate Limiting**: Implemented on the server side

## Performance Considerations

1. **Message Pagination**: Load messages in chunks to avoid memory issues
2. **Connection Pooling**: Efficient WebSocket connection management
3. **Message Caching**: Local storage for offline message viewing
4. **Typing Debouncing**: Prevent excessive typing indicator updates

## Testing

The implementation includes:

1. **Unit Tests**: For ChatService and ChatProvider
2. **Widget Tests**: For ChatScreen and ConversationListScreen
3. **Integration Tests**: For end-to-end chat functionality

## Future Enhancements

1. **Message Encryption**: End-to-end encryption for messages
2. **File Sharing**: Support for images, documents, and voice messages
3. **Group Chats**: Support for multi-participant conversations
4. **Message Search**: Full-text search within conversations
5. **Message Reactions**: Emoji reactions to messages
6. **Message Threading**: Reply threads within conversations
7. **Push Notifications**: Real-time notifications for new messages
8. **Offline Support**: Message queuing and sync when online

## Dependencies

```yaml
dependencies:
  web_socket_channel: ^2.4.0
  uuid: ^4.2.1
  provider: ^6.1.1
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
```

## API Endpoints

### REST API
- `GET /v1/conversations/{conversationID}/messages` - Get messages
- `PUT /v1/messages/{messageID}/read` - Mark message as read

### WebSocket
- `wss://api.nikkah.io/ws` - WebSocket endpoint for real-time communication 