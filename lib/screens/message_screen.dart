// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cupertino_list_tile/cupertino_list_tile.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class MessageScreen extends StatelessWidget {
//   const MessageScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('Chats').snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) {
//           return const Center(
//             child: Text("Something went wrong."),
//           );
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Text("Loading..."),
//           );
//         }
//         if (snapshot.hasData) {}
//         return CustomScrollView(
//           slivers: [
//             const CupertinoSliverNavigationBar(
//               largeTitle: Text("Message"),
//               backgroundColor: Colors.white54,
//             ),
//             SliverList(
//                 delegate: SliverChildListDelegate(
//                     snapshot.data!.docs.map((DocumentSnapshot document) {
//               //Map<String, dynamic> data = document.data()!;
//               return const CupertinoListTile(
//                 title: Text(''),
//               );
//             }).toList()))
//           ],
//         );
//       },
//     );
//   }
// }
