// ignore_for_file: prefer_const_constructors

import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opinion/components/comment.dart';
import 'package:opinion/components/comment_button.dart';
import 'package:opinion/components/like_button.dart';
import 'package:opinion/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String time;
  // final String time;
  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      // required this.time,
      required this.postId,
      required this.likes,
      required this.time});

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final _commentTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  // toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //acess document is Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void showCommentDialog() {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a Comment...."),
        ),
        actions: [
          TextButton(
            onPressed: () => {
              addComment(_commentTextController.text),
              Navigator.pop(context),
              _commentTextController.clear()
            },
            child: Text("Post"),
          ),
          TextButton(
            onPressed: () =>
                {Navigator.pop(context), _commentTextController.clear()},
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    '.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  //like button
                  LikeButton(isLiked: isLiked, onTap: toggleLike),
                  //like count
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  //like button
                  CommentButton(onTap: showCommentDialog),
                  //like count
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '0',
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comment(
                      user: commentData["CommentedBy"],
                      text: commentData["CommentText"],
                      time: formatDate(commentData["CommentTime"]));
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
