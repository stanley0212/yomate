import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yomate/screens/group_details_screen.dart';
import 'package:yomate/utils/colors.dart';

import '../utils/global_variables.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TextEditingController groupController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    groupController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/yomate_new_logo.svg',
          //color: primaryColor,
          height: 40,
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Group')
                  .where('GroupName',
                      isGreaterThanOrEqualTo: groupController.text)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: InkWell(
                        // onTap: (() => Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //         builder: (context) => ProfileScreen(
                        //           uid: (snapshot.data! as dynamic).docs[index]
                        //               ['id'],
                        //         ),
                        //       ),
                        //     )),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white54,
                            backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]['Image'],
                            ),
                          ),
                          title: Text(
                            (snapshot.data! as dynamic).docs[index]
                                ['GroupName'],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Group')
                  //.where('imageType', isEqualTo: 'image')
                  //.orderBy('time', descending: true)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 1.5,
                      childAspectRatio: 0.9),
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => GroupDetailScreen(
                                    groupType:
                                        (snap.data()! as dynamic)['GroupName'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white54,
                                backgroundImage: NetworkImage(
                                  (snap.data()! as dynamic)['Image'],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            (snap.data() as Map<String, dynamic>)['GroupName'],
                            style: TextStyle(color: wordColor),
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
