import 'package:flutter/material.dart';

class ApiConstants {
  static String baseUrl = 'http://ec2-52-90-163-66.compute-1.amazonaws.com:8000/';
  static String loginEndpoint = 'api/auth/login/';
  static String registerEndpoint = 'api/auth/register/';
  static String profileEndpoint = "api/student-profile/";
  static String coursesEndpoint = "api/courses/courses/";
  static String courseSessionsEndpoint = "api/courses/sessions/";
  static String studentCoursesEndpoint = "api/courses/student-courses/";
  static String courseEnrollmentsEndpoint = "api/courses/enrollments/";
  static String examsEndpoint = "api/grades/exams/";
  static String resultsEndpoint = "api/results/";
  static String booksEndpoint = "api/library/books/";
  static String bookInstancesEndpoint = "api/library/book-instances/";
  static String borrowsEndpoint = "api/library/borrows/";
  static String borrowBookEndpoint = "api/library/borrow-book/";
  static String returnsEndpoint = "api/library/returns/";
  static String returnBookEndpoint = "api/library/return-book/";
  static String registerFCMEndpoint = "api/notification/register-fcm/";
  static String notificationEndpoint = "api/notification/";
}

String titleCase(String input) {
  if (input.isEmpty) {
    return input;
  }

  List<String> words = input.toLowerCase().split(' ');

  for (int i = 0; i < words.length; i++) {
    words[i] = words[i][0].toUpperCase() + words[i].substring(1);
  }

  return words.join(' ');
}

Expanded getExpanded(
    String image, String mainText, String subText, Function()? onTap) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                "images/$image.png",
                height: 70.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              mainText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              subText,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.0,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

