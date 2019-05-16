import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import './call.dart';
import './call_voice.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new IndexState();
  }
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textfield is validated to have error
  bool _validateError = false;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Agora Flutter QuickStart'),
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[]),
                  Row(children: <Widget>[
                    Expanded(
                        child: TextField(
                      controller: _channelController,
                      decoration: InputDecoration(
                          errorText: _validateError
                              ? "Channel name is mandatory"
                              : null,
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(width: 1)),
                          hintText: 'Channel name'),
                    ))
                  ]),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            onPressed: () => onJoin('voice'),
                            color: Colors.blueAccent,
                            textColor: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic),
                                Text(" Join")
                              ],
                            )
                          ),
                        ),
                      ],
                    )
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: () => onJoin('video'),
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam),
                              Text(" Join")
                            ],
                          )
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }

  onJoin(type) async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      if (type == 'voice') {
        // 请求麦克风的权限
        await _handleMic();
        // push video page with given channel name
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new CallVoicePage(
                      channelName: _channelController.text,
                    )));
      } else {
        // await for camera and mic permissions before pushing video page
        await _handleCameraAndMic();
        // push video page with given channel name
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new CallPage(
                      channelName: _channelController.text,
                    )));
      }
    }
  }

  _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
        [PermissionGroup.camera, PermissionGroup.microphone]);
  }
  _handleMic() async {
    await PermissionHandler().requestPermissions(
        [PermissionGroup.microphone]);
  }
}
