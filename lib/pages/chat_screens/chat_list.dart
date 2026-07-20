import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/chat_screens/chat_details_screen.dart';
import 'package:rentit24/services/chat_service.dart';
import 'package:rentit24/wrapper/navbar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allChats = <Map<String, dynamic>>[];
  final Set<int> _selectedChatIds = <int>{};

  int _selectedFilterIndex = 0;
  bool _isSearching = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    _loadChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredChats {
    Iterable<Map<String, dynamic>> chats = _allChats;
    final String query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      chats = chats.where((chat) {
        final String name = (chat['name'] as String).toLowerCase();
        final String message = (chat['message'] as String).toLowerCase();
        return name.contains(query) || message.contains(query);
      });
    }

    switch (_selectedFilterIndex) {
      case 1:
        chats = chats.where((chat) => (chat['unread'] as int) > 0);
        break;
      case 2:
        chats = chats.where((chat) => chat['isImportant'] == true);
        break;
    }

    return chats.toList();
  }

  Future<void> _loadChats() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final threads = await _chatService.getChats(limit: 100);
      if (!mounted) return;

      setState(() {
        _allChats
          ..clear()
          ..addAll(
            threads.map((thread) {
              final DateTime? lastAt = thread.lastMessageAt;
              final String direction = thread.direction.toLowerCase();

              return <String, dynamic>{
                'chatId': thread.chatId,
                'listingId': thread.listingId,
                'peerId': thread.peerId,
                'name': thread.peerName.isEmpty
                    ? 'RentIt24 User'
                    : thread.peerName,
                'message': thread.lastMessage,
                'time': lastAt == null ? '' : _formatChatTime(lastAt.toLocal()),
                'unread': thread.unread,
                'isReadByOther': thread.unread == 0,
                'isSentByMe': direction.contains('out'),
                'isOnline': false,
                'isImportant': thread.isImportant,
                'direction': direction,
                'avatar': thread.peerPhoto,
              };
            }),
          );
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Chat list error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _formatChatTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime messageDay =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    final int difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      final int hour = dateTime.hour;
      final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      final String period = hour >= 12 ? 'PM' : 'AM';
      return '$displayHour:$minute $period';
    }

    if (difference == 1) return 'Yesterday';
    if (difference < 7) {
      const List<String> weekdays = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      return weekdays[dateTime.weekday - 1];
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  bool _matchesDirection(Map<String, dynamic> chat, String direction) {
    final String value = (chat['direction'] as String).toLowerCase();
    if (direction == 'in') {
      return value.contains('in') && !value.contains('out');
    }
    return value.contains('out');
  }

  void _toggleSelection(int chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedChatIds.clear);
  }

  void _startSearch() {
    setState(() => _isSearching = true);
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  void _openHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const NavigationWrapper()),
      (route) => false,
    );
  }

  void _selectAllVisible() {
    final List<Map<String, dynamic>> visibleChats = _chatsForTab(
      _tabController.index,
    );
    setState(() {
      _selectedChatIds.addAll(
        visibleChats.map((chat) => chat['chatId'] as int),
      );
    });
  }

  List<Map<String, dynamic>> _chatsForTab(int tabIndex) {
    if (tabIndex == 1) {
      return _filteredChats
          .where((chat) => _matchesDirection(chat, 'in'))
          .toList();
    }
    if (tabIndex == 2) {
      return _filteredChats
          .where((chat) => _matchesDirection(chat, 'out'))
          .toList();
    }
    return _filteredChats;
  }

  void _handleSelectionAction(String action) {
    if (action == 'select_all') {
      _selectAllVisible();
      return;
    }

    if (action == 'important') {
      setState(() {
        for (final Map<String, dynamic> chat in _allChats) {
          if (_selectedChatIds.contains(chat['chatId'])) {
            chat['isImportant'] = true;
          }
        }
        _selectedChatIds.clear();
      });
      _showMessage('Marked as important');
      return;
    }

    if (action == 'delete') {
      _confirmDeleteSelected();
      return;
    }

    _showMessage(
      action == 'read' ? 'Marked as read' : 'Action completed',
    );
    _clearSelection();
  }

  Future<void> _confirmDeleteSelected() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete chats?'),
          content: Text(
            'Delete ${_selectedChatIds.length} selected '
            '${_selectedChatIds.length == 1 ? 'chat' : 'chats'}?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    setState(() {
      _allChats.removeWhere(
        (chat) => _selectedChatIds.contains(chat['chatId']),
      );
      _selectedChatIds.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelectionMode = _selectedChatIds.isNotEmpty;
    final Color backgroundColor = isDark
        ? AppTheme.darkBackground
        : const Color(0xFFF4F7FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDark, isSelectionMode),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildChatTab(isDark: isDark, tabIndex: 0, tabName: 'All'),
          _buildChatTab(isDark: isDark, tabIndex: 1, tabName: 'Rent IN'),
          _buildChatTab(isDark: isDark, tabIndex: 2, tabName: 'Rent OUT'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
  bool isDark,
  bool isSelectionMode,
) {
  final Color backgroundColor = isDark
      ? AppTheme.darkBackground
      : const Color(0xFFEAF1FD);

  final Color textColor =
      isDark ? AppColors.baseWhite : const Color(0xFF2F314D);

  return AppBar(
    toolbarHeight: 38,
    backgroundColor: backgroundColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: false,
    leadingWidth: 39,
    leading: IconButton(
      onPressed: isSelectionMode ? _clearSelection : _openHome,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 39,
        minHeight: 38,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        Icons.arrow_back_rounded,
        color: textColor,
        size: 18,
      ),
    ),
    titleSpacing: 2,
    title: Text(
      isSelectionMode ? '${_selectedChatIds.length}' : 'Chats',
      style: AppTypography.bodyMedium(
        AppTypography.semibold,
        textColor,
      ).copyWith(
        fontSize: 15,
      ),
    ),

    // Normal search and menu icons are hidden to match the screenshot.
    // The selection menu remains available after long-pressing a chat.
    actions: isSelectionMode
        ? <Widget>[
            PopupMenuButton<String>(
              color: isDark
                  ? AppTheme.darkSurface
                  : AppColors.baseWhite,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              icon: Icon(
                Icons.more_horiz_rounded,
                color: textColor,
              ),
              onSelected: _handleSelectionAction,
              itemBuilder: (_) => <PopupMenuEntry<String>>[
                _menuItem(
                  'read',
                  Icons.mark_chat_read_outlined,
                  'Mark as read',
                ),
                _menuItem(
                  'important',
                  Icons.push_pin_outlined,
                  'Mark as important',
                ),
                _menuItem(
                  'select_all',
                  Icons.done_all_rounded,
                  'Select all',
                ),
                _menuItem(
                  'delete',
                  Icons.delete_outline_rounded,
                  'Delete chat',
                  destructive: true,
                ),
              ],
            ),
          ]
        : const <Widget>[],
    bottom: _buildTabsAndFilters(isDark),
  );
}

  PopupMenuItem<String> _menuItem(
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

  PreferredSize _buildTabsAndFilters(bool isDark) {
    final Color selectedText =
        isDark ? AppColors.baseWhite : const Color(0xFF1D2939);
    final Color unselectedText =
        isDark ? AppColors.neutral400 : const Color(0xFF98A2B3);

    return PreferredSize(
      preferredSize: const Size.fromHeight(92),
      child: Column(
        children: <Widget>[
          Container(
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppColors.baseWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: AppTheme.primaryBlue,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 20),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              labelColor: selectedText,
              unselectedLabelColor: unselectedText,
              labelStyle: AppTypography.bodyMedium(
                AppTypography.semibold,
                selectedText,
              ),
              unselectedLabelStyle: AppTypography.bodyMedium(
                AppTypography.regular,
                unselectedText,
              ),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              tabs: const <Tab>[
                Tab(text: 'All'),
                Tab(text: 'Rent IN'),
                Tab(text: 'Rent OUT'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                _buildFilterChip('All', 0, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 1, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Important', 2, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isDark) {
    final bool isSelected = _selectedFilterIndex == index;
    final Color unselectedBackground =
        isDark ? AppColors.neutral800 : AppColors.baseWhite;
    final Color unselectedText =
        isDark ? AppColors.neutral400 : const Color(0xFF667085);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : unselectedBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isDark
                      ? AppColors.neutral700
                      : const Color(0xFFE4E7EC)),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(
            isSelected ? AppTypography.semibold : AppTypography.regular,
            isSelected ? AppColors.baseWhite : unselectedText,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab({
    required bool isDark,
    required int tabIndex,
    required String tabName,
  }) {
    final List<Map<String, dynamic>> chatsToDisplay = _chatsForTab(tabIndex);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    if (_loadError != null && _allChats.isEmpty) {
      return _buildErrorState(isDark);
    }

    if (chatsToDisplay.isEmpty) {
      return _buildEmptyState(
        context,
        isDark,
        AppTheme.primaryBlue,
        tabName,
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryBlue,
      onRefresh: _loadChats,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
        itemCount: chatsToDisplay.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          return _buildChatTile(
            context: context,
            chat: chatsToDisplay[index],
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.wifi_off_rounded,
              size: 42,
              color: isDark ? AppColors.neutral400 : AppColors.neutral500,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load chats',
              style: AppTypography.bodyLarge(
                AppTypography.semibold,
                isDark ? AppColors.baseWhite : AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _loadError ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(
                AppTypography.regular,
                isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loadChats,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required Map<String, dynamic> chat,
    required bool isDark,
  }) {
    final int chatId = chat['chatId'] as int;
    final int unreadCount = chat['unread'] as int;
    final bool hasUnread = unreadCount > 0;
    final bool isSentByMe = chat['isSentByMe'] as bool;
    final bool isReadByOther = chat['isReadByOther'] as bool;
    final bool isSelected = _selectedChatIds.contains(chatId);
    final String avatar = chat['avatar'] as String;

    final Color tileColor = isSelected
        ? (isDark
              ? AppTheme.primaryBlue.withValues(alpha: 0.18)
              : const Color(0xFFE5EDFF))
        : (isDark ? AppTheme.darkSurface : Colors.transparent);
    final Color titleColor =
        isDark ? AppColors.baseWhite : const Color(0xFF101828);
    final Color subtitleColor =
        isDark ? AppColors.neutral400 : const Color(0xFF667085);

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () => _toggleSelection(chatId),
        onTap: () {
          if (_selectedChatIds.isNotEmpty) {
            _toggleSelection(chatId);
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ChatDetailScreen(
                chatId: chatId,
                ownerId: chat['peerId'] as int,
                userName: chat['name'] as String,
                avatar: avatar,
              ),
            ),
          ).then((_) => _loadChats());
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _Avatar(imageUrl: avatar, radius: 25, isDark: isDark),
                  if (chat['isOnline'] as bool)
                    Positioned(
                      right: -1,
                      bottom: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success500,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkSurface
                                : const Color(0xFFF4F7FF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.baseWhite,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  chat['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMedium(
                                    hasUnread
                                        ? AppTypography.semibold
                                        : AppTypography.medium,
                                    titleColor,
                                  ),
                                ),
                              ),
                              if (chat['isImportant'] == true) ...<Widget>[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.push_pin_rounded,
                                  size: 13,
                                  color: AppTheme.primaryBlue,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chat['time'] as String,
                          style: AppTypography.bodyExtraSmall(
                            hasUnread
                                ? AppTypography.semibold
                                : AppTypography.regular,
                            hasUnread
                                ? AppTheme.primaryBlue
                                : (isDark
                                      ? AppColors.neutral400
                                      : const Color(0xFF98A2B3)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        if (isSentByMe) ...<Widget>[
                          Icon(
                            Icons.done_all_rounded,
                            size: 16,
                            color: isReadByOther
                                ? AppTheme.primaryBlue
                                : AppColors.neutral400,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            (chat['message'] as String).isEmpty
                                ? 'Start a conversation'
                                : chat['message'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(
                              hasUnread
                                  ? AppTypography.medium
                                  : AppTypography.regular,
                              hasUnread ? titleColor : subtitleColor,
                            ),
                          ),
                        ),
                        if (hasUnread) ...<Widget>[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: AppTypography.bodyExtraSmall(
                                AppTypography.semibold,
                                AppColors.baseWhite,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color primaryBlue,
    String tabName,
  ) {
    final String title = tabName == 'Rent OUT'
        ? 'No rental enquiries yet!'
        : "You haven't received any messages yet!";
    final String description = tabName == 'Rent OUT'
        ? 'Post an item or service and your customer conversations will appear here.'
        : 'Search for a product or service\nto begin a conversation.';
    final String buttonLabel = tabName == 'Rent OUT'
        ? 'Post an ad'
        : 'Start browsing';

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: primaryBlue,
          onRefresh: _loadChats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/chat.png',
                    height: 190,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return SizedBox(
                        height: 190,
                        child: Icon(
                          Icons.forum_outlined,
                          size: 100,
                          color: primaryBlue.withValues(alpha: 0.45),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge(
                      AppTypography.semibold,
                      isDark ? AppColors.baseWhite : const Color(0xFF101828),
                    ).copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(
                      AppTypography.regular,
                      isDark
                          ? AppColors.neutral400
                          : const Color(0xFF667085),
                    ).copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _openHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: AppColors.baseWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        style: AppTypography.bodyMedium(
                          AppTypography.semibold,
                          AppColors.baseWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.imageUrl,
    required this.radius,
    required this.isDark,
  });

  final String imageUrl;
  final double radius;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool hasNetworkImage = imageUrl.startsWith('http');

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          isDark ? AppColors.neutral800 : const Color(0xFFE4E7EC),
      backgroundImage: hasNetworkImage ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: hasNetworkImage ? (_, __) {} : null,
      child: hasNetworkImage
          ? null
          : Icon(
              Icons.person_outline_rounded,
              color: isDark ? AppColors.neutral400 : AppColors.neutral500,
            ),
    );
  }
}
