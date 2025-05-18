import 'package:educonnect/core/themes/color_mangers.dart';
import 'package:educonnect/features/chat/controller/ChatController.dart';
import 'package:educonnect/features/chat/model/chat_message_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupChatScreen extends StatefulWidget {
  final String forumId;
  final String groupName;

  const GroupChatScreen({
    Key? key,
    required this.forumId,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  bool isSendingMessage = false; // Track message sending state
  @override
  void initState() {
    super.initState();

    // Initialize the ChatController if it's not already registered
    if (!Get.isRegistered<ChatController>()) {
      Get.put(ChatController());
    }

    // Load messages with real-time updates
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      // This will set up a real-time listener for messages
      await chatController.loadForumMessages(widget.forumId);
    } catch (e) {
      print("Error loading messages: $e");
      Get.snackbar(
        'Erreur',
        'Impossible de charger les messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear the input field immediately for better UX
    final textToSend = messageText;
    messageController.clear();

    // Set sending state
    setState(() {
      isSendingMessage = true;
    });

    try {
      // Send message using ChatController
      final success = await chatController.sendMessage(
        forumId: widget.forumId,
        message: textToSend,
      );

      if (success) {
        // Scroll to the bottom to show the new message immediately
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0, // Scroll to top (which is bottom when reversed)
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'envoyer le message, veuillez réessayer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white,
        );
      } // We don't need to manually scroll since messages will update from the stream
      // and the list is in reverse order with newest messages at the bottom
    } catch (e) {
      print("Error sending message: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue, veuillez réessayer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isSendingMessage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.lightGrey3,
      appBar: AppBar(
        backgroundColor: ColorManager.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              final membersCount =
                  chatController.currentForum.value?.memberIds.length ?? 0;
              return Text(
                '$membersCount ${membersCount > 1 ? 'membres' : 'membre'}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              );
            }),
          ],
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.refreshCw, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Obx(() {
                    if (chatController.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FeatherIcons.messageCircle,
                              size: 50,
                              color: ColorManager.grey,
                            ),
                            Gap(10),
                            Text(
                              'Aucun message dans ce groupe',
                              style: TextStyle(
                                color: ColorManager.grey,
                                fontSize: 16,
                              ),
                            ),
                            Gap(5),
                            Text(
                              'Envoyez le premier message !',
                              style: TextStyle(
                                color: ColorManager.primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    } // Use ListView.builder for message display
                    return ListView.builder(
                      key: ValueKey<int>(chatController.messages
                          .length), // Add key to force rebuild when messages change
                      controller: scrollController,
                      reverse: true, // Newest messages at the bottom
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: chatController.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatController.messages[index];
                        final bool isMyMessage =
                            message.senderId == currentUserId;

                        return _buildMessageItem(message, isMyMessage);
                      },
                    );
                  }),
          ),

          // Message input
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Add attachment button (can be implemented later)
                IconButton(
                  icon: Icon(FeatherIcons.paperclip, color: ColorManager.grey),
                  onPressed: () {
                    // Implement attachment functionality
                    Get.snackbar(
                      'Information',
                      'L\'ajout de pièces jointes sera disponible prochainement',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                // Text input field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ColorManager.lightGrey3,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ), // Send button
                IconButton(
                  icon: isSendingMessage
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorManager.primaryColor),
                          ),
                        )
                      : Icon(
                          FeatherIcons.send,
                          color: ColorManager.primaryColor,
                        ),
                  onPressed: isSendingMessage ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessageModel message, bool isMyMessage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMyMessage) _buildAvatar(message.senderName),
          SizedBox(width: isMyMessage ? 0 : 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMyMessage)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: ColorManager.grey,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMyMessage ? ColorManager.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isMyMessage
                              ? Colors.white
                              : ColorManager.SoftBlack,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          color: isMyMessage
                              ? Colors.white.withOpacity(0.7)
                              : ColorManager.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (message.attachment != null &&
                    message.attachment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: _buildAttachment(message.attachment!),
                  ),
              ],
            ),
          ),
          SizedBox(width: isMyMessage ? 8 : 0),
          if (isMyMessage) _buildAvatar('Moi'),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .join()
            .toUpperCase()
        : 'U';

    return CircleAvatar(
      radius: 16,
      backgroundColor: ColorManager.primaryColor,
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttachment(String attachmentUrl) {
    // This is a placeholder for attachment display
    // You can implement image preview, file info, etc.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FeatherIcons.paperclip,
            color: ColorManager.primaryColor,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Pièce jointe',
            style: TextStyle(
              color: ColorManager.primaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today, show only time
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      // Yesterday
      return 'Hier, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within a week
      return '${DateFormat('E').format(dateTime)}, ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // Older messages
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  void dispose() {
    // Clean up resources
    messageController.dispose();
    scrollController.dispose();

    // The stream subscription is handled in the ChatController's onClose method
    // We don't need to cancel it here

    super.dispose();
  }
}
