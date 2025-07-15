import 'package:flutter/material.dart';
import 'package:quickcash/constants.dart';
import 'package:quickcash/util/auth_manager.dart';

import '../../util/apiConstants.dart';

class MyHeaderDrawer extends StatefulWidget {
  const MyHeaderDrawer({super.key});


  @override
  State<MyHeaderDrawer> createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer>{

  String? profileImageUrl ='${ApiConstants.baseImageUrl}${AuthManager.getUserId()}/${AuthManager.getUserImage()}';


  @override
  Widget build(BuildContext context){
    return Container(
      color: kPrimaryColor,
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: defaultPadding,),

          // Profile Image Section
          if (profileImageUrl != null)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage:
                    NetworkImage(profileImageUrl!),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/profile_pic.png'), // Default Image
              ),
            ),

          Text(
            AuthManager.getUserName(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            AuthManager.getUserEmail(),
            style: TextStyle(
              color: Colors.grey[200],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}