import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenImage extends StatefulWidget {
  String imageUrl;
  FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _animation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset? _normalizedOffset;
  double? _previousScale;
  double _kMinFlingVelocity = 600.0;
  bool _isEnlarge = false;
  bool _isHideTitleBar = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller?.addListener(() {
      setState(() {
        _offset = _animation!.value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Size? size = context.size;
    // widget的屏幕宽度
    final Offset minOffset = Offset(size!.width, size!.height) * (1.0 - _scale);
    // 限制他的最小尺寸
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _isHideTitleBar = true;
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // 计算图片放大后的位置
      _controller!.stop();
    });
  }

  _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale! * details.scale).clamp(1.0, 3.0);
      // 限制放大倍数 1~3倍
      _offset = _clampOffset(details.focalPoint - _normalizedOffset! * _scale);
      // 更新当前位置
    });
  }

  _handleOnScaleEnd(ScaleEndDetails details) {
    _setSystemUi();
    final double magnitude = details.velocity.pixelsPerSecond.distanceSquared;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    // 计算当前的方向
    // final double distance = (Offset.zero & context.size).shortestSide;
    // // 计算放大倍速，并相应的放大宽和高，比如原来是600*480的图片，放大后倍数为1.25倍时，宽和高是同时变化的
    // _animation = _controller!.drive(Tween<Offset>(
    //     begin: _offset, end: _clampOffset(_offset + direction * distance)));
    _controller
      ?..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  _onDoubleTap() {
    _isHideTitleBar = true;
    _setSystemUi();
    Size? size = context.size;
    _isEnlarge = !_isEnlarge;
    setState(() {
      if (!_isEnlarge) {
        _scale = 2.0;
        _offset = Offset(-(size!.width / 2), -(size.height / 2));
      } else {
        _scale = 1.0;
        _offset = Offset.zero;
      }
    });
  }

  _onTap() {
    setState(() {
      _isHideTitleBar = !_isHideTitleBar;
    });
    _setSystemUi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: [
          _bodyView(),
          //_titleBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 0, 0),
            child: Row(
              children: [
                IconButton(
                  color: Colors.orange,
                  iconSize: 24,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _bodyView() {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      onDoubleTap: _onDoubleTap,
      onTap: _onTap,
      child: Container(
        color: _isHideTitleBar ? Colors.black : Colors.white,
        child: SizedBox.expand(
          child: ClipRect(
            child: Transform(
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_scale),
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                // placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                ),
              ),
            ),
            // child: Image.network(widget.url,fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }

  // _titleBar() {
  //   return Offstage(
  //     child: Container(
  //       alignment: Alignment.centerLeft,
  //       // padding: EdgeInsets.only(top: MediaQueryData.fromWindow(window).padding.top,
  //       // left: ScreenUtil().setWidth(24)),
  //       color: Colors.white,
  //       height: MediaQuery.of(context).size.height,
  //       width: MediaQuery.of(context).size.width,
  //       child: GestureDetector(
  //         child: Icon(Icons.arrow_back),
  //         onTap: () {
  //           Navigator.pop(context);
  //         },
  //       ),
  //     ),
  //     offstage: _isHideTitleBar,
  //   );
  // }

  _setSystemUi() {
    if (_isHideTitleBar) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
  }
}
