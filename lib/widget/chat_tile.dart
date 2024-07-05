import 'package:flutter/material.dart';
import '../models/profile.dart';

class ChatTile extends StatelessWidget {
  final Profile userProfile;
  final Function onTap;

  const ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      title: Text(userProfile.name),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 30.0,
        child: ClipOval(
          child: FadeInImage.assetNetwork(
            placeholder:
                'assets/lottie_animations/loading.gif', // Make sure you have loading.gif in your assets
            image: userProfile.pfpURL,
            fit: BoxFit.cover,
            width: 60.0, // Ensuring the image fits within the CircleAvatar
            height: 60.0,
            imageErrorBuilder: (context, error, stackTrace) {
              return Icon(Icons
                  .error); // Display an error icon if the image fails to load
            },
          ),
        ),
      ),
    );
  }
}
