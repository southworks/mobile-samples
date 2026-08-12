class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    required this.receivedAt,
  });

  final String title;
  final String body;
  final DateTime receivedAt;
}
