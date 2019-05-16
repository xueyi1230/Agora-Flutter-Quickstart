import 'package:flutter/material.dart';

class VideoSession {
  int uid;
  Widget view;
  int viewId;
  // 增加是否有音量（在说话）的标识
  bool hasVolume;

  VideoSession(int uid, Widget view, {bool hasVolume = false}) {
    this.uid = uid;
    this.view = view;
    this.hasVolume = hasVolume;
  }
}
