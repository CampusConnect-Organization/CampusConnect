import 'package:campus_connect_app/view/attendance/attendance.view.dart';
import 'package:campus_connect_app/view/home.view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_connect_app/models/courses/course.enrollments.model.dart';
import 'package:campus_connect_app/models/error.model.dart';
import 'package:campus_connect_app/services/course.service.dart';
import 'package:campus_connect_app/utils/snackbar.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:campus_connect_app/widgets/greyText.widget.dart';
import 'package:campus_connect_app/widgets/spinner.widget.dart';

class AttendanceCourseSession extends StatefulWidget {
  const AttendanceCourseSession({Key? key}) : super(key: key);

  @override
  State<AttendanceCourseSession> createState() =>
      _AttendanceCourseSessionState();
}

class _AttendanceCourseSessionState extends State<AttendanceCourseSession> {
  CourseEnrollments? enrollments;
  bool isRefreshing = false;
  late Errors errors;

  @override
  void initState() {
    super.initState();
    fetchEnrollments();
  }

  Future<dynamic> fetchEnrollments() async {
    setState(() {
      isRefreshing = true;
    });

    try {
      dynamic data = await CourseAPIService().getCourseEnrollments();
      if (data is CourseEnrollments) {
        setState(() {
          enrollments = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance - Course Enrollments",
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
            Get.off(() => const HomeView());
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchEnrollments,
        child: enrollments != null
            ? ListView.builder(
                itemCount: enrollments?.data.length,
                itemBuilder: (context, index) {
                  List<Datummmm>? enrolls = enrollments?.data;
                  var currentItem = enrolls?[index];

                  return InkWell(
                    onTap: () {
                      Get.to(() => AttendanceDetail(
                          courseSessionId: currentItem.courseSessionId));
                    },
                    child: Container(
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
                        children: [
                          Text(
                            currentItem!.courseSessionName,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(height: 10),
                          GreyText(
                              text:
                                  "Duration: ${currentItem.startDate} - ${currentItem.endDate}"),
                          const SizedBox(height: 10),
                          GreyText(
                              text:
                                  "Instructor: ${currentItem.instructorName}"),
                          const SizedBox(height: 10),
                          GreyText(text: "Semester: ${currentItem.semester}"),
                        ],
                      ),
                    ),
                  );
                },
              )
            : isRefreshing
                ? Center(child: ModernSpinner(color: GlobalColors.mainColor))
                : const Center(
                    child: Text("You haven't enrolled in any courses!"),
                  ),
      ),
    );
  }
}
