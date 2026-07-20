import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentit24/model/notification_model.dart';
import 'package:rentit24/services/api_exception.dart';
import 'package:rentit24/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _items = const [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getMine(limit: 100);
      if (!mounted) return;
      setState(() => _items = items);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.userMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Unable to load notifications.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(NotificationModel item) async {
    if (item.isRead) return;
    try {
      await _service.markRead(item.id);
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (current) => current.id == item.id
                  ? NotificationModel(
                      id: current.id,
                      title: current.title,
                      body: current.body,
                      isRead: true,
                      createdAt: current.createdAt,
                    )
                  : current,
            )
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }

  Future<void> _markAllRead() async {
    if (_markingAll || _items.every((item) => item.isRead)) return;
    setState(() => _markingAll = true);
    try {
      await _service.markAllRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (item) => NotificationModel(
                id: item.id,
                title: item.title,
                body: item.body,
                isRead: true,
                createdAt: item.createdAt,
              ),
            )
            .toList();
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markingAll ? null : _markAllRead,
            child: _markingAll
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          const Icon(Icons.cloud_off_rounded, size: 52),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.tonal(onPressed: _load, child: const Text('Retry')),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text('No notifications', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: EdgeInsets.zero,
          color: item.isRead
              ? null
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          child: ListTile(
            onTap: () => _markRead(item),
            leading: CircleAvatar(
              backgroundColor: item.isRead
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.primary,
              child: Icon(
                Icons.notifications_rounded,
                color: item.isRead
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onPrimary,
              ),
            ),
            title: Text(item.title.isEmpty ? 'Notification' : item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.body),
                ],
                if (item.createdAt != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(item.createdAt!.toLocal()),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ],
            ),
            trailing: item.isRead
                ? null
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
