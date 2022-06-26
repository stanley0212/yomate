import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/utils/colors.dart';

import '../screens/post_details_screen.dart';

class NotisCard extends StatefulWidget {
  final snap;
  NotisCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<NotisCard> createState() => _NotisCardState();
}

class _NotisCardState extends State<NotisCard> {
  var userData = {};
  String username = '';
  String userimage = '';
  @override
  getUserData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.snap['userid'])
          .get();
      print(userSnap);
      userData = userSnap.data()!;
      setState(() {
        username = userData['username'];
        userimage = userData['userimage'];
      });
    } catch (e) {}
  }

  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: Color.fromARGB(179, 212, 211, 211),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(userimage),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          PostDetailScreen(postid: widget.snap['postid'])));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: username,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: wordColor),
                          ),
                          TextSpan(
                            style: const TextStyle(color: wordColor),
                            text: ' ${widget.snap['comment']}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat.yMMMEd()
                            .format(widget.snap['time'].toDate()),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: wordColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}
