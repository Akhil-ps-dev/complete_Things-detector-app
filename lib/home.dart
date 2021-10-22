//@dart=2.9
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_dection/main.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = "";
  CameraImage imgCamera;
  CameraController cameraController;

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt");
  }

  intiCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
//scannedresults
        numResults: 2,
//scannedresults
        threshold: 0.1,
        asynch: true,
      );

      result = "";
      recognitions.forEach((response) {
        result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.blueAccent, Colors.blueGrey]),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        height: 320,
                        width: 360,
                        color: Colors.black,
                      ),
                    ),
                    Center(
                        child: TextButton(
                      onPressed: () {
                        intiCamera();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 35),
                        height: 280,
                        width: 360,
                        child: imgCamera == null
                            ? Container(
                                height: 270,
                                width: 340,
                                child: const Icon(Icons.photo_camera_front,
                                    color: Colors.white, size: 40),
                              )
                            : AspectRatio(
                                aspectRatio: cameraController.value.aspectRatio,
                                child: CameraPreview(cameraController),
                              ),
                      ),
                    )),
                  ],
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(result,
                          style: const TextStyle(
                              backgroundColor: Colors.black87,
                              fontSize: 30.0,
                              color: Colors.white),
                          textAlign: TextAlign.center),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
