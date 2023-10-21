import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtil {
  // for getting formatted time from milliSecondsSinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final timeOfDay = TimeOfDay.fromDateTime(date);

    String formattedTime = timeOfDay.format(context);

    // Determine AM hoặc PM dựa trên giờ trong thời gian
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    // Kết hợp thông tin thời gian và AM/PM
    return '$formattedTime $period';
  }
// get last message time (used in chat user card)
  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final period = TimeOfDay.fromDateTime(send).period == DayPeriod.am ? 'AM' : 'PM';
    if (now.day == send.day &&
        now.month == send.month &&
        now.year == send.year) {
      return "${TimeOfDay.fromDateTime(send).format(context)} ${period}";
    }

    return '${send.day} ${_getMonth(send)}';
  }

  static String getCreatedUser({required BuildContext context, required String time}) {
    final DateTime send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return '${send.day} ${_getMonth(send)} ${send.year}';

}

  static String getLastActiveTime({required BuildContext context , required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    // if time is not available then return below statement
    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at $formattedTime';
    }
    if((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';

   }



  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Abr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}