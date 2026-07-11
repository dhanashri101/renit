import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/chat_screens/chat_details_screen.dart';
import 'package:rentit24/wrapper/navbar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedFilterIndex = 0;

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Set<String> _selectedChats = {};

  final List<Map<String, dynamic>> _allChats = [
    {
      'name': 'Floyd Miles',
      'message': 'The wheelchair is in good condition',
      'time': '18:11',
      'unread': 0,
      'isReadByOther': true,
      'isSentByMe': true,
      'isOnline': true,
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
    },
    {
      'name': 'Robert Fox',
      'message': 'Yes, it is available 👍',
      'time': '18:05',
      'unread': 3,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
    },
    {
      'name': 'Kathryn Murphy',
      'message': 'What is the function date?',
      'time': '17:42',
      'unread': 1,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
    },
    {
      'name': 'Darrell Steward',
      'message': 'Is the apartment still available?',
      'time': '11:31',
      'unread': 0,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar':
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
    },
    {
      'name': 'Jerome Bell',
      'message': 'Yes, I will do video editing also 👍',
      'time': 'Yesterday',
      'unread': 4,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar':
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
    },
    {
      'name': 'Leslie Alexander',
      'message': 'Yes, that sounds great! Will decorate. 🎈',
      'time': '02/12/2025',
      'unread': 2,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': false,
      'avatar':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _allChats;
    return _allChats
        .where(
          (chat) => (chat['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void _toggleSelection(String chatName) {
    setState(() {
      if (_selectedChats.contains(chatName)) {
        _selectedChats.remove(chatName);
      } else {
        _selectedChats.add(chatName);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedChats.clear();
    });
  }

  void _handleMenuAction(String action) {
    setState(() {
      if (action == 'Select all') {
        _selectedChats.addAll(_filteredChats.map((c) => c['name'] as String));
      } else {
        debugPrint('Action selected: $action on $_selectedChats');
        _clearSelection();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelectionMode = _selectedChats.isNotEmpty;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : AppTheme.lightBackground,
        appBar: _buildAppBar(isDark, isSelectionMode),
        body: TabBarView(
          children: [
            _buildActiveChats(
              context,
              isDark,
              AppTheme.primaryBlue,
              isSelectionMode,
            ),
            _buildEmptyState(context, isDark, AppTheme.primaryBlue, "Rent IN"),
            _buildEmptyState(context, isDark, AppTheme.primaryBlue, "Rent OUT"),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isSelectionMode) {
    final textColor = isDark ? AppColors.baseWhite : AppColors.neutral900;

    if (isSelectionMode) {
      return AppBar(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : AppTheme.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: _clearSelection,
        ),
        title: Text(
          '${_selectedChats.length}',
          style: AppTypography.h5Style(textColor),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: textColor),
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) {
              return [
                'Mark as read',
                'Mark as important',
                'View contact',
                'Select all',
                'Delete chat',
                'Block user',
              ].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice, style: AppTypography.bodyMedium(AppTypography.regular, textColor)),
                );
              }).toList();
            },
          ),
        ],
        bottom: _buildTabsAndFilters(isDark),
      );
    }

    if (_isSearching) {
      return AppBar(
        backgroundColor: isDark
            ? AppTheme.darkBackground
            : AppTheme.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: AppTypography.bodyLarge(AppTypography.regular, textColor),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: AppTypography.bodyLarge(
              AppTypography.regular,
              isDark ? AppColors.neutral400 : AppColors.neutral300,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: textColor),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
        ],
        bottom: _buildTabsAndFilters(isDark),
      );
    }

    return AppBar(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavigationWrapper()),
            (route) => false,
          );
        },
      ),
      titleSpacing: 0,
      title: Text(
        'Chats',
        style: AppTypography.h5Style(textColor),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: textColor),
          onPressed: () => setState(() => _isSearching = true),
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, color: textColor),
          onPressed: () {},
        ),
      ],
      bottom: _buildTabsAndFilters(isDark),
    );
  }

  PreferredSize _buildTabsAndFilters(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 40,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 4.0,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                labelColor: isDark ? AppColors.baseWhite : AppColors.neutral800,
                unselectedLabelColor: isDark ? AppColors.neutral400 : AppColors.neutral300,
                labelStyle: AppTypography.bodyLarge(AppTypography.semibold, isDark ? AppColors.baseWhite : AppColors.neutral800),
                unselectedLabelStyle: AppTypography.bodyLarge(AppTypography.medium, isDark ? AppColors.neutral400 : AppColors.neutral300),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text('All'),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text('Rent IN'),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text('Rent OUT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', 0, AppTheme.primaryBlue, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 1, AppTheme.primaryBlue, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Important', 2, AppTheme.primaryBlue, isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int index,
    Color activeColor,
    bool isDark,
  ) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : (isDark ? AppColors.neutral800 : AppColors.neutral50),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(
            isSelected ? AppTypography.semibold : AppTypography.medium,
            isSelected ? AppColors.baseWhite : (isDark ? AppColors.neutral400 : AppColors.neutral500),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChats(
    BuildContext context,
    bool isDark,
    Color primaryBlue,
    bool isSelectionMode,
  ) {
    final chatsToDisplay = _filteredChats;

    if (chatsToDisplay.isEmpty) {
      return Center(
        child: Text(
          'No chats found',
          style: AppTypography.bodyMedium(
            AppTypography.regular,
            isDark ? AppColors.neutral400 : AppColors.neutral500,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: chatsToDisplay.length,
      itemBuilder: (context, index) {
        final chat = chatsToDisplay[index];
        final chatName = chat['name'] as String;
        final unreadCount = chat['unread'] as int;
        final hasUnread = unreadCount > 0;
        final isSentByMe = chat['isSentByMe'] as bool;
        final isReadByOther = chat['isReadByOther'] as bool;

        final isSelected = _selectedChats.contains(chatName);

        return Column(
          children: [
            Container(
              color: isSelected
                  ? (isDark ? primaryBlue.withValues(alpha: 0.2) : AppColors.primary50)
                  : Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onLongPress: () => _toggleSelection(chatName),
                onTap: () {
                  if (isSelectionMode) {
                    _toggleSelection(chatName);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userName: chat['name'] as String,
                          avatar: chat['avatar'] as String,
                        ),
                      ),
                    );
                  }
                },
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(chat['avatar'] as String),
                    ),
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 16, color: AppColors.baseWhite),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(
                      chatName,
                      style: AppTypography.bodyMedium(
                        AppTypography.semibold,
                        isDark ? AppColors.baseWhite : AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                    const SizedBox(width: 2),
                    if (chat['isOnline'] as bool)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Spacer(),
                    if (!hasUnread && !isSentByMe) ...[
                      Icon(Icons.access_time, size: 12, color: AppColors.neutral300),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      chat['time'] as String,
                      style: AppTypography.bodyExtraSmall(
                        hasUnread ? AppTypography.semibold : AppTypography.regular,
                        hasUnread ? primaryBlue : AppColors.neutral300,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      if (isSentByMe) ...[
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: isReadByOther ? primaryBlue : AppColors.neutral300,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(
                            hasUnread ? AppTypography.semibold : AppTypography.regular,
                            hasUnread
                                ? (isDark ? AppColors.baseWhite : AppColors.neutral800)
                                : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: AppTypography.bodyExtraSmall(AppTypography.bold, AppColors.baseWhite),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.neutral700 : AppColors.neutral50,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color primaryBlue,
    String tabName,
  ) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/chat.png', height: 200),
          const SizedBox(height: 24),
          Text(
            "You haven't received any messages yet!",
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge(
              AppTypography.semibold,
              isDark ? AppColors.baseWhite : AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Search the product or service\nto begin a conversation.",
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(
              AppTypography.regular,
              isDark ? AppColors.neutral400 : AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: AppColors.baseWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start ${tabName == 'Rent IN' ? 'Messaging' : 'Renting'}',
                style: AppTypography.bodyMedium(AppTypography.semibold, AppColors.baseWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
