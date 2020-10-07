import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Tensorflow extends StatefulWidget {
  @override
  _TensorflowState createState() => _TensorflowState();
}

class _TensorflowState extends State<Tensorflow> {
  List _outputs;
  File _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  pickImageg() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Pokédex Tensorflow Lite",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.red[400],
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.red[400],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _loading
                  ? Container(
                      height: 300,
                      width: 300,
                      child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/International_Pok%C3%A9mon_logo.svg/269px-International_Pok%C3%A9mon_logo.svg.png'),
                    )
                  : Container(
                      margin: EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _image == null
                              ? Container()
                              : SafeArea(
                                  child: Image.file(
                                  _image,
                                  height: 500,
                                  width: MediaQuery.of(context).size.width,
                                )),
                          SizedBox(
                            height: 20,
                          ),
                          _image == null
                              ? Container()
                              : _outputs != null
                                  ? Text(
                                      _outputs[0]["label"],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30),
                                    )
                                  : Container(child: Text(""))
                        ],
                      ),
                    ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    tooltip: 'Camera',
                    onPressed: pickImage,
                    child: Icon(
                      Icons.add_a_photo,
                      size: 20,
                      color: Colors.red,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  FloatingActionButton(
                    tooltip: 'Pick Image from gallery',
                    onPressed: pickImageg,
                    child: Icon(
                      Icons.file_upload,
                      size: 20,
                      color: Colors.red,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                    tooltip: 'reset',
                    child: Icon(
                      Icons.restore,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                    onPressed: () {
                      setState(() {
                        _loading = true;
                      });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
