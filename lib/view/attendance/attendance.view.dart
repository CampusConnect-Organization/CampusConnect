import 'dart:io';

import 'package:campus_connect_app/models/attendance/attendance.model.dart';
import 'package:campus_connect_app/models/error.model.dart';
import 'package:campus_connect_app/utils/constants.dart';
import 'package:campus_connect_app/services/attendance.service.dart';
import 'package:campus_connect_app/utils/snackbar.dart';
import 'package:campus_connect_app/widgets/greyText.widget.dart';
import 'package:campus_connect_app/widgets/spinner.widget.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceDetail extends StatefulWidget {
  final int courseSessionId;

  const AttendanceDetail({Key? key, required this.courseSessionId})
      : super(key: key);

  @override
  State<AttendanceDetail> createState() => _AttendanceDetailState();
}

class _AttendanceDetailState extends State<AttendanceDetail> {
  Attendance? attendance;
  bool isRefreshing = false;
  bool isUploading = false;
  late Errors errors;
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, String> attendanceMap = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAttendances();
  }

  Future<void> fetchAttendances() async {
    setState(() {
      isRefreshing = true;
      errorMessage = '';
    });

    try {
      dynamic data = await AttendanceAPIService().getAttendances(widget.courseSessionId);

      if (data is Attendance) {
        setState(() {
          attendance = data;
          attendanceMap = {};
          for (var record in attendance!.data) {
            DateTime utcDate = DateTime.parse(record.date);
            DateTime nepalDate = convertToNepalTime(utcDate);
            DateTime dateKey = DateTime(nepalDate.year, nepalDate.month, nepalDate.day);

            attendanceMap[normalizeDate(dateKey)] = record.status;
          }
          isRefreshing = false;
        });
      } else if (data is Errors) {
        setState(() {
          errors = data;
          isRefreshing = false;
        });
      }
    } catch (error) {
      generateErrorSnackbar("Error", "An unspecified error occurred!");
      setState(() {
        isRefreshing = false;
        errorMessage = 'An error occurred while fetching data.';
      });
    }
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      isUploading = true;
    });

    try {
      var response = await AttendanceAPIService()
          .markAttendance(widget.courseSessionId, imageFile);

      if (response.statusCode == 200) {
        generateSuccessSnackbar("Success", "Attendance taken successfully!");
        await fetchAttendances();
      } else if (response.statusCode == 400) {
        generateErrorSnackbar(
            "Error", "You are not allowed to take attendance for other students");
      } else if (response.statusCode == 418) {
        generateErrorSnackbar("Error", "No student found!");
      } else {
        generateErrorSnackbar(
            "Error", "Failed to upload image: ${response.body}");
      }
    } catch (e) {
      generateErrorSnackbar("Error",
          "Attendance already taken today or an unspecified error occurred!");
    } finally {
      setState(() {
        isUploading = false;
      });
      fetchAttendances();
    }
  }

  DateTime convertToNepalTime(DateTime utcDateTime) {
    Duration offset = const Duration(hours: 5, minutes: 45);
    return utcDateTime.add(offset);
  }

  DateTime normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  void updateAttendanceForMonth(DateTime month) {
    setState(() {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      attendanceMap = {};
      for (var record in attendance!.data) {
        DateTime utcDate = DateTime.parse(record.date);
        DateTime nepalDate = convertToNepalTime(utcDate);
        DateTime dateKey = DateTime(nepalDate.year, nepalDate.month, nepalDate.day);

        if (dateKey.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            dateKey.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          attendanceMap[normalizeDate(dateKey)] = record.status;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedAttendanceEntries = attendanceMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: GlobalColors.mainColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            onPressed: _openCamera,
            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: fetchAttendances,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: GlobalColors.mainColor,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: const TextStyle(color: Colors.black),
                          outsideTextStyle: const TextStyle(color: Colors.grey),
                        ),
                        headerStyle: HeaderStyle(
                          titleTextStyle: TextStyle(color: GlobalColors.mainColor),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekendStyle: TextStyle(color: Colors.red),
                          weekdayStyle: TextStyle(color: Colors.black),
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, date, _) {
                            final normalizedDate = normalizeDate(date);
                            final attendanceStatus = attendanceMap[normalizedDate];
                            Color backgroundColor;
                            if (attendanceStatus == 'present') {
                              backgroundColor = Colors.green;
                            } else if (attendanceStatus == 'absent') {
                              backgroundColor = Colors.red;
                            } else {
                              backgroundColor = Colors.transparent;
                            }
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: attendanceStatus != null ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, date, _) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: GlobalColors.mainColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          todayBuilder: (context, date, _) {
                            final normalizedDate = normalizeDate(date);
                            final attendanceStatus = attendanceMap[normalizedDate];
                            Color backgroundColor;
                            if (attendanceStatus == 'present') {
                              backgroundColor = Colors.green;
                            } else if (attendanceStatus == 'absent') {
                              backgroundColor = Colors.red;
                            } else {
                              backgroundColor = Colors.transparent;
                            }
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: attendanceStatus != null ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                            updateAttendanceForMonth(focusedDay);
                          });
                        },
                        enabledDayPredicate: (day) {
                          return true;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Attendance Record',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GlobalColors.mainColor,
                          ),
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: sortedAttendanceEntries.length,
                          itemBuilder: (context, index) {
                            DateTime date = sortedAttendanceEntries[index].key;
                            String status = sortedAttendanceEntries[index].value;
                            return ListTile(
                              leading: Icon(
                                status == 'present'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: status == 'present' ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                DateFormat('yyyy-MM-dd').format(date),
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                'Status: ${titleCase(status)}',
                                style: TextStyle(
                                  color: status == 'present' ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRefreshing)
                  Center(child: ModernSpinner(color: GlobalColors.mainColor))
                else if (attendance == null || attendance!.data.isEmpty)
                  Center(
                    child: Text(
                      'No attendance records found!',
                      style: TextStyle(
                        color: GlobalColors.textColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
