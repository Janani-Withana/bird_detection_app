import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:path_provider/path_provider.dart';
import 'tflite_helper.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  final TFLiteHelper _tfliteHelper = TFLiteHelper();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeNotifications();
    _tfliteHelper.loadModel();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initializeNotifications() async {
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _captureAndProcessImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final XFile file = await _cameraController!.takePicture();
    final String imagePath = file.path;

    var result = await _tfliteHelper.runInference(imagePath);
    
    if (result != null && result.isNotEmpty) {
      _showNotification("Bird Detected!");
    }
  }

  Future<void> _showNotification(String message) async {
    var androidDetails = AndroidNotificationDetails('channelId', 'Bird Detection');
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, "Alert", message, generalNotificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Bird Detection")),
      body: CameraPreview(_cameraController!),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: _captureAndProcessImage,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tfliteHelper.close();
    super.dispose();
  }
}
