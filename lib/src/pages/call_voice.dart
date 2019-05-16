import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../utils/videosession.dart';
import '../utils/settings.dart';

class CallVoicePage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// Creates a call page with given channel name.
  const CallVoicePage({Key key, this.channelName}) : super(key: key);

  @override
  _CallVoicePageState createState() {
    return new _CallVoicePageState();
  }
}

class _CallVoicePageState extends State<CallVoicePage> {
  static final _sessions = List<VideoSession>();
  final _infoStrings = <String>[];
  bool muted = false;

  @override
  void dispose() {
    // clean up native views & destroy sdk
    _sessions.forEach((session) {
      AgoraRtcEngine.removeNativeView(session.viewId);
    });
    _sessions.clear();
    AgoraRtcEngine.leaveChannel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
  }

  void initialize() {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings
          .add("APP_ID missing, please provide your APP_ID in settings.dart");
        _infoStrings.add("Agora Engine is not starting");
      });
      return;
    }

    _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // use _addRenderView everytime a native video view is needed
    _addRenderView(0, (viewId) {
      // AgoraRtcEngine.setupLocalVideo(viewId, VideoRenderMode.Hidden);
      // AgoraRtcEngine.startPreview();
      // state can access widget directly
      AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
    });
  }

  /// Create agora sdk instance and initialze
  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(APP_ID);
    // 不启用视频模块（或关闭视频模块），将默认启用语音模式
    // AgoraRtcEngine.enableVideo();
    // 启用说话者音量提示
    AgoraRtcEngine.enableAudioVolumeIndication(500, 1);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (int code) {
      setState(() {
        String info = 'onError: ' + code.toString();
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      setState(() {
        String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        String info = 'userJoined: ' + uid.toString();
        _infoStrings.add(info);
        // _addRenderView(uid, (viewId) {
        //   AgoraRtcEngine.setupRemoteVideo(viewId, VideoRenderMode.Hidden, uid);
        // });
        _addRenderView(uid, null);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        String info = 'userOffline: ' + uid.toString();
        _infoStrings.add(info);
        _removeRenderView(uid);
      });
    };

    // AgoraRtcEngine.onFirstRemoteVideoFrame =
    //     (int uid, int width, int height, int elapsed) {
    //   setState(() {
    //     String info = 'firstRemoteVideo: ' +
    //         uid.toString() +
    //         ' ' +
    //         width.toString() +
    //         'x' +
    //         height.toString();
    //     _infoStrings.add(info);
    //   });
    // };

    // 监听正在说话的用户以及说话者的音量
    AgoraRtcEngine.onAudioVolumeIndication = (totalVolume, speakers) {
      // 本地用户独享一个 onAudioVolumeIndication 回调；远端说话者共用一个 onAudioVolumeIndication 回调
      // 因此在设定的时间周期内，该回调将会触发
      // 一次（本地用户无音量，远端无音量或有音量speakerIds = []或[x]）
      // 或两次（[0]、[]；[0]、[x]；[0]、[]）
      // 无法得知哪次调用是本地，哪次是远端
      // List speakerIds = speakers.map((speaker) => speaker.uid).toList();
      // print('______________');
      // print(totalVolume);
      // print(speakerIds);
      // bool hasSpeaker = speakerIds.length != 0;
      // if (hasSpeaker) {
      //   print(speakers[0].volume);
      // }
      // // setState(() {
      // //   _sessions.forEach((session) {
      // //     session.hasVolume = speakerIds.indexOf(session.uid) > -1;
      // //   });
      // // });
      // print('==================');
    };
  }

  /// Create a native view and add a new video session object
  /// The native viewId can be used to set up local/remote view
  void _addRenderView(int uid, Function(int viewId) finished) {
    Widget view = AgoraRtcEngine.createNativeView(uid, (viewId) {
      setState(() {
        _getVideoSession(uid).viewId = viewId;
        if (finished != null) {
          finished(viewId);
        }
      });
    });

    VideoSession session = VideoSession(uid, view);
    _sessions.add(session);
  }

  /// Remove a native view and remove an existing video session object
  void _removeRenderView(int uid) {
    VideoSession session = _getVideoSession(uid);
    if (session != null) {
      _sessions.remove(session);
    }
    AgoraRtcEngine.removeNativeView(session.viewId);
  }

  /// Helper function to filter video session with uid
  VideoSession _getVideoSession(int uid) {
    return _sessions.firstWhere((session) {
      return session.uid == uid;
    });
  }

  /// Helper function to get list of native views
  // List<Widget> _getRenderViews() {
  //   return _sessions.map((session) => session.view).toList();
  // }

  // 标识正在说话的用户
  Widget _iconInSpeech() {
    final icon = Icons.record_voice_over;

    return Stack(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54, //颜色
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 4.0, 4.0, 5.0),
            child: Icon(icon, color: Colors.white, size: 18.0),
          ),
        ),
      ],
    );
  }
  /// Video view wrapper
  // Widget _videoView(session) {
  //   return Expanded(child: Container(child: session.view));
  // }
  // 将原本的视频窗口改成头像小窗口
  Widget _videoView(session) {
    final size = MediaQuery.of(context).size;
    Widget myAvatar = Image.asset(
      'images/avatar.jpg',
      fit: BoxFit.cover,
    );
    Widget remoteAvatar = Image.network(
      'https://www.gravatar.com/avatar/${session.uid}?d=identicon&s=400',
      fit: BoxFit.cover,
    );

    return Container(
      width: size.width / 2,
      height: size.width / 2,
      decoration: BoxDecoration(
        border: Border.all(width: 8.0, color: Colors.white),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 不插入 view 组件，无法调起加入频道等相关事件
          session.view,
          Container(
            color: Colors.white,
            child: session.uid == 0 ? myAvatar : remoteAvatar,
          ),
          Positioned(
            right: 5.0,
            bottom: 5.0,
            child: session.hasVolume ? _iconInSpeech() : Container(),
          )
        ],
      )
    );
  }

  /// Video view row wrapper
  // 传入单个窗口的 view 替换为 session，以便获取每个 session 是否有音量的状态
  // Widget _expandedVideoRow(List<Widget> views) {
  Widget _expandedVideoRow(List<VideoSession> sessions) {
    List<Widget> wrappedViews =
        // views.map((Widget view) => _videoView(view)).toList();
        sessions.map((session) => _videoView(session)).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      )
    );
  }

  Widget _viewColumn() {
    switch (_sessions.length) {
      case 1:
        return Column(
          children: <Widget>[
            _expandedVideoRow([_sessions[0]])
          ],
        );
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([_sessions[0], _sessions[1]])
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(_sessions.sublist(0, 2)),
            _expandedVideoRow(_sessions.sublist(2, 3)),
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(_sessions.sublist(0, 2)),
            _expandedVideoRow(_sessions.sublist(2, 4))
          ],
        );
      default:
    }
    return Container();
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.width,
      child: _viewColumn(),
    );
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: () => _onToggleMute(),
            child: new Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: new Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: new CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          // 去掉翻转摄像头的操作
          // RawMaterialButton(
          //   onPressed: () => _onSwitchCamera(),
          //   child: new Icon(
          //     Icons.switch_camera,
          //     color: Colors.blueAccent,
          //     size: 20.0,
          //   ),
          //   shape: new CircleBorder(),
          //   elevation: 2.0,
          //   fillColor: Colors.white,
          //   padding: const      EdgeInsets.all(12.0),
          // )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.length == 0) {
                return null;
              }
              return Padding(
                padding:
                  EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 2, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey)
                        )
                      )
                    )
                  ]
                )
              );
            }
          )
        ),
      )
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  // void _onSwitchCamera() {
  //   AgoraRtcEngine.switchCamera();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agora Flutter QuickStart'),
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Stack(
          children: <Widget>[_viewRows(), _panel(), _toolbar()],
        )
      )
    );
  }
}
