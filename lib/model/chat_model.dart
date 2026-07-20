import 'package:rentit24/config/api_config.dart';

class ChatThreadModel {
  const ChatThreadModel({
    required this.chatId,
    required this.listingId,
    required this.listingTitle,
    required this.listingImage,
    required this.peerId,
    required this.peerName,
    required this.peerPhoto,
    required this.direction,
    required this.lastMessage,
    required this.unread,
    required this.isImportant,
    this.lastMessageAt,
  });

  final int chatId;
  final int listingId;
  final String listingTitle;
  final String listingImage;
  final int peerId;
  final String peerName;
  final String peerPhoto;
  final String direction;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unread;
  final bool isImportant;

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    return ChatThreadModel(
      chatId: _int(json['chat_id'] ?? json['chatId']),
      listingId: _int(json['listing_id'] ?? json['listingId']),
      listingTitle: _text(json['listing_title'] ?? json['listingTitle']),
      listingImage: ApiConfig.resolveMediaUrl(_text(json['listing_image'] ?? json['listingImage'])),
      peerId: _int(json['peer_id'] ?? json['peerId']),
      peerName: _text(json['peer_name'] ?? json['peerName']),
      peerPhoto: ApiConfig.resolveMediaUrl(_text(json['peer_photo'] ?? json['peerPhoto'])),
      direction: _text(json['direction']),
      lastMessage: _text(json['last_message'] ?? json['lastMessage']),
      lastMessageAt: DateTime.tryParse(_text(json['last_message_at'] ?? json['lastMessageAt'])),
      unread: _int(json['unread']),
      isImportant: _bool(json['is_important'] ?? json['isImportant']),
    );
  }

  static int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static String _text(dynamic value) => value?.toString().trim() ?? '';
  static bool _bool(dynamic value) => value == true || value == 1 || value?.toString() == 'true';
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    required this.isRead,
    this.sentAt,
  });

  final int id;
  final int senderId;
  final String message;
  final bool isRead;
  final DateTime? sentAt;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    return ChatMessageModel(
      id: toInt(json['id']),
      senderId: toInt(json['sender_id'] ?? json['senderId']),
      message: (json['message'] ?? '').toString(),
      isRead: json['is_read'] == true || json['isRead'] == true,
      sentAt: DateTime.tryParse((json['sent_at'] ?? json['sentAt'] ?? '').toString()),
    );
  }
}
