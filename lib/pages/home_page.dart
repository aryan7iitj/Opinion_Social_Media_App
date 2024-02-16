// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unused_import, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opinion/components/text_field.dart';
import 'package:opinion/components/wall_post.dart';
import 'package:opinion/components/drawer.dart';
import 'package:opinion/helper/helper_methods.dart';
import 'package:opinion/main.dart';
import 'package:opinion/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final textController = TextEditingController();
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'Timestamp': Timestamp.now(),
        'Likes': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }

  void goToProfilePage() {
    Navigator.pop(context);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Opinion'),
        centerTitle: true,
        
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .orderBy(
                          "Timestamp",
                          descending: false,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];
                            return WallPost(
                                message: post['Message'],
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                time: formatDate(post['Timestamp']),
                                user: post['UserEmail']);
                                
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error:${snapshot.error}"),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    })),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                        controller: textController,
                        hintText: "Write Opinion on Something...",
                        obscureText: false),
                  ),
                  IconButton(
                      onPressed: postMessage,
                      icon: const Icon(Icons.arrow_circle_up)),
                ],
              ),
            ),
            Text(
              "Logged in as: " + currentUser.email!,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
