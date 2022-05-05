import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/widgets/post_card.dart';

import '../providers/user_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    //Provider.of<UserProvider>(context).refreshUser();
    final User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/yomate_new_logo.svg',
                //color: primaryColor,
                height: 48,
              ),
              actions: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white54,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.message_outlined,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white54,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications),
                  ),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            //.where('country', isEqualTo: user.country)
            //.where('country', isEqualTo: 'Australia')
            .orderBy('time', descending: true) //倒序開啟
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0),
              child: PostCard(
                snap: snapshot.data!.docs[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
