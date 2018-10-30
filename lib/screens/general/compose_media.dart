import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';

class MediaSubmission extends StatefulWidget {
  final String type;

  const MediaSubmission({Key key, this.type = "image"}) : super(key: key);

  @override
  _MediaSubmissionState createState() => _MediaSubmissionState();
}

class _MediaSubmissionState extends State<MediaSubmission> {
  File _image;

  Future getImage(String source) async {
//    switch (source) {
//      case "gallery":
//        _image = await ImagePicker.pickImage(source: ImageSource.gallery);
//        break;
//      case "camera":
//        _image = await ImagePicker.pickImage(source: ImageSource.camera);
//        break;
//    }

    setState(() {});
  }

  Widget buildOption(IconData icon, String label, Function onTap) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            child: Icon(icon),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(label.toUpperCase()),
        )
      ],
    );
  }

  Widget buildGrid() {
    return GridView(
      gridDelegate:
          SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 4.0),
      children: <Widget>[
        GridTile(
            child:
                buildOption(Icons.camera, "Camera", () => getImage("camera"))),
        GridTile(
            child: buildOption(
                Icons.photo_library, "Library", () => getImage("gallery"))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? buildGrid()
        : new Center(
            child: _image == null
                ? new Text('No image selected.')
                : new Image.file(_image),
          );
  }
}
