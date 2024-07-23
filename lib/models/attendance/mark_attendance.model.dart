// To parse this JSON data, do
//
//     final markAttendance = markAttendanceFromJson(jsonString);

import 'dart:convert';

MarkAttendance markAttendanceFromJson(String str) => MarkAttendance.fromJson(json.decode(str));

String markAttendanceToJson(MarkAttendance data) => json.encode(data.toJson());

class MarkAttendance {
    bool success;
    dynamic data;
    String message;

    MarkAttendance({
        required this.success,
        required this.data,
        required this.message,
    });

    factory MarkAttendance.fromJson(Map<String, dynamic> json) => MarkAttendance(
        success: json["success"],
        data: json["data"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data,
        "message": message,
    };
}
