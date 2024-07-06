import 'package:campus_connect_app/utils/constants.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    Key? key,
    required this.profilePicture,
    required this.firstName,
  }) : super(key: key);

  final String profilePicture;
  final String firstName;

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: GlobalColors.mainColor,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                  title: Text(
                    "Hi, ${widget.firstName}!",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Welcome to Campus Connect",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white54, fontSize: 14.0),
                  ),
                  trailing: CircleAvatar(
                    radius: 40.0,
                    backgroundImage: NetworkImage(
                        ApiConstants.baseUrl + widget.profilePicture),
                  ),
                ),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
