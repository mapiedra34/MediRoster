import 'package:intl/intl.dart';

/// Utility functions for date and time formatting
class DateTimeHelper {
  /// Format DateTime to date string (yyyy-MM-dd)
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format DateTime to display date string (EEEE, MMMM d, y)
  static String formatDisplayDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }
  
  /// Format DateTime to time string (HH:mm)
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  /// Format DateTime to full date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  
  /// Parse date string to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse time string (HH:mm) to DateTime (today's date with that time)
  static DateTime? parseTime(String timeString) {
    try {
      final now = DateTime.now();
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }
  
  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));
  }
  
  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.isNegative) {
      // Future
      final absDiff = difference.abs();
      if (absDiff.inDays > 0) {
        return 'in ${absDiff.inDays} ${absDiff.inDays == 1 ? 'day' : 'days'}';
      } else if (absDiff.inHours > 0) {
        return 'in ${absDiff.inHours} ${absDiff.inHours == 1 ? 'hour' : 'hours'}';
      } else if (absDiff.inMinutes > 0) {
        return 'in ${absDiff.inMinutes} ${absDiff.inMinutes == 1 ? 'minute' : 'minutes'}';
      } else {
        return 'in a moment';
      }
    } else {
      // Past
      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        return 'just now';
      }
    }
  }
}
