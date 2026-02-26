/// Helper utilities for date/time operations, specifically for Philippine Standard Time (PST/UTC+8).
library;

/// Gets the current time in Philippine Standard Time (UTC+8).
/// Returns a naive (non-UTC-flagged) DateTime so that when converted to
/// ISO 8601 string, it will be stored correctly in Supabase without
/// additional timezone conversions.
DateTime getPSTNow() {
  final utcNow = DateTime.now().toUtc();
  final pst = utcNow.add(const Duration(hours: 8));
  // Return a naive DateTime by constructing from PST components
  return DateTime(
    pst.year,
    pst.month,
    pst.day,
    pst.hour,
    pst.minute,
    pst.second,
    pst.millisecond,
  );
}

/// Parses a timestamp from Supabase (which is stored as a naive PST string).
/// Returns a DateTime that represents the correct PST time.
/// This should be used when reading timestamps from Supabase.
DateTime parsePSTTimestamp(dynamic timestamp) {
  if (timestamp == null) {
    return getPSTNow();
  }
  
  try {
    // Parse the timestamp - it's stored as a naive PST string
    // DateTime.parse() on a naive string returns a naive DateTime
    // whose .hour is already in PST
    return DateTime.parse(timestamp.toString());
  } catch (e) {
    return getPSTNow();
  }
}
