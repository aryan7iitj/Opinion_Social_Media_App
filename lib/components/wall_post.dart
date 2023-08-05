// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class WallPost extends StatelessWidget {
  final String message;
  final String user;
  // final String time;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    // required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8)
      ),
      margin: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400],
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user,
                style: TextStyle(color: Colors.grey[500]),
              ),
              SizedBox(height: 10),
              Text(message),
            ],
          ),
        ],
      ),
    );
  }
}
