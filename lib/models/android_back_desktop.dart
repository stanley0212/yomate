import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AndroidBackTop {
  //初始化通信管道-設置退出到手機桌面
  static const String CHANNEL = "android/back/desktop";
  //設置回退到手機桌面
  static Future<bool> backDeskTop() async {
    final platform = MethodChannel(CHANNEL);
    //通知安卓返回,到手機桌面
    try {
      final bool out = await platform.invokeMethod('backDesktop');
      if (out) debugPrint('返回到桌面');
    } on PlatformException catch (e) {
      debugPrint("通信失敗(設置回退到安卓手機桌面:設置失敗)");
      print(e.toString());
    }
    return Future.value(false);
  }
}
