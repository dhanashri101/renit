import 'package:flutter/material.dart';
import 'package:rentit24/core/theme.dart';
import 'package:rentit24/pages/chat_screens/chat_details_screen.dart';

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
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
    },
    {
      'name': 'Robert Fox',
      'message': 'Yes, it is available 👍',
      'time': '18:05',
      'unread': 3,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
    },
    {
      'name': 'Kathryn Murphy',
      'message': 'What is the function date?',
      'time': '17:42',
      'unread': 1,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
    },
    {
      'name': 'Darrell Steward',
      'message': 'Is the apartment still available?',
      'time': '11:31',
      'unread': 0,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100',
    },
    {
      'name': 'Jerome Bell',
      'message': 'Yes, I will do video editing also 👍',
      'time': 'Yesterday',
      'unread': 4,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': true,
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
    },
    {
      'name': 'Leslie Alexander',
      'message': 'Yes, that sounds great! Will decorate. 🎈',
      'time': '02/12/2025',
      'unread': 2,
      'isReadByOther': false,
      'isSentByMe': false,
      'isOnline': false,
      'avatar': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100',
    }
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _allChats;
    return _allChats
        .where((chat) => (chat['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
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
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: _buildAppBar(isDark, isSelectionMode),
        body: TabBarView(
          children: [
            _buildActiveChats(context, isDark, AppTheme.primaryBlue , isSelectionMode),
            _buildEmptyState(context, isDark, AppTheme.primaryBlue , "Rent IN"),
            _buildEmptyState(context, isDark, AppTheme.primaryBlue , "Rent OUT"),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isSelectionMode) {
    final textColor = isDark ? Colors.white : const Color(0xFF111827);

    if (isSelectionMode) {
      return AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: _clearSelection,
        ),
        title: Text(
          '${_selectedChats.length}',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
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
                  child: Text(choice),
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
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
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
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Search chats...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
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
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Text(
        'Chats',
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
                  borderSide: BorderSide(color: AppTheme.primaryBlue , width: 4.0),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                labelColor: isDark ? Colors.white : const Color(0xFF1F2937),
                unselectedLabelColor: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(child: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Text('All'))),
                  Tab(child: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Text('Rent IN'))),
                  Tab(child: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Text('Rent OUT'))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', 0, AppTheme.primaryBlue , isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 1, AppTheme.primaryBlue , isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Important', 2, AppTheme.primaryBlue , isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color activeColor, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChats(BuildContext context, bool isDark, Color primaryBlue , bool isSelectionMode) {
    final chatsToDisplay = _filteredChats;

    if (chatsToDisplay.isEmpty) {
      return Center(
        child: Text(
          'No chats found',
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                  ? (isDark ? primaryBlue .withOpacity(0.2) : const Color(0xFFE5EDFF))
                  : Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(
                      chatName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 2),
                    if (chat['isOnline'] as bool)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const Spacer(),
                    if (!hasUnread && !isSentByMe) ...[
                      Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      chat['time'] as String,
                      style: TextStyle(
                        color: hasUnread ? primaryBlue  : const Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
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
                          color: isReadByOther ? primaryBlue  : Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat['message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[500] : const Color(0xFF6B7280)),
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryBlue ,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, Color primaryBlue , String tabName) {
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Search the product or service\nto begin a conversation.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue ,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start ${tabName == 'Rent IN' ? 'Messaging' : 'Renting'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}