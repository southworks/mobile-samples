class ClockSnapshot {
  const ClockSnapshot({
    required this.dateTime,
    required this.timeZoneName,
    required this.timeZoneOffset,
  });

  final DateTime dateTime;
  final String timeZoneName;
  final Duration timeZoneOffset;
}
