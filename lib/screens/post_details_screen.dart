import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  String postid;
  PostDetailScreen({Key? key, required this.postid}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        widget.postid,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
