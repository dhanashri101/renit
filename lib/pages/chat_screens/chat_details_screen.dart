import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:intl/intl.dart';
import 'package:rentit24/pages/chat_screens/profile.dart';

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;
  final bool isRead;

  ChatMessage({required this.text, required this.time, required this.isMe, this.isRead = false});
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String avatar;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    this.avatar = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100'
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;

  List<ChatMessage> messages = [
    ChatMessage(text: "Hi, is the wheelchair available?", time: "13:05", isMe: false),
    ChatMessage(text: "for 15 days", time: "13:05", isMe: false),
    ChatMessage(text: "Yes it is available", time: "13:15", isMe: true, isRead: true),
    ChatMessage(text: "cool", time: "13:05", isMe: false),
    ChatMessage(text: "Is the wheelchair working properly?", time: "13:05", isMe: false),
    ChatMessage(text: "wheelchair is working properly, not used since 3 months", time: "13:25", isMe: true, isRead: true),
    ChatMessage(text: "all the wheels are in good condition?", time: "13:15", isMe: false),
    ChatMessage(text: "The wheelchair is in good condition", time: "13:25", isMe: true, isRead: true),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);

    setState(() {
      messages.add(
        ChatMessage(text: _messageController.text.trim(), time: timeString, isMe: true)
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _handleAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening file picker...")),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recording started... Tap again to send.")),
      );
    } else {
      final timeString = DateFormat('HH:mm').format(DateTime.now());
      setState(() {
        messages.add(
          ChatMessage(text: "🎤 Voice Message (0:05)", time: timeString, isMe: true)
        );
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreenchat(
          userName: widget.userName,
          avatar: widget.avatar,
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'important':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Marked as important")),
        );
        break;
      case 'contact':
        _openProfile();
        break;
      case 'select_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All messages selected")),
        );
        break;
      case 'delete':
        _confirmDeleteChat();
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User reported")),
        );
        break;
      case 'safety':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Opening safety tips...")),
        );
        break;
      case 'block':
        _confirmBlockUser();
        break;
    }
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete chat"),
        content: const Text("Are you sure you want to delete this chat? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => messages.clear());
            },
            child: Text("Delete", style: TextStyle(color: AppColors.error500)),
          ),
        ],
      ),
    );
  }

  void _confirmBlockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Block ${widget.userName}"),
        content: const Text("Blocked users won't be able to message you or view your ads."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Block", style: TextStyle(color: AppColors.error500)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBlue = AppTheme.primaryBlue;
    final textColor = isDark ? AppColors.baseWhite : AppColors.neutral900;
    final subTextColor = isDark ? AppColors.neutral400 : AppColors.neutral500;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: _openProfile,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(widget.avatar)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: AppTypography.bodyLarge(AppTypography.semibold, textColor),
                  ),
                  Text(
                    "Online",
                    style: AppTypography.bodySmall(AppTypography.regular, subTextColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textColor),
            color: isDark ? AppTheme.darkSurface : AppColors.baseWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              _buildMenuItem('important', Icons.push_pin_outlined, 'Mark as important', isDark),
              _buildMenuItem('contact', Icons.person_outline, 'View contact', isDark),
              _buildMenuItem('select_all', Icons.checklist_outlined, 'Select all', isDark),
              _buildMenuItem('delete', Icons.delete_outline, 'Delete chat', isDark),
              _buildMenuItem('report', Icons.flag_outlined, 'Report user', isDark),
              _buildMenuItem('safety', Icons.shield_outlined, 'Safety tips', isDark),
              _buildMenuItem('block', Icons.block, 'Block user', isDark, isDestructive: true),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: isDark ? AppColors.neutral700 : AppColors.neutral100, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppColors.baseWhite.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.neutral300, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Sharing personal information such as your phone number, ID, password, or security PIN is strictly prohibited according to our app's terms and conditions. If you choose to share any of this information, our app cannot be held responsible.",
                    style: AppTypography.bodyExtraSmall(
                      AppTypography.regular,
                      isDark ? AppColors.neutral400 : AppColors.neutral300,
                    ).copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(
                  context,
                  msg.text,
                  msg.time,
                  msg.isMe,
                  isDark,
                  primaryBlue,
                  isRead: msg.isRead
                );
              },
            ),
          ),
          _buildMessageComposer(context, isDark, primaryBlue),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String label, bool isDark, {bool isDestructive = false}) {
    final color = isDestructive ? AppColors.error500 : (isDark ? AppColors.baseWhite : AppColors.neutral900);
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.bodyMedium(AppTypography.regular, color)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String message, String time, bool isMe, bool isDark, Color primaryBlue, {bool isRead = false}) {
     final bgColor = isMe
        ? (isDark ? AppColors.primary700 : AppColors.primary50)
        : (isDark ? AppTheme.darkSurface : AppColors.baseWhite);

    final textColor = isDark ? AppColors.baseWhite : AppColors.neutral900;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            Text(message, style: AppTypography.bodyMedium(AppTypography.regular, textColor)),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTypography.bodyExtraSmall(
                    AppTypography.regular,
                    isDark ? AppColors.neutral400 : AppColors.neutral500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: isRead ? primaryBlue : AppColors.neutral300),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(BuildContext context, bool isDark, Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? Theme.of(context).colorScheme.surface : AppTheme.lightBackground,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppColors.baseWhite,
                  borderRadius: BorderRadius.circular(30),
                  border: _isRecording ? Border.all(color: AppColors.error400) : null,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Icon(
                        _isRecording ? Icons.stop_circle : Icons.mic_none,
                        color: _isRecording ? AppColors.error500 : primaryBlue,
                        size: 24
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: AppTypography.bodyMedium(
                          AppTypography.regular,
                          isDark ? AppColors.baseWhite : AppColors.baseBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: _isRecording ? "Recording..." : "Message",
                          hintStyle: AppTypography.bodyLarge(
                            AppTypography.regular,
                            _isRecording ? AppColors.error400 : (isDark ? AppColors.neutral400 : AppColors.neutral300),
                          ).copyWith(fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _handleAttachment,
                      child: Icon(Icons.attach_file, color: primaryBlue, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.send_outlined, color: AppColors.baseWhite, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}