import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:eshop/Helper/Session.dart';
import 'package:eshop/Helper/String.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Model/Model.dart';

class Chat extends StatefulWidget {
  final String id,status;
  const Chat({Key key, this.id, this.status}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController msgController = new TextEditingController();
  List<File> files = [];
  List<Model> chatList = [];
  Map<String, String> downloadlist;
  String _filePath = "";

  @override
  void initState() {
    super.initState();
    downloadlist = new Map<String, String>();

    FlutterDownloader.registerCallback(downloadCallback);
    getMsg();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print(
        'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(getTranslated(context, 'CHAT'), context),
      body: Column(
        children: <Widget>[buildListMessage(), msgRow()],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, index) => msgItem(index, chatList[index]),
        itemCount: chatList.length,
        reverse: true,
        //  controller: _scrollController,
      ),
    );
  }

  Widget msgItem(int index, Model message) {
    /*String filetype = message.attachment_mime_type.trim();
    String file = message.attachments;*/

    if (message.uid == CUR_USERID) {
      //Own message
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
        ],
      );
    } else {
      //Other's message
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
  }

  Widget MsgContent(int index, Model message) {
    //String filetype = message.attachment_mime_type.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: message.uid == CUR_USERID
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        message.uid == CUR_USERID
            ? Container()
            : Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ClipOval(child:
                    // message.profile == null || message.profile.isEmpty? Image.asset("assets/images/placeholder.png",width: 25, height: 25,)
                    //     :FadeInImage.assetNetwork(
                    //   image: message.profile,
                    //   placeholder: "assets/images/placeholder.png",
                    //   width: 25,
                    //   height: 25,
                    //   fit: BoxFit.cover,
                    // )),
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(capitalize(message.name),
                          style:
                              TextStyle(color: colors.primary, fontSize: 12)),
                    )
                  ],
                ),
              ),
        ListView.builder(
            itemBuilder: (context, index) {
              return attachItem(message.attach, index, message);
            },
            itemCount: message.attach.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true),
        Card(
          //margin: EdgeInsets.only(right: message.sender_id == myid ? 10 : 50, left: message.sender_id == myid ? 50 : 10, bottom: 10),
          elevation: 0.0,
          color: message.uid == CUR_USERID
              ? colors.fontColor.withOpacity(0.1)
              : colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Column(
              crossAxisAlignment: message.uid == CUR_USERID
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                //_messages[index].issend ? Container() : Center(child: SizedBox(height:20,width: 20,child: new CircularProgressIndicator(backgroundColor: ColorsRes.secondgradientcolor,))),

                Text("${message.msg}", style: TextStyle(color: colors.black)),
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 5),
                  child: Text((message.date),
                      style: TextStyle(color: colors.lightBlack, fontSize: 9)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _requestDownload(String url, String mid) async {
    bool checkpermission = await Checkpermission();
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        _filePath = target.path.toString();
      } else {
        Directory downloadsDirectory =
            await DownloadsPathProvider.downloadsDirectory;
        _filePath = downloadsDirectory.path.toString();
      }

      String fileName = url.substring(url.lastIndexOf("/") + 1);
      File file = new File(_filePath + "/" + fileName);
      bool hasExisted = await file.exists();
      print("===test===$hasExisted=======$url***$_filePath");

      if (downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query:
                "SELECT status FROM task WHERE task_id=${downloadlist[mid]}");

        if (tasks == 4 || tasks == 5) downloadlist.remove(mid);
      }

      if (hasExisted) {
        final _openFile = await OpenFile.open(_filePath + "/" + fileName);
      } else if (downloadlist.containsKey(mid)) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getTranslated(context, 'Downloading'))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(getTranslated(context, 'Downloading'))));
        final taskid = await FlutterDownloader.enqueue(
            url: url,
            savedDir: _filePath,
            headers: {"auth": "test_for_sql_encoding"},
            showNotification: true,
            openFileFromNotification: true);
        print("====taskid==" + taskid + "=====" + mid);
        setState(() {
          downloadlist[mid] = taskid.toString();
        });
      }
    }
  }

  Future<bool> Checkpermission() async {
    var status = await Permission.storage.status;
    print("permission==$status");
    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        FileDirectoryPrepare();
        return true;
      }
    } else {
      FileDirectoryPrepare();
      return true;
    }
  }

  Future<Null> FileDirectoryPrepare() async {
    // _filePath = (await _findLocalPath()) +
    //     Platform.pathSeparator +
    //     'Download'; //"${StringsRes.mainappname}";

    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      _filePath = target.path.toString();
    } else {
      Directory downloadsDirectory =
          await DownloadsPathProvider.downloadsDirectory;
      _filePath = downloadsDirectory.path.toString();
    }

    // final savedDir = Directory(_filePath);
    // bool hasExisted = await savedDir.exists();
    // if (!hasExisted) {
    //   savedDir.create();
    // }
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  _imgFromGallery() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendMessage(String message) async {
    //   try {
    //     var data = {
    //       USER_ID: CUR_USERID,
    //       TICKET_ID: widget.id,
    //       USER_TYPE: USER,
    //       MESSAGE: msg,
    //     };

    //     Response response = await post(sendMsgApi, body: data, headers: headers)
    //         .timeout(Duration(seconds: timeOut));
    //     print("res***${response.body.toString()}");
    //     if (response.statusCode == 200) {
    //       var getdata = json.decode(response.body);

    //       bool error = getdata["error"];
    //       String msg = getdata["message"];

    //       if (mounted) setState(() {});

    //       // setSnackbar(msg);
    //     }
    //   } on TimeoutException catch (_) {
    //     //  setSnackbar(getTranslated(context, 'somethingMSg'));
    //   }
    // }
 setState(() {
                      msgController.text = "";
                  });
    var request = http.MultipartRequest("POST", sendMsgApi);
    request.headers.addAll(headers);
    request.fields[USER_ID] = CUR_USERID;
    request.fields[TICKET_ID] = widget.id;
    request.fields[USER_TYPE] = USER;
    request.fields[MESSAGE] = message;

    if (files != null) {
      for (int i = 0; i < files.length; i++) {
        print("res****uploading**${files[i].path}");
        var pic = await http.MultipartFile.fromPath(ATTACH, files[i].path);
        request.files.add(pic);
      }
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var getdata = json.decode(responseString);
    bool error = getdata["error"];
    String msg = getdata['message'];
    // if (!error) {
    //   setSnackbar(msg);
    // } else {
    //   setSnackbar(msg);
    //   initialRate = 0;
    // }
    print("res***${responseString.toString()}");

    files.clear();
    if (mounted)
      setState(() {
        //  _isProgress = false;
      });
  }

  Future<void> getMsg() async {
    try {
      var data = {
        // USER_ID: CUR_USERID,
        TICKET_ID: widget.id,
        // USER_TYPE: USER,
        // MESSAGE: msg,
      };

      Response response = await post(getMsgApi, body: data, headers: headers)
          .timeout(Duration(seconds: timeOut));
      print("res***${response.body.toString()}");
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String msg = getdata["message"];

        if (!error) {
          var data = getdata["data"];
          chatList =
              (data as List).map((data) => new Model.fromChat(data)).toList();
        }
        // setSnackbar(msg);
        if (mounted) setState(() {});
      }
    } on TimeoutException catch (_) {
      //  setSnackbar(getTranslated(context, 'somethingMSg'));
    }
  }

  msgRow() {
    return 
    widget.status=="2"?
    Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
        height: 60,
        width: double.infinity,
        color: colors.white,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _imgFromGallery();
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.add,
                  color: colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: TextField(
                controller: msgController,
                decoration: InputDecoration(
                    hintText: "Write message...",
                    hintStyle: TextStyle(color: colors.lightBlack),
                    border: InputBorder.none),
              ),
            ),
            SizedBox(
              width: 15,
            ),
            FloatingActionButton(
              onPressed: () {
                if (msgController.text.trim().length > 0 || files.length > 0) {
                 
                  sendMessage(msgController.text.trim());
                }
              },
              child: Icon(
                Icons.send,
                color: colors.white,
                size: 18,
              ),
              backgroundColor: colors.primary,
              elevation: 0,
            ),
          ],
        ),
      ),
    ):Container();
  }

  Widget attachItem(List<String> attach, int index, Model message) {
    String file = attach[index];

    print("file****$file");
    return file.isEmpty
        ? Container()
        : Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              Card(
                //margin: EdgeInsets.only(right: message.sender_id == myid ? 10 : 50, left: message.sender_id == myid ? 50 : 10, bottom: 10),
                elevation: 0.0,
                color: message.uid == CUR_USERID
                    ? colors.fontColor.withOpacity(0.1)
                    : colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: message.uid == CUR_USERID
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      //_messages[index].issend ? Container() : Center(child: SizedBox(height:20,width: 20,child: new CircularProgressIndicator(backgroundColor: ColorsRes.secondgradientcolor,))),

                      GestureDetector(
                        onTap: () {
                          _requestDownload(file, message.id);
                        },
                        child: Container(
                            child: Image.network(
                          file,
                          width: 250,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                            // child: filetype == Constant.fileimage ? FadeInImage.assetNetwork(image: file, placeholder: "assets/images/splash_logo.png",width: 250,height: 150, fit: BoxFit.cover,) :
                            // filetype == Constant.filevideo ? Image.asset("assets/images/defaultvideo.png",width: 250,height: 150,fit: BoxFit.cover) :
                            // filetype == Constant.filedoc ? Image.asset("assets/images/defaultdoc.png",width: 250,height: 150,fit: BoxFit.cover) : Container()
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text((message.date),
                      style: TextStyle(color: colors.lightBlack, fontSize: 9)),
                ),
              ),
            ],
          );
  }
}
