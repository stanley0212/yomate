import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yomate/widgets/notis_card.dart';

import '../utils/colors.dart';
import '../utils/global_variables.dart';

class NotificationScreen extends StatefulWidget {
  String userID;
  NotificationScreen({Key? key, required this.userID}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height * 0.75;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: true,
              title: Text(
                'Notification',
                style: TextStyle(color: Colors.black),
              ),
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
              ),
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Notifications')
            .where('received',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          //print(context);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            //print("ok");
          }
          return Container(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  if (index % 10 == 0) {
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  width > webScreenSize ? width * 0.3 : 0,
                              vertical: width > webScreenSize ? 15 : 0),
                          child: NotisCard(
                            snap: snapshot.data!.docs[index],
                          ),
                        ),
                      ],
                    );
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: width > webScreenSize ? width * 0.3 : 0,
                        vertical: width > webScreenSize ? 15 : 0),
                    child: NotisCard(
                      snap: snapshot.data!.docs[index],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 1.0,
                  );
                },
                itemCount: 50),
          );
        },
      ),
    );
  }
}
