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
  bool isUploading = false; // Added flag to track image upload status
  late Errors errors;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchAttendances();
  }

  Future<dynamic> fetchAttendances() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      dynamic data =
          await AttendanceAPIService().getAttendances(widget.courseSessionId);
      if (data is Attendance) {
        setState(() {
          attendance = data;
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
    } finally {
      setState(() {
        isRefreshing = false;
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
      isUploading = true; // Show the loader
    });

    try {
      var response = await AttendanceAPIService()
          .markAttendance(widget.courseSessionId, imageFile);

      if (response.statusCode == 200) {
        generateSuccessSnackbar("Success", "Attendance taken successfully!");
        await fetchAttendances();
      }else if(response.statusCode == 400){
        generateErrorSnackbar("Error", "You are not allowed to take attendance or other students");
      }else if(response.statusCode == 418){
        generateErrorSnackbar("Error", "No student found!");
      }
       else {
        generateErrorSnackbar(
            "Error", "Failed to upload image: ${response.body}");
      }
    } catch (e) {
      generateErrorSnackbar("Error",
          "Attendance already taken today or an unspecified error occurred!");
    } finally {
      setState(() {
        isUploading = false; // Hide the loader
      });
    }
  }

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat.yMMMMd().format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: fetchAttendances,
            child: attendance != null
                ? ListView.builder(
                    itemCount: attendance?.data.length,
                    itemBuilder: (context, index) {
                      var currentItem = attendance?.data[index];

                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(currentItem!.date),
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            GreyText(
                                text: "Student: ${currentItem.studentName}"),
                            const SizedBox(height: 10),
                            GreyText(
                                text:
                                    "Status: ${titleCase(currentItem.status)}"),
                          ],
                        ),
                      );
                    },
                  )
                : isRefreshing
                    ? Center(
                        child: ModernSpinner(color: GlobalColors.mainColor))
                    : const Center(
                        child: Text("No attendance records found!"),
                      ),
          ),
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: ModernSpinner(
                  color: GlobalColors.mainColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
