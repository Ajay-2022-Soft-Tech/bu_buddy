// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../models/message_model.dart';
// import '../repository/chat_repository.dart';
//
// class ChatController {
//   final String currentUserId;
//   final String otherUserId;
//   final ChatRepository _chatRepository = ChatRepository();
//
//   ChatController({
//     required this.currentUserId,
//     required this.otherUserId,
//   });
//
//   // Stream chat messages
//   Stream<List<Message>> getChatMessages() {
//     return _chatRepository.getMessages(currentUserId, otherUserId);
//   }
//
//   // Send a text message
//   Future<void> sendMessage(String content, {Map<String, dynamic>? rideDetails}) async {
//     final message = Message(
//       senderId: currentUserId,
//       receiverId: otherUserId,
//       content: content,
//       timestamp: DateTime.now(),
//       attachedRideDetails: rideDetails,
//     );
//     await _chatRepository.sendMessage(message, currentUserId, otherUserId);
//   }
//
//   // Mark messages as read when chat is opened
//   Future<void> markMessagesAsRead() async {
//     await _chatRepository.markMessagesAsRead(currentUserId, otherUserId);
//   }
//
//   // Send a fare proposal
//   Future<void> sendFareProposal(double proposedFare, Map<String, dynamic> rideDetails) async {
//     final content = "💰 I'm proposing a fare of ₹$proposedFare for this ride";
//
//     // Update ride details with proposed fare
//     final updatedRideDetails = Map<String, dynamic>.from(rideDetails);
//     updatedRideDetails['proposedFare'] = proposedFare;
//
//     await sendMessage(content, rideDetails: updatedRideDetails);
//   }
//
//   // Accept or reject a fare proposal
//   Future<void> respondToFareProposal(bool accepted, Message proposalMessage) async {
//     final proposedFare = proposalMessage.attachedRideDetails?['proposedFare'];
//     final responseText = accepted
//         ? "✅ I accept the fare proposal of ₹$proposedFare"
//         : "❌ I cannot accept the fare proposal of ₹$proposedFare";
//
//     await sendMessage(responseText);
//   }
// }
