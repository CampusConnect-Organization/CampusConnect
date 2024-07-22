import 'package:campus_connect_app/utils/constants.dart';
import 'package:campus_connect_app/utils/global.colors.dart';
import 'package:campus_connect_app/widgets/spinner.widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({
    Key? key,
    required this.profilePicture,
    required this.firstName,
  }) : super(key: key);

  final String profilePicture;
  final String firstName;

  @override
  ProfileWidgetState createState() => ProfileWidgetState();
}

class ProfileWidgetState extends State<ProfileWidget> {
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
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: ApiConstants.baseUrl + widget.profilePicture,
                        placeholder: (context, url) => const ModernSpinner(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.cover,
                      ),
                    ),
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
