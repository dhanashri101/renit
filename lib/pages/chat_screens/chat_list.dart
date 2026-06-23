import 'package:flutter/material.dart';
import 'package:rentit24/pages/chat_screens/chat_details_screen.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedFilterIndex = 0; 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryBlue = const Color(0xFF2563EB); 

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Text(
            'Chats',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(
              100,
            ), 
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: primaryBlue,
                      unselectedLabelColor: isDark
                          ? Colors.grey[400]
                          : const Color(0xFF6B7280),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Rent IN'),
                        Tab(text: 'Rent OUT'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFilterChip('All', 0, primaryBlue, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Unread', 1, primaryBlue, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip('Important', 2, primaryBlue, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveChats(context, isDark, primaryBlue),
            _buildEmptyState(context, isDark, primaryBlue, "Rent IN"),
            _buildEmptyState(context, isDark, primaryBlue, "Rent OUT"),
          ],
        ),
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
          color: isSelected
              ? activeColor
              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveChats(
    BuildContext context,
    bool isDark,
    Color primaryBlue,
  ) {
    final chats = [
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
    ];

    return ListView.separated(
      itemCount: chats.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[100],
      ),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final unreadCount = chat['unread'] as int;
        final hasUnread = unreadCount > 0;
        final isSentByMe = chat['isSentByMe'] as bool;
        final isReadByOther = chat['isReadByOther'] as bool;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(chat['avatar'] as String),
          ),
          title: Row(
            children: [
              Text(
                chat['name'] as String,
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
                  color: hasUnread ? primaryBlue : const Color(0xFF9CA3AF),
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
                    color: isReadByOther ? primaryBlue : Colors.grey[400],
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
                          : (isDark
                                ? Colors.grey[500]
                                : const Color(0xFF6B7280)),
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
                      color: primaryBlue,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  userName: chat['name'] as String,
                  avatar: chat['avatar'] as String,
                ),
              ),
            );
          },
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
                backgroundColor: primaryBlue,
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
