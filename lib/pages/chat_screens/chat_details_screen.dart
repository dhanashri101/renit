import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/chat_screens/profile.dart';
import 'package:rentit24/services/chat_service.dart';
import 'package:rentit24/services/session_service.dart';

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
    required this.sentAt,
    this.isRead = false,
  });

  final String text;
  final String time;
  final bool isMe;
  final bool isRead;
  final DateTime sentAt;
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    this.chatId = 0,
    this.ownerId = 0,
    required this.userName,
    this.avatar = '',
  });

  final int chatId;
  final int ownerId;
  final String userName;
  final String avatar;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ChatService _chatService = ChatService();

  final List<ChatMessage> messages = <ChatMessage>[];

  bool _isRecording = false;
  bool _isLoading = false;
  bool _isSending = false;
  bool _isFavourite = false;
  int _currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (widget.chatId <= 0) return;

    setState(() => _isLoading = true);

    try {
      _currentUserId = await SessionService.getUserId();
      final data = await _chatService.getMessages(widget.chatId, limit: 100);
      await _chatService.markRead(
        widget.chatId,
        userId: _currentUserId,
      );

      if (!mounted) return;
      setState(() {
        messages
          ..clear()
          ..addAll(
            data.map((message) {
              final DateTime sentAt =
                  message.sentAt?.toLocal() ?? DateTime.now();
              return ChatMessage(
                text: message.message,
                time: DateFormat('h:mm a').format(sentAt),
                isMe: message.senderId == _currentUserId,
                isRead: message.isRead,
                sentAt: sentAt,
              );
            }),
          );
        _isLoading = false;
      });
      _scrollToBottom(jump: true);
    } catch (error, stackTrace) {
      debugPrint('Chat messages error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    if (widget.chatId <= 0) {
      _showMessage('Chat is not connected to a backend conversation.');
      return;
    }

    final DateTime now = DateTime.now();
    final ChatMessage optimisticMessage = ChatMessage(
      text: text,
      time: DateFormat('h:mm a').format(now),
      isMe: true,
      sentAt: now,
    );

    _messageController.clear();
    _messageFocusNode.requestFocus();

    setState(() {
      messages.add(optimisticMessage);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      _currentUserId = _currentUserId == 0
          ? await SessionService.getUserId()
          : _currentUserId;

      await _chatService.sendMessage(
        widget.chatId,
        text,
        senderId: _currentUserId,
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);

    if (_isRecording) {
      _showMessage('Recording started. Tap again to send.');
      return;
    }

    final DateTime now = DateTime.now();
    setState(() {
      messages.add(
        ChatMessage(
          text: '🎤 Voice message · 0:05',
          time: DateFormat('h:mm a').format(now),
          isMe: true,
          sentAt: now,
        ),
      );
    });
    _scrollToBottom();
  }

  void _handleAttachment() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppTheme.darkSurface : AppColors.baseWhite,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _AttachmentAction(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  color: const Color(0xFF7C3AED),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage('Opening gallery...');
                  },
                ),
                _AttachmentAction(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  color: AppTheme.primaryBlue,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage('Opening camera...');
                  },
                ),
                _AttachmentAction(
                  icon: Icons.description_outlined,
                  label: 'Document',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage('Opening file picker...');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final double offset = _scrollController.position.maxScrollExtent;

      if (jump) {
        _scrollController.jumpTo(offset);
      } else {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProfileScreenchat(
          ownerId: widget.ownerId,
          userName: widget.userName,
          avatar: widget.avatar,
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'important':
        _showMessage('Marked as important');
        break;
      case 'contact':
        _openProfile();
        break;
      case 'select_all':
        _showMessage('All messages selected');
        break;
      case 'delete':
        _confirmDeleteChat();
        break;
      case 'report':
        _showMessage('User reported');
        break;
      case 'safety':
        _showMessage('Opening safety tips...');
        break;
      case 'block':
        _confirmBlockUser();
        break;
    }
  }

  Future<void> _confirmDeleteChat() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete chat?'),
          content: const Text(
            'Are you sure you want to delete this chat? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error500),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(messages.clear);
    }
  }

  Future<void> _confirmBlockUser() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Block ${widget.userName}?'),
          content: const Text(
            "Blocked users won't be able to message you or view your ads.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showMessage('${widget.userName} blocked');
              },
              child: Text(
                'Block',
                style: TextStyle(color: AppColors.error500),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? AppTheme.darkBackground
        : const Color(0xFFF4F7FF);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: <Widget>[
          _buildSafetyNotice(isDark),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : _buildMessages(isDark),
          ),
          _buildMessageComposer(isDark),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final Color textColor =
        isDark ? AppColors.baseWhite : const Color(0xFF101828);
    final Color subTextColor =
        isDark ? AppColors.neutral400 : const Color(0xFF667085);
    final Color backgroundColor = isDark
        ? AppTheme.darkBackground
        : const Color(0xFFF4F7FF);

    return AppBar(
      toolbarHeight: 64,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 46,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: textColor,
          size: 19,
        ),
      ),
      titleSpacing: 0,
      title: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openProfile,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _HeaderAvatar(
                    imageUrl: widget.avatar,
                    isDark: isDark,
                  ),
                  Positioned(
                    right: -1,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.success500,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: backgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium(
                        AppTypography.semibold,
                        textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Online',
                      style: AppTypography.bodyExtraSmall(
                        AppTypography.regular,
                        subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          tooltip: 'Favourite',
          onPressed: () {
            setState(() => _isFavourite = !_isFavourite);
          },
          icon: Icon(
            _isFavourite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isFavourite ? AppColors.error500 : textColor,
            size: 22,
          ),
        ),
        PopupMenuButton<String>(
          color: isDark ? AppTheme.darkSurface : AppColors.baseWhite,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          icon: Icon(Icons.more_vert_rounded, color: textColor),
          onSelected: _handleMenuSelection,
          itemBuilder: (_) => <PopupMenuEntry<String>>[
            _buildMenuItem(
              'important',
              Icons.push_pin_outlined,
              'Mark as important',
            ),
            _buildMenuItem(
              'contact',
              Icons.person_outline_rounded,
              'View contact',
            ),
            _buildMenuItem(
              'select_all',
              Icons.done_all_rounded,
              'Select all',
            ),
            _buildMenuItem(
              'delete',
              Icons.delete_outline_rounded,
              'Delete chat',
            ),
            _buildMenuItem(
              'report',
              Icons.flag_outlined,
              'Report user',
            ),
            _buildMenuItem(
              'safety',
              Icons.shield_outlined,
              'Safety tips',
            ),
            _buildMenuItem(
              'block',
              Icons.block_rounded,
              'Block user',
              destructive: true,
            ),
          ],
        ),
        const SizedBox(width: 2),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? AppColors.neutral800
              : const Color(0xFFE8ECF4),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 19,
            color: destructive ? AppColors.error500 : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: destructive ? AppColors.error500 : null,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice(bool isDark) {
    final Color cardColor = isDark
        ? AppTheme.darkSurface
        : AppColors.baseWhite.withValues(alpha: 0.78);
    final Color textColor =
        isDark ? AppColors.neutral400 : const Color(0xFF98A2B3);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.neutral800
              : const Color(0xFFE8ECF4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: textColor,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Never share your phone number, ID, password, OTP or security PIN in chat.',
              style: AppTypography.bodyExtraSmall(
                AppTypography.regular,
                textColor,
              ).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(bool isDark) {
    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waving_hand_outlined,
                  color: AppTheme.primaryBlue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Start the conversation',
                style: AppTypography.bodyLarge(
                  AppTypography.semibold,
                  isDark ? AppColors.baseWhite : const Color(0xFF101828),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Send a message about the product or service.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(
                  AppTypography.regular,
                  isDark ? AppColors.neutral400 : const Color(0xFF667085),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryBlue,
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final ChatMessage message = messages[index];
          final bool showDate = index == 0 ||
              !_isSameDay(messages[index - 1].sentAt, message.sentAt);

          return Column(
            children: <Widget>[
              if (showDate) _buildDateSeparator(message.sentAt, isDark),
              _buildMessageBubble(message, isDark),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Widget _buildDateSeparator(DateTime date, bool isDark) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime value = DateTime(date.year, date.month, date.day);
    final int difference = today.difference(value).inDays;

    String label;
    if (difference == 0) {
      label = 'Today';
    } else if (difference == 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('dd MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral800 : const Color(0xFFE8EEFA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodyExtraSmall(
            AppTypography.medium,
            isDark ? AppColors.neutral400 : const Color(0xFF667085),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final Color backgroundColor = message.isMe
        ? (isDark
              ? AppColors.primary700
              : const Color(0xFFDDE8FF))
        : (isDark ? AppTheme.darkSurface : AppColors.baseWhite);
    final Color textColor =
        isDark ? AppColors.baseWhite : const Color(0xFF101828);
    final Color timeColor =
        isDark ? AppColors.neutral400 : const Color(0xFF98A2B3);

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        margin: EdgeInsets.only(
          left: message.isMe ? 44 : 0,
          right: message.isMe ? 0 : 44,
          bottom: 8,
        ),
        padding: const EdgeInsets.fromLTRB(13, 9, 10, 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(message.isMe ? 15 : 3),
            bottomRight: Radius.circular(message.isMe ? 3 : 15),
          ),
          border: message.isMe || isDark
              ? null
              : Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          runSpacing: 3,
          children: <Widget>[
            Text(
              message.text,
              style: AppTypography.bodyMedium(
                AppTypography.regular,
                textColor,
              ).copyWith(height: 1.35),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message.time,
                  style: AppTypography.bodyExtraSmall(
                    AppTypography.regular,
                    timeColor,
                  ).copyWith(fontSize: 9.5),
                ),
                if (message.isMe) ...<Widget>[
                  const SizedBox(width: 3),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: message.isRead
                        ? AppTheme.primaryBlue
                        : AppColors.neutral400,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer(bool isDark) {
    final Color composerBackground = isDark
        ? AppTheme.darkBackground
        : const Color(0xFFF4F7FF);
    final Color fieldBackground =
        isDark ? AppTheme.darkSurface : AppColors.baseWhite;
    final Color textColor =
        isDark ? AppColors.baseWhite : const Color(0xFF101828);
    final Color hintColor =
        isDark ? AppColors.neutral400 : const Color(0xFF98A2B3);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: composerBackground,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.neutral800
                : const Color(0xFFE8ECF4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isRecording
                        ? AppColors.error400
                        : (isDark
                              ? AppColors.neutral800
                              : const Color(0xFFE4E7EC)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _toggleRecording,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            _isRecording
                                ? Icons.stop_circle_rounded
                                : Icons.mic_none_rounded,
                            color: _isRecording
                                ? AppColors.error500
                                : AppTheme.primaryBlue,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _messageFocusNode,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        style: AppTypography.bodyMedium(
                          AppTypography.regular,
                          textColor,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              _isRecording ? 'Recording...' : 'Type a message',
                          hintStyle: AppTypography.bodyMedium(
                            AppTypography.regular,
                            _isRecording ? AppColors.error400 : hintColor,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _handleAttachment,
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Icon(
                            Icons.attach_file_rounded,
                            color: AppTheme.primaryBlue,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: Material(
                color: AppTheme.primaryBlue,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _isSending ? null : _sendMessage,
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: AppColors.baseWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.baseWhite,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage = imageUrl.startsWith('http');

    return CircleAvatar(
      radius: 19,
      backgroundColor:
          isDark ? AppColors.neutral800 : const Color(0xFFE4E7EC),
      backgroundImage: hasNetworkImage ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: hasNetworkImage ? (_, __) {} : null,
      child: hasNetworkImage
          ? null
          : Icon(
              Icons.person_outline_rounded,
              color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              size: 20,
            ),
    );
  }
}

class _AttachmentAction extends StatelessWidget {
  const _AttachmentAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
