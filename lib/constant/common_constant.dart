import 'package:sqlite_user/utils/date_util.dart';

getAge({required int year, required int day, required int month}) {
  DateTime birthday = DateTime(year, day, month);
  DateTime today = DateTime.now();

  AgeDuration? age;
  age = Age.dateDifference(
      fromDate: birthday, toDate: today, includeToDate: false);
  return age;
  }
