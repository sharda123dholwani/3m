

import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'predict_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mmm_sheeting_app_ios_flutter/screens/dashboard_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/main.dart';
import 'package:mmm_sheeting_app_ios_flutter/print_text.dart';

class MyCameraScreen extends StatefulWidget {

  const MyCameraScreen({Key? key}) : super(key: key);

  @override
  State<MyCameraScreen> createState() => _MyCameraScreenState();
}

class _MyCameraScreenState extends State<MyCameraScreen> with WidgetsBindingObserver {
  CameraController? controller;


  File? _imageFile, croppedFile;
  String? imagePath;
  File? _videoFile;

  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isRearCameraSelected = true;
  bool flashMode = false;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode=FlashMode.off;

  List<File> allFileList = [];

  ResolutionPreset currentResolutionPreset = ResolutionPreset.ultraHigh;

  @override
  void initState() {
    // Hide the status bar in Android
    // SystemChrome.setEnabledSystemUIOverlays([]);
    getPermissionStatus();
    setState(() {
      _currentFlashMode=FlashMode.off;
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



captureImage() async {

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

    double cropX=((decodedImage.width/2)-256)  ;
    double cropY=((decodedImage.height/2)-256)  ;
if (Platform.isAndroid){
  if(decodedImage.width>decodedImage.height){
    croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropX.round(), cropY.round(), 512, 512);
  }

  if(decodedImage.width<=decodedImage.height){
    croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
  }
}

   else if (Platform.isIOS){
      if(decodedImage.width>decodedImage.height){
        croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
      }

      if(decodedImage.width<=decodedImage.height){
        croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropX.round(), cropY.round(), 512, 512);
      }
    }
    goToAnalyseScreen();




   // if(await isBlurry(croppedFile)){
   //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
   //     content: Text("Please click a clear picture"),
   //   ));
   //
   // }
   //
   // else{
   //  goToAnalyseScreen();
   //   }
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




  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: txtColor,
            body:_isCameraInitialized
                ? Container(
              height: 926.h,
              width: 428.w,
              child: Stack(
                children: [
                  AspectRatio(
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
                  ),

                  SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: SvgPicture.asset(
                      "assets/icons/camera_overlay.svg",
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 615.h,left: 61.w,right: 61.w),
                    width: 306.w,
                    height: 67.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child:  Center(
                      child: Text("Keep the product within 10 cms distance from the camera.",textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 12.sp,
                      ),),
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
                    margin: EdgeInsets.only(top: 700.h,left: 68.w,right: 68.w),
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
                    child: Container(
                      height: 50.h,
                      width: 328.w,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        onPressed:  () {
                          captureImage();
                        },
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
}






