import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yomate/resources/auth_methods.dart';
import 'package:yomate/responsive/firestore_methods.dart';
import 'package:yomate/screens/edit_profile_screen.dart';
import 'package:yomate/screens/login_screen.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/utils/utils.dart';
import 'package:yomate/widgets/follow_button.dart';

class FollowProfileScreen extends StatefulWidget {
  final String uid;
  const FollowProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<FollowProfileScreen> createState() => _FollowProfileScreenState();
}

class _FollowProfileScreenState extends State<FollowProfileScreen> {
  var userData = {};
  int PostLen = 0;
  int followers = 0;
  int following = 0;
  int ycoins = 0;
  bool isFollowing = false;
  bool isLoading = false;
  String username = "";
  String bio = "";
  String userimage = "";
  String currentUsername = "";

  //Show Video
  bool isPlaying = true;
  bool isPlayingLoop = true;
  late VideoPlayerController _controller;
  String data = 'video';

  //Chatroom
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();

    getData();
    if (data != 'image') {
      _controller = VideoPlayerController.network('')
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          //even before the play button has been pressed.
          setState(() {
            _controller.seekTo(Duration(milliseconds: 2));
          });
        });
      _controller.pause();

      _controller.setLooping(isPlayingLoop);
      //_controller.value.isPlaying ? _controller.pause() : _controller.play();
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.uid)
          .get();
      var currentUsernameSnap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      var PostSnap = await FirebaseFirestore.instance
          .collection('Posts')
          .where('publisher', isEqualTo: widget.uid)
          .get();
      PostLen = PostSnap.docs.length;
      userData = userSnap.data()!;
      ycoins = userSnap.data()!['coins'];
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(widget.uid);

      await FirebaseFirestore.instance
          .collection('Users')
          .where("email", isEqualTo: userSnap['email'])
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
        //print(userMap);
      });

      setState(() {
        username = userData['username'];
        bio = userData['bio'];
        userimage = userData['userimage'];
        currentUsername = currentUsernameSnap['username'];
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: width > webScreenSize
                ? webBackgroundColor
                : mobileBackgroundColor,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white54,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              title: Text(
                username,
                style: const TextStyle(color: wordColor),
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(userimage),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(PostLen, "Posts"),
                                    buildStatColumn(ycoins, "Y-Coins"),
                                    buildStatColumn(followers, "Followers"),
                                    buildStatColumn(following, "Following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            borderColor: Colors.grey,
                                            text: 'Edit Profile',
                                            //text: 'Sign out',
                                            textColor: wordColor,
                                            function: () async {
                                              //await AuthMethods().signOut();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const EditProfileScteen(),
                                                ),
                                              );
                                            },
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                backgroundColor: Colors.white,
                                                borderColor: Colors.grey,
                                                text: 'Unfollow',
                                                textColor: Colors.black,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['id'],
                                                  );
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                backgroundColor: Colors.blue,
                                                borderColor: Colors.grey,
                                                text: 'Follow',
                                                textColor: Colors.white,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['id'],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
                                              ),
                                  ],
                                ),
                                // FollowButton(
                                //   backgroundColor: mobileBackgroundColor,
                                //   borderColor: Colors.grey,
                                //   text: 'Message',
                                //   textColor: wordColor,
                                //   function: () {},
                                // )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: wordColor),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          bio,
                          style: const TextStyle(color: wordColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('Posts')
                      .where('publisher', isEqualTo: widget.uid)
                      //.where('imageType', isEqualTo: 'image')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];
                        return SizedBox(
                          child: snap['imageType'] == 'image'
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        (snap.data()! as dynamic)['postimage'],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: CircleAvatar(
                                    radius: 16.0,
                                    child: Icon(Icons.play_circle),
                                  ),
                                ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: wordColor),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
