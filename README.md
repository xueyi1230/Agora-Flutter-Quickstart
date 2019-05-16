# Agora Flutter Voice 语音通话应用

在官方的[视频通话demo](https://github.com/AgoraIO-Community/Agora-Flutter-Quickstart)基础上，通过关闭视频模块，修改为语音通话应用。

## 主要修改
/lib/src/pages

* 新增 call_voice.dart 文件
* index.dart 中增加新页面入口

/lib/src/utils

* videosession.dart 模型中增加“是否有音量”字段

## 显示

首页新增语音聊天入口，进入后本地用户显示为固定头像，远端用户显示为随机头像。

## 功能

### （未完成）正在说话的用户提示

[onAudioVolumeIndication](https://docs.agora.io/cn/Video/API%20Reference/java/classio_1_1agora_1_1rtc_1_1_i_rtc_engine_event_handler.html#a4d37f2b4d569fa787bb8c0e3ae8cd424) 监听正在说话的用户以及说话者的音量

API说明：

本地用户独享一个 onAudioVolumeIndication 回调；远端说话者共用一个 onAudioVolumeIndication 回调。

因此在设定的时间周期内，该回调将会触发：

* 一次（本地用户无音量，远端无音量或有音量speakerIds = []或[x]）
* 或两次（[0]、[]；[0]、[x]；[0]、[]）

无法得知哪次调用是本地，哪次是远端。暂时没找到显示/隐藏说话提示的好方法。

## 附录
* Agora 没有专门的 flutter 版本文档，可参考 [Android API 文档](https://docs.agora.io/cn/Video/API%20Reference/java/index.html)进行开发。

* 原项目教程：[基于 Agora Flutter SDK，构建你的第一个 Flutter 视频通话应用](https://rtcdeveloper.com/t/topic/12981)。

---

我是原 README 的分割线

---

*Other languages： [English](README.en.md)*

本教程介绍如何使用[Flutter](https://flutter.io/)创建Agora帐户并使用Agora构建示例应用程序。

## 准备工作
 -  Agora.io [开发者帐户](https://dashboard.agora.io/signin/)
 -  [Flutter](https://flutter.io/) 1.0.0

## 快速开始
这个示例向您展示如何使用Agora Flutter SDK构建一个简单的视频通话应用程序。它向您展示了如何：

 - 加入/离开频道
 - 静音/取消静音
 - 切换摄像头
 - 布局多个视频视图

![screenshot-1](screenshot-1.png)
![screenshot-2](screenshot-2.png)


### 创建一个帐户并获取一个App ID
要构建和运行示例应用程序，请首先获取Agora App ID：

1. 在[agora.io](https://dashboard.agora.io/signin/)创建开发人员帐户。完成注册过程后，您将被重定向到仪表板页面。
2. 在左侧的仪表板树中导航到**项目** > **项目列表**。
3. 将从仪表板获取的App ID复制到文本文件中。您将在启动应用程序时用到它。

### 更新并运行示例应用程序

打开[settings.dart](lib/src/utils/settings.dart)文件并添加App ID。

```dart
  const APP_ID ="";
```

在项目目录中运行`packages get`命令:

```shell
  #install dependencies
  flutter packages get
```

构建完成后，执行`run`命令启动应用程序。

```shell
  #start app
  flutter run
```

**我们建议您在开发期间按照flutter官方引导推荐，使用IDE(包括但不限于VS Code)来控制整体构建过程**

有关如何设置IDE的详细信息，请参阅[此处](https://flutter.io/docs/get-started/editor?tab=vscode)

## 附录
* 开发者中心[API文档](https://docs.agora.io/en/)
* 如果发现了示例代码的bug, 欢迎提交 [issue](https://github.com/AgoraIO/Agora-Interactive-Broadcasting-Live-Streaming-Web/issues)
* [Flutter lab：编写你的第一个Flutter应用程序](https://flutter.io/docs/get-started/codelab)
* [Flutter cookbook](https://flutter.io/docs/cookbook)
* [Flutter在线文档](https://flutter.io/docs)，提供有关移动开发的教程，示例，指南以及完整的API参考。

## License
MIT
