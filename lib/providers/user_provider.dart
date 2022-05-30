import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yomate/models/user.dart';
import 'package:yomate/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user = User(
      bio: 'yomate',
      blue_check: '0',
      coins: 0,
      country: 'Australia',
      email: 'yomate@yomate.com',
      followers: [],
      following: [],
      id: '123',
      password: '123',
      userimage: '',
      username: 'yomate');
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
