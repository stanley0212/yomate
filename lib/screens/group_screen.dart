import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Group'),
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
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 1.5,
                      childAspectRatio: 1),
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    return Column(
                      children: [
                        Container(
                          child: CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              (snap.data()! as dynamic)['Image'],
                            ),
                          ),
                        ),
                        Text((snap.data() as Map<String, dynamic>)['GroupName'])
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
