import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:share_extend/share_extend.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.white70),
                      foregroundColor: WidgetStateProperty.all(Colors.black)),
                  onPressed: () {
                    ShareExtend.share("share text", "text",
                        sharePanelTitle: "share text title",
                        subject: "share text subject");
                  },
                  child: Text("share text"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.white70),
                      foregroundColor: WidgetStateProperty.all(Colors.black)),
                  onPressed: () async {
                    final res =
                        await _picker.pickVideo(source: ImageSource.gallery);
                    if (res?.path != null) {
                      ShareExtend.share(res?.path??"", "video");
                    }
                  },
                  child: Text("share video"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.white70),
                      foregroundColor: WidgetStateProperty.all(Colors.black)),
                  onPressed: () {
                    _shareStorageFile();
                  },
                  child: Text("share file"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> _writeByteToImageFile(ByteData byteData) async {
    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if(dir !=null){
      File imageFile = new File(
          "${dir.path}/flutter/${DateTime.now().millisecondsSinceEpoch}.png");
      imageFile.createSync(recursive: true);
      imageFile.writeAsBytesSync(byteData.buffer.asUint8List(0));
      return imageFile.path;
    }else{
      return "";
    }
  }

  ///share the storage file
  _shareStorageFile() async {
    Directory? dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if(dir==null){
      return "";
    }
    File testFile = File("${dir.path}/flutter/test.txt");
    if (!await testFile.exists()) {
      await testFile.create(recursive: true);
      testFile.writeAsStringSync("test for share documents file");
    }
    ShareExtend.share(testFile.path, "file");
  }
}
