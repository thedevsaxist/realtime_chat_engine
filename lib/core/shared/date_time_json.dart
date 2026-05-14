/// Parses dates from the wire (ISO-8601 strings) or local SQLite INTEGER milliseconds.
DateTime dateTimeFromJson(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is double) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    final ms = int.tryParse(value);
    if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime.parse(value);
  }
  throw FormatException('Cannot parse DateTime from: $value (${value.runtimeType})');
}
