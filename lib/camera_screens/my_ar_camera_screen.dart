import 'dart:ui' as ui;

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mmm_sheeting_app_ios_flutter/camera_screens/predict_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../Screens/dashboard_screen.dart';
import '../main.dart';
import 'package:image/image.dart' as img;

import '../print_text.dart';

class MyARCameraScreen extends StatefulWidget {

  const MyARCameraScreen({Key? key}) : super(key: key);

  @override
  State<MyARCameraScreen> createState() => _MyCameraScreenState();
}

class _MyCameraScreenState extends State<MyARCameraScreen> with WidgetsBindingObserver {

  late ARKitController arkitController;
  vector.Vector3? lastPosition;
  vector.Vector3? cameraPosition;
  String distanceToShow="0.0 Cms";
  late Offset centerPoint;
  bool busy = false;
  bool isCaptureButtonActive=false;


  CameraController? controller;


  File? _imageFile, croppedFile;
  String? imagePath;
  File? _videoFile;

  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode=FlashMode.off;

  List<File> allFileList = [];
  bool flashMode = false;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;

  @override
  void initState() {
    // Hide the status bar in Android
    // SystemChrome.setEnabledSystemUIOverlays([]);
    getPermissionStatus();
    if(Platform.isAndroid){
      setState(() {
        isCaptureButtonActive=true;
      });
    }
    else if(Platform.isIOS){
      setState(() {
        isCaptureButtonActive=false;
      });
    }
    setState(() {
      _currentFlashMode=FlashMode.off;
      printLine("current flash  mode: $_currentFlashMode");
    });
    super.initState();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    await controller!.setFlashMode(
      _currentFlashMode!,
    );

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    else{

    }

    try {
      XFile file = await cameraController.takePicture();
      controller!.setFlashMode(_currentFlashMode!);

      return file;
    } on CameraException catch (e) {
      printLine('Error occurred while taking picture: $e');
      return null;
    }
  }




  getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      log('Camera Permission: GRANTED');
      setState(() {
        _isCameraPermissionGranted = true;
      });
      log(cameras.length.toString());
      // Set and initialize the new camera
      onNewCameraSelected(cameras[0]);
      // refreshAlreadyCapturedImages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Camera Permission: DENIED"),

      ));
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder:
            (context) =>
            const DashboardScreen()
        ),);
      log('Camera Permission: DENIED');
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      // _currentFlashMode = controller!.value.flashMode;
      _currentFlashMode=FlashMode.off;
    } on CameraException catch (e) {
      printLine('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  captureARImage() async {

    XFile? rawImage =
    await takePicture();
    File imageFile =
    File(rawImage!.path);

    int currentUnix = DateTime.now()
        .millisecondsSinceEpoch;

    final directory =
    await getApplicationDocumentsDirectory();

    String fileFormat = imageFile
        .path
        .split('.')
        .last;

    printLine(fileFormat);

    await imageFile.copy(
      '${directory.path}/$currentUnix.$fileFormat',
    );

    refreshAlreadyCapturedImages();


  }

  captureImage() async {
    printLine("Capture image");
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final ARImage = await arkitController.snapshot();
      int currentUnix = DateTime.now()
          .millisecondsSinceEpoch;

      final directory =
      await getApplicationDocumentsDirectory();
      File imageFile = await File('${directory.path}/$currentUnix.jpg').create();
      await imageFile.copy(
        '${directory.path}/$currentUnix.jpg',
      );
      imageFile.writeAsBytesSync(ARImage as List<int>);
      refreshAlreadyCapturedImages();
    }
    else if(Theme.of(context).platform == TargetPlatform.android){
      XFile? rawImage =
      await takePicture();
      File imageFile =
      File(rawImage!.path);

      int currentUnix = DateTime.now()
          .millisecondsSinceEpoch;

      final directory =
      await getApplicationDocumentsDirectory();

      String fileFormat = imageFile
          .path
          .split('.')
          .last;

      printLine(fileFormat);

      await imageFile.copy(
        '${directory.path}/$currentUnix.$fileFormat',
      );

      refreshAlreadyCapturedImages();
    }



  }
  Future<String> saveRotatedImage(img.Image rotatedImage, String fileName) async {
    // Encode image to bytes (e.g., PNG format)
    final Uint8List imageBytes = Uint8List.fromList(img.encodePng(rotatedImage));

    // Get directory to save the image
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Write bytes to file
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    return filePath;
  }

  Future<img.Image> convertUiImageToImage(ui.Image uiImage) async {
    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    final Uint8List uint8List = byteData!.buffer.asUint8List();
    final img.Image image = img.Image.fromBytes(



      format:img.Format.uint8, width:  uiImage.width, height:  uiImage.height, bytes:  byteData.buffer,
    );
    return image;
  }
  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    fileList.forEach((file) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    if (fileNames.isNotEmpty) {
      final recentFile =
      fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        // _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        imagePath= '${directory.path}/$recentFileName';
        _videoFile = null;
      }

      setState(() {
        _imageFile = File('${directory.path}/$recentFileName');
        imagePath= '${directory.path}/$recentFileName';
      });
    }

    printLine("Image Path $imagePath");
    printLine("Image File $_imageFile");

    var decodedImage = await decodeImageFromList(_imageFile!.readAsBytesSync());
    printLine(decodedImage.width);
    printLine(decodedImage.height);
    ImageProperties properties = await FlutterNativeImage.getImageProperties(imagePath!);
    printLine("proeperties: ${properties.orientation}");
    printLine("width my ar camera screen:${properties.width}");
    printLine("height:${properties.height}");


   //  final image = await convertUiImageToImage(decodedImage);
   //  printLine("image: ${image.width}");
   // var rotated = img.copyRotate(image, angle: 90);
   //
   //  printLine("rotated: ${rotated}");
   //  final rotatedImagePath = await saveRotatedImage(rotated, 'rotated_${DateTime.now().millisecondsSinceEpoch}.png');
   //
   //  printLine("Rotated Image Path: $rotatedImagePath");
    double cropX=((properties.width!/2)-256);
    double cropY=((properties.height!/2)-256);
    printLine("crop X: ${cropX.round()}");
    printLine("crop Y: ${cropY.round()}");

    if (Platform.isAndroid){


      // if(decodedImage.width>decodedImage.height){
      //   printLine("width greater than height");
        croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropX.round(), cropY.round(), 512, 512);
        printLine("croppedFile: ${croppedFile?.path}");
        printLine(croppedFile?.uri);
      // }
      // else if(decodedImage.width<=decodedImage.height){
      //   printLine("width less than or equal to height");
      //   croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
      //   printLine("croppedFile: ${croppedFile?.path}");
      //   printLine(croppedFile?.uri);
      // }
    }

    else if (Platform.isIOS){
      if(decodedImage.width>decodedImage.height){
        croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
      }

      if(decodedImage.width<=decodedImage.height){
        croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
      }
    }
    goToAnalyseScreen();
  }


  goToAnalyseScreen() {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PredictScreen(
              croppedFile:croppedFile!,
              imageFile: _imageFile!,
              imagePath: imagePath!,
              fileList: allFileList, flashModeStatus: flashMode,
            ),
      ),
    );
  }

  goToDashboardScreen(){
    Navigator.pop(context,true);
  }


  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onARKitViewCreated(ARKitController arkitController,BuildContext context) async  {


    this.arkitController = arkitController;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      centerPoint = renderBox.size.center(Offset.zero);
    });


    final x = centerPoint.dx / renderBox.size.width ;
    final y = centerPoint.dy / renderBox.size.height ;
    var objPoint;
    this.arkitController.updateAtTime = (time) async {
      var position = await this.arkitController.cameraPosition();
      printLine("Initial Camera Position: $position");


      if (busy == false) {
        busy = true;
        this.arkitController.performHitTest(x: x, y: y).then((results) {
          printLine("Results: $results $x $y ");
          if (results.isNotEmpty) {
            objPoint = results.firstWhere(
                  (o) => o.type == ARKitHitTestResultType.featurePoint,
            );
            printLine("object point check: $objPoint");
            // if (objPoint == null) {
            //   return;
            // }
            // else
            if(objPoint!=null && position!=null){
              getObjectDistance(objPoint,position);
            }

          }
          busy = false;
        });

      }
    };

  }

  void  getObjectDistance(ARKitTestResult point, vector.Vector3 positionCamera) {
    printLine("Inside get Distance");

    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final distance =_calculateDistanceBetweenObjectAndCamera(position, positionCamera);

    double dist=double.tryParse(distance.split(' ')[0])?? 0.0;

    if (dist <= 15.0){
      isCaptureButtonActive=true;
    }
    else {
      isCaptureButtonActive = false;
    }

    printLine("Distance of object from camera hit test: $distance");
    // _drawText(distance, pointToShowDistance);
    // _drawPoint(pointToShowDistance);
    setState(() {
      distanceToShow=distance;
      isCaptureButtonActive;
    });


  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  String _calculateDistanceBetweenObjectAndCamera(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: txtColor,
          body:_isCameraInitialized
              ? SizedBox(
            height: 926.h,
            width: 428.w,
            child: Stack(
              children: [
                _buildARWidget(context),
                SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: SvgPicture.asset(
                    "assets/icons/camera_overlay.svg",
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 600.h,left: 68.w,right: 68.w),
                  child: Column(
                    children: [
                      Container(
                        width: 306.w,
                        height: 67.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child:  Center(
                          child: Text("Keep the product within 15 cms distance from the camera.",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 12.sp,
                          ),),
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 10.h),
                        width: 292.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child:  Center(
                          child: Text("Place your product in the marked area.",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 12.sp,
                          ),),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 90.h,left: 194.w,right: 21.w),
                  width: 213.w,
                  height: 33.h,
                  decoration: BoxDecoration(
                    color: titleTxtColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child:  Center(
                    child: Text("Keep Flash ON at all times",textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 12.sp,
                    ),),
                  ),
                ),



                Container(
                  margin: EdgeInsets.only(top: 45.h,left: 34.w),
                  height: 20.h,
                  width: 20.w,
                  child: GestureDetector(
                    onTap: ()=> goToDashboardScreen(),
                    child: SvgPicture.asset(
                      "assets/icons/back.svg",
                      color: ellipseDashboard,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 40.h,right: 40.w,left: 347.w),
                  width: 40.w,
                  height: 40.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          if(_currentFlashMode==FlashMode.off){
                            setState(() {
                              _currentFlashMode = FlashMode.always;
                            });
                            await controller!.setFlashMode(
                              FlashMode.always,
                            );
                            setState(() {
                              flashMode = true;
                            });
                          }

                          else if(_currentFlashMode==FlashMode.always){
                            setState(() {
                              _currentFlashMode = FlashMode.off;
                            });
                            await controller!.setFlashMode(
                              FlashMode.off,
                            );
                            setState(() {
                              flashMode = false;
                            });
                          }

                        },
                        child:
                        _currentFlashMode == FlashMode.off?
                        const Icon(
                          Icons.flash_off,
                          color:Colors.white,
                        ) :
                        const Icon(
                          Icons.flash_on,
                          color:Colors.amber,
                        )

                        ,
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 750.h,left: 61.w,right: 61.w),
                  width: 328.w,
                  height: 50.h,
                  child: SizedBox(
                    height: 50.h,
                    width: 328.w,
                    child: TextButton(
                      style: isCaptureButtonActive ?
                      ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      ):ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(secondaryColor),
                        foregroundColor: MaterialStateProperty.all<Color>(feedbackBg),
                      ),
                      onPressed: isCaptureButtonActive ?   () {
                        captureImage();
                      } : null,
                      child: const Text('Capture Image'),
                    ),
                  ),
                ),

              ],
            ),



          )
          // Expanded(
          //   child: Container(
          //     alignment: Alignment.center,
          //     margin: EdgeInsets.only(bottom: 50.h),
          //     width: 328.w,
          //     height: 50.h,
          //     child: Container(
          //       height: 50.h,
          //       width: 328.w,
          //       child: TextButton(
          //         style: ButtonStyle(
          //           backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
          //           foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          //         ),
          //         onPressed:  () {
          //           captureImage();
          //         },
          //         child: const Text('Capture Image'),
          //       ),
          //     ),
          //   ),
          // ),
              : const Center(
            child: Text(
              'LOADING',
              style: TextStyle(color: Colors.white),
            ),
          ),


        ));
  }

  Widget _buildARWidget(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return Container(
        child: Builder(
            builder: (context) {
              return ARKitSceneView(
                enableTapRecognizer: true,
                onARKitViewCreated : (controller) => onARKitViewCreated(controller, context),
              );
            }
        ),
      );
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      return AspectRatio(
            aspectRatio: 1 / controller!.value.aspectRatio,
            child:CameraPreview(
              controller!,
              child: LayoutBuilder(builder:
                  (BuildContext context,
                  BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) =>
                      onViewFinderTap(details, constraints),
                );
              }),
            ),
          );
    } else {
      return const Text('AR is not supported on this platform');
    }
  }
}






