import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Clean utility helpers for parsing and formatting Dates and Times.
class DateTimeUtils {
  DateTimeUtils._();

  static final DateFormat _headerDateFormat = DateFormat('EEEE, MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  /// Formats today's date or a given [dateTime] into a header string (e.g. "Monday, Oct 26, 2026").
  static String formatHeaderDate([DateTime? dateTime]) {
    return _headerDateFormat.format(dateTime ?? DateTime.now());
  }

  /// Formats a [DateTime] into a standard compact readable format (e.g. "Oct 26, 2026").
  static String formatShortDate(DateTime dateTime) {
    return _shortDateFormat.format(dateTime);
  }

  /// Converts a Flutter [TimeOfDay] into an uppercase 12-hour formatted string (e.g. "08:30 AM").
  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return _timeFormat.format(dt);
  }

  /// Safely parses a 12-hour time string into a Flutter [TimeOfDay].
  /// Returns 08:00 AM as a safe fallback if parsing fails.
  static TimeOfDay parseTimeOfDay(String timeString) {
    try {
      final trimmed = timeString.trim().toUpperCase();
      final dt = _timeFormat.parse(trimmed);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      // Fallback manual regex match
      final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$', caseSensitive: false).firstMatch(timeString.trim());
      if (match != null) {
        var hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final meridian = match.group(3)?.toUpperCase();

        if (meridian == 'PM' && hour < 12) hour += 12;
        if (meridian == 'AM' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  /// Checks whether two DateTimes fall on the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
