import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/providers/user_provider.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/utils/colors.dart';

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  _CommentCardState createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profilePic']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: wordColor),
                        ),
                        TextSpan(
                          style: const TextStyle(color: wordColor),
                          text: ' ${widget.snap['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMEd()
                          .format(widget.snap['datePublished'].toDate()),
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
          //Stnaley mark 05/05/2022 Comment cannot delete
          // widget.snap['id'].toString() == user.id
          //     ? IconButton(
          //         onPressed: () {
          //           showDialog(
          //             useRootNavigator: false,
          //             context: context,
          //             builder: (context) {
          //               return Dialog(
          //                 child: ListView(
          //                     padding: const EdgeInsets.symmetric(vertical: 16),
          //                     shrinkWrap: true,
          //                     children: [
          //                       'Delete',
          //                     ]
          //                         .map(
          //                           (e) => InkWell(
          //                               child: Container(
          //                                 padding: const EdgeInsets.symmetric(
          //                                     vertical: 12, horizontal: 16),
          //                                 child: Text(e),
          //                               ),
          //                               onTap: () {
          //                                 print(widget.snap['id'].toString());
          //                                 // FirestoreMethods().deleteComment(
          //                                 //   widget.snap['id'].toString(),
          //                                 // );
          //                                 // remove the dialog box
          //                                 Navigator.of(context).pop();
          //                               }),
          //                         )
          //                         .toList()),
          //               );
          //             },
          //           );
          //         },
          //         icon: const CircleAvatar(
          //             radius: 16,
          //             backgroundColor: Colors.white54,
          //             child: Icon(Icons.more_vert)),
          //       )
          //     : Container(),
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
