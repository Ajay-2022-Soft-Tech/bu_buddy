import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _messagesCollection => _firestore.collection('messages');
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  // Get chat document ID (consistent regardless of who initiated the chat)
  String getChatId(String userId1, String userId2) {
    // Sort IDs alphabetically to ensure consistent chat ID
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Stream chat messages
  Stream<List<Message>> getMessages(String currentUserId, String otherUserId) {
    final chatId = getChatId(currentUserId, otherUserId);

    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList();
    })
        .handleError((error) {
      print("Error streaming messages: $error");
      // Return empty list on error to prevent UI crashes
      return [];
    });
  }


  // Send a message
  Future<void> sendMessage(Message message, String currentUserId, String otherUserId) async {
    final chatId = getChatId(currentUserId, otherUserId);

    // Add message to messages collection
    await _messagesCollection.add({
      'chatId': chatId,
      ...message.toMap(),
    });

    // Update or create chat document (for chat list)
    await _chatsCollection.doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'lastMessage': message.content,
      'lastSenderId': message.senderId,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      'unreadCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    final chatId = getChatId(currentUserId, otherUserId);

    // Get unread messages sent by the other user
    final unreadQuery = await _messagesCollection
        .where('chatId', isEqualTo: chatId)
        .where('senderId', isEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    // Update each message
    final batch = _firestore.batch();
    for (var doc in unreadQuery.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Reset unread count in chat document
    batch.update(_chatsCollection.doc(chatId), {'unreadCount': 0});

    // Commit batch update
    await batch.commit();
  }

  // Get user chats list
  Stream<List<DocumentSnapshot>> getUserChats(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

}
