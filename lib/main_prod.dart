import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';
import 'env.dart';
import 'main.dart';
// void main() {
//   AppEnvironment.setupEnv(Environment.dev);
//   runApp(const MyApp());
// }

Future<void> main() async {
  AppEnvironment.setupEnv(Environment.prod);
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    if (kDebugMode) {
      print('Error in fetching the cameras: $e');
    }
  }
  LocalStorage();
  runApp(const MyApp());
}