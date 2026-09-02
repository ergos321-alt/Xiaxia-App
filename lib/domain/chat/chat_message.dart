import 'dart:convert';

enum ChatAuthor { user, xiaxia }
enum DeliveryState { sending, sent, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
    this.deliveryState = DeliveryState.sent,
  });

  final String id;
  final ChatAuthor author;
  final String text;
  final DateTime timestamp;
  final DeliveryState deliveryState;

  ChatMessage copyWith({DeliveryState? deliveryState}) {
    return ChatMessage(
      id: id,
      author: author,
      text: text,
      timestamp: timestamp,
      deliveryState: deliveryState ?? this.deliveryState,
    );
  }

  Map<String, Object> toJson() => {
        'id': id,
        'author': author.name,
        'text': text,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'delivery_state': deliveryState.name,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final text = json['text'];
    final timestamp = json['timestamp'];
    if (id is! String || text is! String || timestamp is! String) {
      throw const FormatException('Malformed stored chat message');
    }
    return ChatMessage(
      id: id,
      author: ChatAuthor.values.firstWhere(
        (value) => value.name == json['author'],
        orElse: () => throw const FormatException('Unknown chat author'),
      ),
      text: text,
      timestamp: DateTime.parse(timestamp),
      deliveryState: DeliveryState.values.firstWhere(
        (value) => value.name == json['delivery_state'],
        orElse: () => DeliveryState.sent,
      ),
    );
  }

  String encode() => jsonEncode(toJson());
}
