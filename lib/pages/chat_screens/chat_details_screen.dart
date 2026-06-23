import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  final String userName;
  final String avatar;

  const ChatDetailScreen({
    super.key, 
    required this.userName, 
    this.avatar = 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100'
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBlue = const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Online",
                  style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : const Color(0xFF111827)),
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: '1', child: Text('Mark as important')),
              const PopupMenuItem<String>(value: '2', child: Text('View contact')),
              const PopupMenuItem<String>(value: '3', child: Text('Select all')),
              const PopupMenuItem<String>(value: '4', child: Text('Delete chat')),
              const PopupMenuItem<String>(value: '5', child: Text('Report user')),
              const PopupMenuItem<String>(value: '6', child: Text('Safety tips')),
              const PopupMenuItem<String>(value: '7', child: Text('Block user')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB),
              border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Sharing personal information such as your phone number, ID, password, or security PIN is strictly prohibited according to our app's terms and conditions. If you choose to share any of this information, our app cannot be held responsible.",
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMessageBubble(context, "Hi, is the wheelchair available?", "13:05", false, isDark, primaryBlue),
                _buildMessageBubble(context, "for 15 days", "13:05", false, isDark, primaryBlue),
                _buildMessageBubble(context, "Yes it is available", "13:15", true, isDark, primaryBlue, isRead: true),
                _buildMessageBubble(context, "cool", "13:05", false, isDark, primaryBlue), 
                _buildMessageBubble(context, "Is the wheelchair working properly?", "13:05", false, isDark, primaryBlue),
                _buildMessageBubble(context, "wheelchair is working properly, not used since 3 months", "13:25", true, isDark, primaryBlue, isRead: true),
                _buildMessageBubble(context, "all the wheels are in good condition?", "13:15", false, isDark, primaryBlue),
                _buildMessageBubble(context, "The wheelchair is in good condition", "13:25", true, isDark, primaryBlue, isRead: true),
              ],
            ),
          ),
          _buildMessageComposer(context, isDark, primaryBlue),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String message, String time, bool isMe, bool isDark, Color primaryBlue, {bool isRead = false}) {
    final bgColor = isMe 
        ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF)) 
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6));
    
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

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
            Text(message, style: TextStyle(color: textColor, fontSize: 14)),
            const SizedBox(width: 8), 
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all, size: 14, color: isRead ? primaryBlue : Colors.grey[400]),
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
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.mic_none, color: isDark ? Colors.grey[400] : primaryBlue, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Message",
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : primaryBlue, size: 24),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}