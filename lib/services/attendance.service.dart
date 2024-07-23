import 'dart:developer';
import 'dart:io';

import 'package:campus_connect_app/models/attendance/attendance.model.dart';
import 'package:campus_connect_app/models/error.model.dart';
import 'package:campus_connect_app/utils/constants.dart';
import 'package:campus_connect_app/view/login.view.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AttendanceAPIService{
  Future<dynamic> getAttendances(int courseSessionId) async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.listAttendanceEndpoint}$courseSessionId");
      Object? accessToken = prefs.get("accessToken");
      if (accessToken == null) {
        Get.off(() => const LoginView());
      }

    var response = await http.get(url, headers: {"Authorization": "Bearer $accessToken"});
    if(response.statusCode == 200){
      Attendance attendance = attendanceFromJson(response.body);
      return attendance;
    }else{
      Errors errors = errorsFromJson(response.body);
      return errors;
    }
    }catch(error){
      log(error.toString());
    }
  }

  Future<dynamic> markAttendance(int courseSessionId, File image) async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var url = Uri.parse("${ApiConstants.baseUrl}${ApiConstants.markAttendanceEndpoint}");
      Object? accessToken = prefs.get("accessToken");
      if (accessToken == null) {
        Get.off(() => const LoginView());
      }

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll({"Authorization": "Bearer $accessToken"})
      ..files.add(await http.MultipartFile.fromPath('file', image.path))
      ..fields['course_session'] = courseSessionId.toString();

    var response = await request.send();
    
    return response;
    }catch(error){
      log(error.toString());
    }
  }
}