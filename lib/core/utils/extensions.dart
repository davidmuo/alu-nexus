import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.grey.shade900,
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  String get timeAgo => timeago.format(this);

  String get shortDate => DateFormat('MMM d, yyyy').format(this);

  String get fullDate => DateFormat('MMMM d, yyyy').format(this);

  String get shortDateTime => DateFormat('MMM d • h:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    return now.difference(this).inDays < 7;
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isAluEmail =>
      endsWith('@alustudent.com') || endsWith('@alueducation.com');
}

extension ListExtensions<T> on List<T> {
  List<T> withoutDuplicates() => toSet().toList();
}
