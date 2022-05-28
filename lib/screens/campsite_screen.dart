import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/utils/colors.dart';
import 'package:yomate/utils/global_variables.dart';
import 'package:yomate/widgets/campsite_card.dart';
import 'package:yomate/widgets/post_card.dart';

import '../providers/user_provider.dart';

class CampsiteScreen extends StatefulWidget {
  const CampsiteScreen({Key? key}) : super(key: key);

  @override
  _CampsiteScreenState createState() => _CampsiteScreenState();
}

class _CampsiteScreenState extends State<CampsiteScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications),
                ),
              ],
            ),
    );
  }
}
