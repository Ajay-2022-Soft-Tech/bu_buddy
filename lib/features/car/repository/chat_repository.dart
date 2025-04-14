// lib/data/repositories/chat/chat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a chat room for a ride
  Future<String?> createChatRoom(String rideId, List<String> participantIds) async {
    try {
      final chatDoc = await _db.collection('chatRooms').add({
        'rideId': rideId,
        'participantIds': participantIds,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      });

      return chatDoc.id;
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }

  // Send a message in a chat room
  Future<bool> sendMessage(String chatRoomId, String message, {Map<String, dynamic>? additionalData}) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Add message to the chat room
      await _db.collection('chatRooms').doc(chatRoomId).collection('messages').add({
        'senderId': currentUser.uid,
        'message': message,
        'data': additionalData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update last message in chat room
      await _db.collection('chatRooms').doc(chatRoomId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUser.uid,
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Get messages for a chat room
  Stream<QuerySnapshot> getChatMessages(String chatRoomId) {
    return _db.collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Get all chat rooms for a user
  Future<List<DocumentSnapshot>> getUserChatRooms() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final chatRoomsSnapshot = await _db.collection('chatRooms')
          .where('participantIds', arrayContains: currentUser.uid)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return chatRoomsSnapshot.docs;
    } catch (e) {
      print('Error getting user chat rooms: $e');
      return [];
    }
  }
}