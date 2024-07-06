import 'package:campus_connect_app/view/exam.view.dart';
import 'package:campus_connect_app/widgets/spinner.widget.dart';
import 'package:flutter/material.dart';
import 'package:campus_connect_app/models/notification.model.dart' as noti;
import 'package:campus_connect_app/services/notification.service.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:campus_connect_app/utils/snackbar.dart';
import 'package:get/get.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<noti.NotificationData> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    dynamic result = await NotificationAPIService().getNotifications();
    if (result is noti.Notification) {
      setState(() {
        notifications = result.data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      generateErrorSnackbar("Error", "Notifications couldn't be fetched!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: GlobalColors.mainColor,
        centerTitle: true,  
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Get.off(() => const ExamView());
          },
        ),
      ),
      body: buildNotificationList(),
    );
  }

  Widget buildNotificationList() {
    if (isLoading) {
      return Center(
        child: ModernSpinner(
          color: GlobalColors.mainColor,
        ),
      );
    } else if (notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications available.',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return buildNotificationItem(notifications[index]);
        },
      );
    }
  }

  Widget buildNotificationItem(noti.NotificationData notification) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            notification.body,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
