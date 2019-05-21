import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';


class CameraService extends StatefulWidget {

  CameraService();

  @override

  _CameraServiceState createState() => _CameraServiceState();
}


class _CameraServiceState extends State<CameraService> {

  List<CameraDescription> cameras;
  CameraController controller;

  String imagePath;

  void initState() {
    super.initState();

    getCameras();
  }


  Future<void> getCameras() async {

    try {
      cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      print (e);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (controller == null ) {
      return Container();
    }

    if (!controller.value.isInitialized ) {
      return Container();
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: _cameraPreviewWidget(),
            ),
          ),
          _captureControlRowWidget(),
        ],
      );

    }
  }


  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        "Tap a camera",
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }
  
  
  Widget _captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null &&
          controller.value.isInitialized &&
          !controller.value.isRecordingVideo
          ? onTakePictureButtonPressed
          : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam,
          color: Colors.blue,
          ),
          onPressed: controller != null &&
          controller.value.isInitialized &&
            !controller.value.isRecordingVideo
            ? onVideoRecordButtonPressed
              : null,
        )
      ],
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      print('takePictures $filePath');
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
      }
    });
  }

  void onVideoRecordButtonPressed() {

  }


  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    /// ToDo takePicture for iOS
    if (!Platform.isAndroid) {
      return null;
    }

    //final Directory extDir = await getApplicationDocumentsDirectory();
    final Directory extDir = await getExternalStorageDirectory();

    final String dirPath = '${extDir.path}/TourPictures/';
    await Directory(dirPath).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$dirPath/${currentTime}.jpg';

    print('filePath: $filePath');
    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

    void _showCameraException(CameraException e) {
      //logError(e.code, e.description);
      print(e.code + e.description);
    }

}

