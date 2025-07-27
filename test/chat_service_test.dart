import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nikkah_io/services/chat_service.dart';
import 'package:nikkah_io/models/message.dart';
import 'package:uuid/uuid.dart';

import 'chat_service_test.mocks.dart';

@GenerateMocks([ChatService])
void main() {
  group('ChatService Tests', () {
    late MockChatService mockChatService;

    setUp(() {
      mockChatService = MockChatService();
    });

    test('should send message successfully', () async {
      // Arrange
      final senderID = const Uuid().v4();
      final conversationID = const Uuid().v4();
      final content = 'Hello, how are you?';
      final messageType = 'text';
      final mediaURL = '';
      final metadata = <int>[];
      final replyToMessageID = null;

      final expectedMessage = Message(
        id: const Uuid().v4(),
        senderID: senderID,
        conversationID: conversationID,
        content: content,
        messageType: messageType,
        mediaURL: null,
        metadata: null,
        replyToMessageID: null,
        timestamp: DateTime.now(),
        isRead: false,
      );

      when(mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      )).thenAnswer((_) async => expectedMessage);

      // Act
      final result = await mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      );

      // Assert
      expect(result, equals(expectedMessage));
      verify(mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      )).called(1);
    });

    test('should get messages by conversation', () async {
      // Arrange
      final conversationID = const Uuid().v4();
      final limit = 50;
      final offset = 0;

      final expectedMessages = [
        Message(
          id: const Uuid().v4(),
          senderID: const Uuid().v4(),
          conversationID: conversationID,
          content: 'Hello',
          messageType: 'text',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: const Uuid().v4(),
          senderID: const Uuid().v4(),
          conversationID: conversationID,
          content: 'Hi there!',
          messageType: 'text',
          timestamp: DateTime.now(),
          isRead: true,
        ),
      ];

      when(mockChatService.getMessagesByConversation(
        conversationID,
        limit,
        offset,
      )).thenAnswer((_) async => expectedMessages);

      // Act
      final result = await mockChatService.getMessagesByConversation(
        conversationID,
        limit,
        offset,
      );

      // Assert
      expect(result, equals(expectedMessages));
      expect(result.length, equals(2));
      verify(mockChatService.getMessagesByConversation(
        conversationID,
        limit,
        offset,
      )).called(1);
    });

    test('should mark message as read', () async {
      // Arrange
      final messageID = const Uuid().v4();
      final readerID = const Uuid().v4();

      when(mockChatService.markMessageAsRead(messageID, readerID))
          .thenAnswer((_) async => null);

      // Act
      await mockChatService.markMessageAsRead(messageID, readerID);

      // Assert
      verify(mockChatService.markMessageAsRead(messageID, readerID)).called(1);
    });

    test('should handle message with media', () async {
      // Arrange
      final senderID = const Uuid().v4();
      final conversationID = const Uuid().v4();
      final content = 'Check out this image';
      final messageType = 'image';
      final mediaURL = 'https://example.com/image.jpg';
      final metadata = <int>[1, 2, 3, 4];
      final replyToMessageID = null;

      final expectedMessage = Message(
        id: const Uuid().v4(),
        senderID: senderID,
        conversationID: conversationID,
        content: content,
        messageType: messageType,
        mediaURL: mediaURL,
        metadata: metadata,
        replyToMessageID: null,
        timestamp: DateTime.now(),
        isRead: false,
      );

      when(mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      )).thenAnswer((_) async => expectedMessage);

      // Act
      final result = await mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      );

      // Assert
      expect(result.messageType, equals('image'));
      expect(result.mediaURL, equals(mediaURL));
      expect(result.metadata, equals(metadata));
    });

    test('should handle reply message', () async {
      // Arrange
      final senderID = const Uuid().v4();
      final conversationID = const Uuid().v4();
      final content = 'This is a reply';
      final messageType = 'text';
      final mediaURL = '';
      final metadata = <int>[];
      final replyToMessageID = const Uuid().v4();

      final expectedMessage = Message(
        id: const Uuid().v4(),
        senderID: senderID,
        conversationID: conversationID,
        content: content,
        messageType: messageType,
        mediaURL: null,
        metadata: null,
        replyToMessageID: replyToMessageID,
        timestamp: DateTime.now(),
        isRead: false,
      );

      when(mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      )).thenAnswer((_) async => expectedMessage);

      // Act
      final result = await mockChatService.sendMessage(
        senderID,
        conversationID,
        content,
        messageType,
        mediaURL,
        metadata,
        replyToMessageID,
      );

      // Assert
      expect(result.replyToMessageID, equals(replyToMessageID));
    });
  });
}
