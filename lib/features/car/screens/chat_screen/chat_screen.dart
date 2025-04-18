import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final Map<String, dynamic> rideDetails;

  const ChatScreen({
    Key? key,
    required this.receiverId,
    required this.receiverName,
    required this.rideDetails,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _attachmentAnimationController;
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonAnimation;

  bool _isAttachmentVisible = false;
  bool _isSending = false;
  bool _isTyping = false;
  bool _isEmojiVisible = false;
  bool _isIndexCreated = false;
  bool _isOnline = true; // Simulate online status
  bool _imageUploading = false;

  // Pagination variables
  int _messageLimit = 20;
  bool _isLoadingMore = false;
  List<DocumentSnapshot> _messages = [];
  bool _hasMoreMessages = true;
  DocumentSnapshot? _lastDocument;

  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
  String get _chatId => getChatId(_currentUserId, widget.receiverId);

  // Local messages for optimistic UI updates
  List<Map<String, dynamic>> _localMessages = [];

  // Stream subscription for new messages
  StreamSubscription? _newMessagesSubscription;

  // Get a consistent chat ID regardless of who initiates the chat
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort to ensure consistency
    return '${ids[0]}_${ids[1]}';
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _attachmentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sendButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Listen for text changes to animate send button
    _messageController.addListener(_onTextChanged);

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);

    // Setup Firebase offline persistence
    _setupOfflineCache();

    // Load initial messages
    _loadInitialMessages();

    // Setup real-time listener for new messages
    _setupMessageListener();

    // Send ride details message if this is a new chat
    _checkAndSendRideDetails();

    // Auto-scroll to bottom when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Listen for keyboard focus to scroll when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });

    // Simulate typing status after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = true);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _isTyping = false);
          }
        });
      }
    });
  }

  void _setupOfflineCache() {
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  void _setupMessageListener() {
    // Listen for new messages
    _newMessagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty && mounted) {
        final newDoc = snapshot.docs.first;
        final newMessage = newDoc.data();
        final messageId = newDoc.id;

        // Check if this is actually a new message and not already in our list
        if (!_messages.any((doc) => doc.id == messageId) &&
            !_localMessages.any((msg) => msg['id'] == messageId)) {

          // Add to local messages for immediate UI update
          setState(() {
            _localMessages.insert(0, {...newMessage, 'id': messageId});
          });

          // If it's a new message from the other person, mark as read
          if (newMessage['senderId'] != _currentUserId) {
            _markMessageAsRead(messageId);
          }

          // Scroll to bottom if we're already near the bottom
          if (_isNearBottom()) {
            _scrollToBottom();
          }
        }
      }
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return maxScroll - currentScroll < 200;
  }

  Future<void> _markMessageAsRead(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> _loadInitialMessages() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(_messageLimit)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _messages = querySnapshot.docs;
          _lastDocument = querySnapshot.docs.last;
          _hasMoreMessages = querySnapshot.docs.length >= _messageLimit;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading messages: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreMessages) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || _lastDocument == null) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_messageLimit)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _messages.addAll(querySnapshot.docs);
          _lastDocument = querySnapshot.docs.last;
          _hasMoreMessages = querySnapshot.docs.length >= _messageLimit;
        });
      } else {
        setState(() {
          _hasMoreMessages = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error loading more messages: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onTextChanged() {
    final hasText = _messageController.text.isNotEmpty;
    if (hasText && !_sendButtonAnimationController.isCompleted) {
      _sendButtonAnimationController.forward();
    } else if (!hasText && _sendButtonAnimationController.isCompleted) {
      _sendButtonAnimationController.reverse();
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    _fabAnimationController.dispose();
    _attachmentAnimationController.dispose();
    _sendButtonAnimationController.dispose();
    _newMessagesSubscription?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // Since we're using descending order, 0 is the bottom
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _checkAndSendRideDetails() async {
    try {
      final messagesRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages');

      final snapshot = await messagesRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        _sendRideDetailsMessage();
      }
    } catch (e) {
      print('Error checking chat history: $e');
    }
  }

  void _sendRideDetailsMessage() {
    final from = widget.rideDetails['from'] ?? 'Unknown location';
    final to = widget.rideDetails['to'] ?? 'Unknown destination';
    final time = widget.rideDetails['time'] ?? 'Not specified';
    final price = widget.rideDetails['price'] ?? 'Not specified';

    final message =
        "🚗 Ride Details:\n"
        "From: $from\n"
        "To: $to\n"
        "Time: $time\n"
        "Share Cost: $price";

    _sendMessage(message, messageType: 'ride_details');
  }

  Future<void> _sendMessage(String text, {String messageType = 'text'}) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Trigger haptic feedback for better user experience
    HapticFeedback.lightImpact();

    // Generate a unique message ID
    final messageId = FirebaseFirestore.instance.collection('chats').doc().id;
    final timestamp = Timestamp.now();

    // Create message data
    final messageData = {
      'id': messageId,
      'chatId': _chatId,
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'text': text,
      'timestamp': timestamp,
      'type': messageType,
      'isRead': false,
      'isPending': true,
    };

    // Add to local messages for optimistic UI update
    setState(() {
      _localMessages.insert(0, messageData);
    });

    try {
      // Actually send to Firebase
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'chatId': _chatId,
        'senderId': _currentUserId,
        'receiverId': widget.receiverId,
        'text': text,
        'timestamp': timestamp,
        'type': messageType,
        'isRead': false,
      });

      // Update chat metadata
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .set({
        'participants': [_currentUserId, widget.receiverId],
        'lastMessage': text,
        'lastMessageTime': timestamp,
        'lastSenderId': _currentUserId,
        'ride': widget.rideDetails,
      }, SetOptions(merge: true));

      // Update local message to remove pending state
      setState(() {
        final index = _localMessages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          _localMessages[index]['isPending'] = false;
        }
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      // Mark message as failed in local state
      setState(() {
        final index = _localMessages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          _localMessages[index]['isFailed'] = true;
          _localMessages[index]['isPending'] = false;
        }
      });
      _showErrorSnackBar('Failed to send message: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _resendFailedMessage(Map<String, dynamic> failedMessage) async {
    // Remove the failed message
    setState(() {
      _localMessages.removeWhere((msg) => msg['id'] == failedMessage['id']);
    });

    // Resend with the same content
    await _sendMessage(
      failedMessage['text'],
      messageType: failedMessage['type'],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(10),
        elevation: 6,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _sendLocationMessage() async {
    try {
      final status = await Permission.location.request();
      if (status.isDenied) {
        _showErrorSnackBar('Location permission is required to share location');
        return;
      }

      setState(() => _isSending = true);

      // This would normally connect to device location
      // Simulating location share for demonstration
      _sendMessage("📍 Current Location: https://maps.google.com/?q=28.6139,77.2090",
          messageType: 'location');
    } catch (e) {
      _showErrorSnackBar('Error accessing location: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _takePicture() async {
    try {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        _showErrorSnackBar('Camera permission is required to take pictures');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        await _uploadAndSendImage(File(photo.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take picture: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        _showErrorSnackBar('Gallery permission is required to select photos');
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        await _uploadAndSendImage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<File> _compressImage(File imageFile) async {
    // This would normally use a compression library like flutter_image_compress
    // For now, we'll just return the original file
    return imageFile;
  }

  Future<void> _uploadAndSendImage(File imageFile) async {
    try {
      setState(() => _imageUploading = true);

      // Compress image before uploading
      final compressedFile = await _compressImage(imageFile);

      // Upload to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(_chatId)
          .child(fileName);

      final uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Send image message
      await _sendMessage(downloadUrl, messageType: 'image');
    } catch (e) {
      _showErrorSnackBar('Failed to upload image: $e');
    } finally {
      if (mounted) setState(() => _imageUploading = false);
    }
  }

  void _proposeNewFare() {
    final TextEditingController fareController = TextEditingController();
    String currentPrice = widget.rideDetails['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '';
    if (currentPrice.isNotEmpty) {
      fareController.text = currentPrice;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFareProposalSheet(context, fareController),
    );
  }

  Widget _buildFareProposalSheet(BuildContext context, TextEditingController fareController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, -1),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 40,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Text(
              'Propose New Cost Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: fareController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter new cost amount',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    fontWeight: FontWeight.normal,
                  ),
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                autofocus: true,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final proposedFare = fareController.text;
                      if (proposedFare.isNotEmpty) {
                        _sendMessage("💰 I propose a new cost share of ₹$proposedFare",
                            messageType: 'fare_proposal');
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Propose', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(String message, bool isMe, String messageId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 40,
              margin: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            ListTile(
              leading: Icon(Icons.reply, color: TColors.primary),
              title: Text('Reply', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                // Reply logic would be implemented here
              },
            ),
            ListTile(
              leading: Icon(Icons.content_copy, color: Colors.blue),
              title: Text('Copy', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(10),
                  ),
                );
              },
            ),
            if (isMe)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(messageId);
                },
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      // Remove from local messages first for immediate UI update
      setState(() {
        _localMessages.removeWhere((msg) => msg['id'] == messageId);
      });

      // Then delete from Firebase
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Refresh messages list
      _loadInitialMessages();

    } catch (e) {
      _showErrorSnackBar('Failed to delete message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: Stack(
        children: [
          Column(
            children: [
              _buildRideDetailsBanner(isDark),

              if (_isTyping) _buildTypingIndicator(isDark),

              Expanded(
                child: _buildMessagesList(isDark),
              ),

              // Fix for opacity issue in TweenAnimationBuilder
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isAttachmentVisible ? 120 : 0,
                child: _isAttachmentVisible
                    ? _buildAttachmentOptions(isDark)
                    : SizedBox.shrink(),
              ),

              _buildMessageInput(isDark),
            ],
          ),

          if (_imageUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Uploading image...", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(isDark),
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    // Fixed opacity calculation to ensure value is between 0.0 and 1.0
    final opacity = _scrollController.hasClients && _scrollController.offset > 200 ? 1.0 : 0.0;

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0), // Ensure opacity is within valid range
      child: IgnorePointer(
        ignoring: opacity < 0.1,
        child: FloatingActionButton(
          mini: true,
          backgroundColor: TColors.primary,
          onPressed: _scrollToBottom,
          child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: TColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: InkWell(
        onTap: () => _showRideDetailsBottomSheet(context, isDark),
        borderRadius: BorderRadius.circular(30),
        child: Row(
          children: [
            Hero(
              tag: 'profile_${widget.receiverId}',
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        _isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: IconButton(
            icon: Icon(Icons.call, size: 18, color: Colors.white),
            onPressed: () {
              // Call functionality would be implemented here
              HapticFeedback.mediumImpact();
              _showCallDialog();
            },
          ),
        ),
        SizedBox(width: 8),
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: IconButton(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.white),
            onPressed: () => _showRideDetailsBottomSheet(context, isDark),
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${widget.receiverName}'),
        content: Text('This will initiate a call to ${widget.receiverName}. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
              _sendMessage("📞 Tried to call you", messageType: 'call_log');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call initiated to ${widget.receiverName}'),
                ),
              );
            },
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsBanner(bool isDark) {
    return Material(
      color: isDark ? Colors.grey.shade800 : TColors.primary.withOpacity(0.1),
      child: InkWell(
        onTap: () => _showRideDetailsBottomSheet(context, isDark),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: TColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip Details",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${widget.rideDetails['from'] ?? 'Unknown'} → ${widget.rideDetails['to'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : TColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.green.withOpacity(isDark ? 0.4 : 0.2),
                  ),
                ),
                child: Text(
                  widget.rideDetails['price'] ?? 'Not specified',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: TColors.primary.withOpacity(isDark ? 0.3 : 0.2),
            child: Icon(Icons.person, size: 12, color: TColors.primary),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('Typing', style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                )),
                SizedBox(width: 5),
                SizedBox(
                  width: 20,
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText('...',
                        speed: Duration(milliseconds: 200),
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                    repeatForever: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    // Combine Firebase messages and local messages
    List<dynamic> allMessages = [];

    // Add Firebase messages
    for (var doc in _messages) {
      final data = doc.data() as Map<String, dynamic>;
      allMessages.add({
        ...data,
        'id': doc.id,
        'isFirebase': true,
      });
    }

    // Add local messages that aren't already in Firebase messages
    for (var localMsg in _localMessages) {
      if (!allMessages.any((msg) => msg['id'] == localMsg['id'])) {
        allMessages.add({
          ...localMsg,
          'isFirebase': false,
        });
      }
    }

    // Sort by timestamp, newest first (since we're using descending order)
    allMessages.sort((a, b) {
      final aTime = a['timestamp'] as Timestamp;
      final bTime = b['timestamp'] as Timestamp;
      return bTime.compareTo(aTime);
    });

    if (_isLoadingMore && allMessages.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (allMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_l5qvxwtf.json',
              width: 150,
              height: 150,
            ),
            Text(
              "Start the conversation!",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          reverse: true, // Display newest messages at the bottom
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: BouncingScrollPhysics(),
          itemCount: allMessages.length + (_hasMoreMessages ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the end of the list
            if (_hasMoreMessages && index == allMessages.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }

            final message = allMessages[index];
            final isMe = message['senderId'] == _currentUserId;
            final messageType = message['type'] ?? 'text';
            final timestamp = (message['timestamp'] as Timestamp).toDate();
            final isPending = message['isPending'] ?? false;
            final isFailed = message['isFailed'] ?? false;
            final messageId = message['id'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildMessageItem(
                message: message['text'] ?? '',
                isMe: isMe,
                timestamp: timestamp,
                messageType: messageType,
                isDark: isDark,
                isPending: isPending,
                isFailed: isFailed,
                messageId: messageId,
                isLastMessage: index == 0,
              ),
            );
          },
        ),

        // Loading more indicator at the top
        if (_isLoadingMore)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessageItem({
    required String message,
    required bool isMe,
    required DateTime timestamp,
    required String messageType,
    required bool isDark,
    required bool isPending,
    required bool isFailed,
    required String messageId,
    required bool isLastMessage,
  }) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showMessageOptions(message, isMe, messageId);
      },
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(isDark),

          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isMe ? 40 : 0,
                right: isMe ? 0 : 40,
              ),
              child: _buildMessageBubble(
                message: message,
                isMe: isMe,
                timestamp: timestamp,
                messageType: messageType,
                isDark: isDark,
                isPending: isPending,
                isFailed: isFailed,
                messageId: messageId,
                isLastMessage: isLastMessage,
              ),
            ),
          ),

          if (isMe) SizedBox(width: 4),
          if (isMe) _buildAvatar(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required DateTime timestamp,
    required String messageType,
    required bool isDark,
    required bool isPending,
    required bool isFailed,
    required String messageId,
    required bool isLastMessage,
  }) {
    final time = DateFormat('h:mm a').format(timestamp);
    final isSpecialMessage = messageType != 'text';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _getBubbleColor(isMe, messageType, isDark),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: isMe ? Radius.circular(20) : Radius.circular(5),
          bottomRight: isMe ? Radius.circular(5) : Radius.circular(20),
        ),
        border: isSpecialMessage ? Border.all(
          color: _getSpecialBorderColor(messageType, isDark),
          width: 1.5,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageContent(message, messageType, isDark, isMe),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  // Fixed opacity clamping
                  color: isMe
                      ? Colors.white.withOpacity(0.7.clamp(0.0, 1.0))
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  fontSize: 11,
                ),
              ),
              if (isMe) SizedBox(width: 4),
              if (isMe && isFailed)
                GestureDetector(
                  onTap: () {
                    // Find the failed message in local messages
                    final failedMessage = _localMessages.firstWhere(
                          (msg) => msg['id'] == messageId,
                      orElse: () => {},
                    );

                    if (failedMessage.isNotEmpty) {
                      _resendFailedMessage(failedMessage);
                    }
                  },
                  child: Icon(
                    Icons.error_outline,
                    size: 14,
                    color: Colors.red.shade300,
                  ),
                )
              else if (isMe && isPending)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      // Fixed opacity clamping
                      Colors.white.withOpacity(0.7.clamp(0.0, 1.0)),
                    ),
                  ),
                )
              else if (isMe)
                  Icon(
                    isLastMessage ? Icons.done_all : Icons.check,
                    size: 12,
                    // Fixed opacity handling
                    color: isLastMessage
                        ? Colors.blue.shade300
                        : Colors.white.withOpacity(0.7.clamp(0.0, 1.0)),
                  ),
            ],
          ),

          if (messageType == 'fare_proposal' && !isMe)
            _buildFareProposalActions(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageContent(String message, String messageType, bool isDark, bool isMe) {
    switch (messageType) {
      case 'image':
        return _buildImageMessage(message);
      case 'location':
        return _buildLocationMessage(message, isDark);
      case 'call_log':
        return Row(
          children: [
            Icon(
              Icons.call,
              size: 16,
              color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        );
      default:
        return Flexible(
          child: Text(
            message,
            style: TextStyle(
              color: isMe
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
              fontSize: 15,
            ),
            overflow: TextOverflow.visible,
          ),
        );
    }
  }

  Widget _buildImageMessage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Show full-screen image
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.error_outline, color: Colors.red),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Photo",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(String message, bool isDark) {
    final urlPattern = RegExp(r'https?://[^\s]+');
    final match = urlPattern.firstMatch(message);
    final url = match != null ? match.group(0) : null;

    return GestureDetector(
      onTap: () {
        if (url != null) {
          // Open map URL - would use url_launcher package
          print('Would open: $url');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Tap to open map",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: TColors.primary.withOpacity((isDark ? 0.3 : 0.2).clamp(0.0, 1.0)),
        child: Icon(
          Icons.person,
          size: 14,
          color: TColors.primary,
        ),
      ),
    );
  }

  Color _getBubbleColor(bool isMe, String messageType, bool isDark) {
    if (isMe) return TColors.primary;

    switch (messageType) {
      case 'ride_details':
        return isDark ? Colors.indigo.shade900 : Colors.indigo.shade50;
      case 'location':
        return isDark ? Colors.green.shade900 : Colors.green.shade50;
      case 'fare_proposal':
        return isDark ? Colors.orange.shade900 : Colors.orange.shade50;
      case 'image':
        return isDark ? Colors.purple.shade900 : Colors.purple.shade50;
      case 'call_log':
        return isDark ? Colors.blue.shade900 : Colors.blue.shade50;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }

  Color _getSpecialBorderColor(String messageType, bool isDark) {
    switch (messageType) {
      case 'ride_details':
        return isDark ? Colors.indigo.shade400 : Colors.indigo.shade300;
      case 'location':
        return isDark ? Colors.green.shade400 : Colors.green.shade300;
      case 'fare_proposal':
        return isDark ? Colors.orange.shade400 : Colors.orange.shade300;
      case 'image':
        return isDark ? Colors.purple.shade400 : Colors.purple.shade300;
      case 'call_log':
        return isDark ? Colors.blue.shade400 : Colors.blue.shade300;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildFareProposalActions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                _sendMessage("✅ I've accepted your cost proposal",
                    messageType: 'fare_response');
                HapticFeedback.mediumImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14),
                  SizedBox(width: 4),
                  Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                _sendMessage("❌ I cannot accept your cost proposal",
                    messageType: 'fare_response');
                HapticFeedback.mediumImpact();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 14),
                  SizedBox(width: 4),
                  Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptions(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            isDark: isDark,
            icon: Icons.location_on,
            label: 'Location',
            color: Colors.red,
            onTap: _sendLocationMessage,
          ),
          _buildAttachmentOption(
            isDark: isDark,
            icon: Icons.attach_money,
            label: 'New Cost',
            color: Colors.green,
            onTap: _proposeNewFare,
          ),
          _buildAttachmentOption(
            isDark: isDark,
            icon: Icons.image,
            label: 'Gallery',
            color: Colors.blue,
            onTap: _pickImage,
          ),
          _buildAttachmentOption(
            isDark: isDark,
            icon: Icons.camera_alt,
            label: 'Camera',
            color: Colors.purple,
            onTap: _takePicture,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              // Fixed opacity calculation
              color: color.withOpacity(0.1.clamp(0.0, 1.0)),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3.clamp(0.0, 1.0)),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    final bool hasText = _messageController.text.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isAttachmentVisible = !_isAttachmentVisible;
                    // Close emoji picker if open
                    if (_isEmojiVisible) {
                      _isEmojiVisible = false;
                    }
                  });
                  HapticFeedback.lightImpact();
                  if (_isAttachmentVisible) {
                    _attachmentAnimationController.forward();
                  } else {
                    _attachmentAnimationController.reverse();
                  }
                },
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _attachmentAnimationController,
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
                splashRadius: 20,
              ),
            ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (text) {
                          // Force rebuild to update send button state
                          setState(() {});
                        },
                        onTap: () {
                          // Hide emoji picker if visible
                          if (_isEmojiVisible) {
                            setState(() => _isEmojiVisible = false);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEmojiVisible
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEmojiVisible = !_isEmojiVisible;
                          _isAttachmentVisible = false;
                          _attachmentAnimationController.reverse();

                          if (_isEmojiVisible) {
                            // Hide keyboard when showing emoji picker
                            FocusScope.of(context).unfocus();
                          } else {
                            // Show keyboard when hiding emoji picker
                            FocusScope.of(context).requestFocus(_focusNode);
                          }
                        });
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8),

            // Send button
            Builder(
              builder: (context) {
                // Fixed animation scale calculation
                final scale = hasText
                    ? (0.8 + ((_sendButtonAnimation.value * 0.2).clamp(0.0, 0.2)))
                    : 0.8;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasText ? TColors.primary : TColors.primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: hasText ? [
                        BoxShadow(
                          color: TColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ] : [],
                    ),
                    child: IconButton(
                      onPressed: (_isSending || !hasText)
                          ? null
                          : () {
                        HapticFeedback.mediumImpact();
                        _sendMessage(_messageController.text.trim());
                      },
                      icon: _isSending
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.all(0),
                      splashRadius: 20,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRideDetailsBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle indicator
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom: 8),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ride Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Ride Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildRideInfoRow(
                    icon: Icons.location_on,
                    title: 'From',
                    value: widget.rideDetails['from'] ?? 'Not specified',
                    iconColor: Colors.blue,
                    isDark: isDark,
                  ),
                  SizedBox(height: 15),
                  _buildRideInfoRow(
                    icon: Icons.flag,
                    title: 'To',
                    value: widget.rideDetails['to'] ?? 'Not specified',
                    iconColor: Colors.red,
                    isDark: isDark,
                  ),
                  SizedBox(height: 15),
                  _buildRideInfoRow(
                    icon: Icons.access_time,
                    title: 'Time',
                    value: widget.rideDetails['time'] ?? 'Not specified',
                    iconColor: Colors.purple,
                    isDark: isDark,
                  ),
                  SizedBox(height: 15),
                  _buildRideInfoRow(
                    icon: Icons.person,
                    title: 'Seats',
                    value: widget.rideDetails['seats'] ?? 'Not specified',
                    iconColor: Colors.orange,
                    isDark: isDark,
                  ),
                  SizedBox(height: 15),
                  _buildRideInfoRow(
                    icon: Icons.attach_money,
                    title: 'Cost Share',
                    value: widget.rideDetails['price'] ?? 'Not specified',
                    iconColor: Colors.green,
                    isDark: isDark,
                  ),
                  SizedBox(height: 15),
                  _buildRideInfoRow(
                    icon: Icons.person,
                    title: 'Student',
                    value: widget.rideDetails['student'] ?? widget.receiverName,
                    iconColor: TColors.primary,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _proposeNewFare();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Negotiate Cost',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showCallDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 50),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Call Student',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            // Fixed opacity calculation
            color: iconColor.withOpacity(0.1.clamp(0.0, 1.0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
