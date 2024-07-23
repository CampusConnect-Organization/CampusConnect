// To parse this JSON data, do
//
//     final attendance = attendanceFromJson(jsonString);

import 'dart:convert';

Attendance attendanceFromJson(String str) => Attendance.fromJson(json.decode(str));

String attendanceToJson(Attendance data) => json.encode(data.toJson());

class Attendance {
    bool success;
    List<AttendanceData> data;
    String message;

    Attendance({
        required this.success,
        required this.data,
        required this.message,
    });

    factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        success: json["success"],
        data: List<AttendanceData>.from(json["data"].map((x) => AttendanceData.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class AttendanceData {
    int id;
    String studentName;
    String courseSession;
    String status;
    String date;
    int student;

    AttendanceData({
        required this.id,
        required this.studentName,
        required this.courseSession,
        required this.status,
        required this.date,
        required this.student,
    });

    factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
        id: json["id"],
        studentName: json["student_name"],
        courseSession: json["course_session"],
        status: json["status"],
        date: json["date"],
        student: json["student"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "student_name": studentName,
        "course_session": courseSession,
        "status": status,
        "date": date,
        "student": student,
    };
}
