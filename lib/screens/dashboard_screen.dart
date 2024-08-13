import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mmm_sheeting_app_ios_flutter/api_constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/camera_screens/my_ar_camera_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/camera_screens/my_camera_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/components/drawer_item.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/models/feedback.dart';
import 'package:mmm_sheeting_app_ios_flutter/screens/about.dart';
import 'package:mmm_sheeting_app_ios_flutter/screens/history.dart';
import 'phone_screen.dart';
import 'privacy.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';
import '../api_service.dart';
import '../camera_screens/predict_screen.dart';
import '../database_helper.dart';
import '../print_text.dart';

class DashboardScreen extends StatefulWidget {
   const DashboardScreen({Key? key}) : super(key: key);
   @override
   State<DashboardScreen> createState() => _DashboardScreenState();

}

class _DashboardScreenState extends State<DashboardScreen>{

  File? _imageFile,croppedFile;
  String? imagePath;
  List<FeedbackModel> listFeedback=[];
  List<FeedbackModel> listFeedbackStatus2=[];
  List<File> allFileList = [];
  late StreamSubscription subscription;
  bool isConnected=false;

  int? feedbackStatus;

  @override
  void initState() {
    if (kDebugMode) {
      printLine("init fired ");
    }
    loadDB();
    deleteImageData();
    getConnectivity();
    super.initState();
  }

  deleteImageData () async{

    final db = DatabaseHelper();
    await db.init();
    var todayDate = DateTime.now();

    for(var i = 0; i < listFeedbackStatus2.length; i++){

      var parsedDate = DateTime.parse(listFeedbackStatus2[i].timeStamp);
      var differenceDays=todayDate.difference(parsedDate).inDays;
      if (kDebugMode) {
        print("Difference ${todayDate.difference(parsedDate).inDays}");
      }

      if(differenceDays>7){

        db.updateStatusTo0(listFeedbackStatus2[i]);

        try {
          final file = await File(listFeedbackStatus2[i].imagePath);
          await file.delete();
        } catch (e) {
          return 0;
        }

      }

    }


  }


  loadDB() async{

  listFeedback= await feedbackListStatus1();
  listFeedbackStatus2= await feedbackListStatus2();

  Future.delayed(const Duration(milliseconds: 500), () {
    checkNetwork();
  });

  deleteImageData();
  }

  checkNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();// User defined class
    if (kDebugMode) {
      printLine(connectivityResult);
    }
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (kDebugMode) {
        printLine("Inside Connectivity");
        printLine(listFeedback.length);
      }

      for(var i = 0; i < listFeedback.length; i++){
        feedbackStatus = await ApiService().sendFeedback(listFeedback[i]);
      }

    }
  }


  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
              isConnected = await InternetConnectionChecker().hasConnection;
              if(isConnected){
                if (kDebugMode) {
                  printLine(listFeedback.length);
                }
                for(var i = 0; i < listFeedback.length; i++){
                 feedbackStatus = await ApiService().sendFeedback(listFeedback[i]);

                }
              }
              else {
                if (kDebugMode) {
                  printLine("Disconnected");
                }
              }
        },
      );

  Future<List<FeedbackModel>> feedbackListStatus1() async {
    // Get a reference to the database.
    final db = DatabaseHelper();//await
    await db.init();

    final List<Map<String, dynamic>> maps = await db.queryAllRowsStatus1();
    List<FeedbackModel> feedbackRowsStatus1 =List.generate(maps.length, (i) {
      return FeedbackModel(
        maps[i]['_id'],
        maps[i]['image_path'],
        maps[i]['prediction_type'],
        maps[i]['prediction_color'],
        maps[i]['feedback'],
        maps[i]['correct_ans_type'],
        maps[i]['correct_ans_color'],
        maps[i]['flash'],
        maps[i]['image_name'],
        maps[i]['time_stamp'],
        maps[i]['status'],
      );
    }
    );
    return feedbackRowsStatus1;

  }
  Future<List<FeedbackModel>> feedbackListStatus2() async {
    // Get a reference to the database.
    final db = DatabaseHelper();
    await db.init();

    final List<Map<String, dynamic>> maps = await db.queryAllRowsStatus2();
    List<FeedbackModel> feedbackRowsStatus2 =List.generate(maps.length, (i) {
      return FeedbackModel(
        maps[i]['_id'],
        maps[i]['image_path'],
        maps[i]['prediction_type'],
        maps[i]['prediction_color'],
        maps[i]['feedback'],
        maps[i]['correct_ans_type'],
        maps[i]['correct_ans_color'],
        maps[i]['flash'],
        maps[i]['image_name'],
        maps[i]['time_stamp'],
        maps[i]['status'],
      );
    }
    );
    return feedbackRowsStatus2;

  }


  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      _imageFile=File(pickedFile.path);
       imagePath=pickedFile.path;
      croppedFile= (await(_cropImage(pickedFile)));
      // var decodedImage = await decodeImageFromList(_imageFile!.readAsBytesSync());
      // printLine(decodedImage.width);
      // printLine(decodedImage.height);
      //
      // double cropX=((decodedImage.width/2)-256)  ;
      // double cropY=((decodedImage.height/2)-256)  ;
      //
      // if(decodedImage.width>decodedImage.height){
      //   croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropX.round(), cropY.round(), 512, 512);
      // }
      //
      // if(decodedImage.width<=decodedImage.height){
      //   croppedFile = await FlutterNativeImage.cropImage(_imageFile!.path, cropY.round(), cropX.round(), 512, 512);
      // }
      if (croppedFile != null){goToAnalyseScreen();}
      else {
        return;
      }
      // setState(() {
      //   imageFile = File(pickedFile.path);
      // });
    }
  }

  Future<File?> _cropImage(PickedFile pickedFile) async {
    File? cropFile;
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      maxHeight: 512,
      maxWidth: 512,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
          rectHeight: 512.h,
          rectWidth: 512.w,
          minimumAspectRatio: 1
        ),
        WebUiSettings(
          context: context,
          presentStyle: CropperPresentStyle.dialog,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
          const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        cropFile = File(croppedFile.path);
      });
    }

    return cropFile;
    }



  goToAnalyseScreen() {

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PredictScreen(
              croppedFile: croppedFile!,
              imageFile: _imageFile!,
              imagePath: imagePath!,
              fileList: allFileList!, flashModeStatus: false,
            ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dashboardBgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          iconTheme: const IconThemeData(color: txtColor),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              SizedBox(width: 127.w,),
              Image.asset(
                'assets/images/mmm_logo.png',
                fit: BoxFit.fill,
                width: 60.w,
                height: 30.h,
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 30.h,
              ),
              height: 60.h,
              width: 400.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap:(){
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(

                        width: 59.w,
                        height: 61.h,
                        child: const Icon(Icons.arrow_back)),
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(color: txtColor, fontSize: 16.sp),
                  )
                ],
              ),
            ),
            // GestureDetector(
            //   onTap: (){
            //     Navigator.of(context).pop();
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) =>  HistoryScreen())
            //     );
            //   } ,
            //   child: DrawerItem(
            //     title: "Scanning History",
            //     icon: Icons.history,
            //     press: () {
            //     },
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen())
                );
              },
              child: DrawerItem(
                title: "About 3M",
                icon: Icons.info_outline,
                press: () {
                },
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pop();
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyScreen())
                );
              },
              child: DrawerItem(

              title: "Privacy Policy",
                icon: Icons.privacy_tip_outlined,
                press: () {
                  Navigator.pop(context);
                },
              ),
            ),
            GestureDetector(
              onTap: (){
                LocalStorage().clearStorage();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const PhoneScreen()),
                      (Route<dynamic> route) => false,
                );

              },
              child: DrawerItem(
                title: "Log Out",
                icon: Icons.logout,
                press: () {

                },
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: 428.w,
        padding: const EdgeInsets.all(0.0),
        child: Column(children: [
          Stack(
            children: [
              SizedBox(
                height: 290.h,
                width: 428.w,
                child: Image.asset("assets/images/mmm_bg.png",fit: BoxFit.cover),
              ),
              Container(
                margin: EdgeInsets.only(left: 33.w, top: 148.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Validate your",
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Text(
                      "3M Reflective Sheet products",
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                    Text(
                      "in 2 Simple Steps",
                      style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30.h,
            width: 428,
          ),
          Container(
            margin: EdgeInsets.only(left: 33.w, right: 33.w),
            child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Scan the product',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold, color: txtColor),
                  ),
                  TextSpan(
                    text: ', and get details to verify authenticity of the sheet.',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal,
                        color: txtColor),
                  )
                ])),
          ),
          SizedBox(
            height: 25.h,
            width: 428,
          ),
          Container(
            margin: EdgeInsets.only(left: 35.w, right: 35.w),
            width: 370.w,
            height: 127.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Container(
              alignment: AlignmentDirectional.topStart,
              padding: EdgeInsets.all(11.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 11.w),
                  Container(
                    margin: EdgeInsets.only(top: 11.h),
                    child: Text(
                      "01",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: txtColor),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: 40.w,
                        child: SvgPicture.asset(
                          "assets/icons/ellipse.svg",
                          color: ellipseDashboard,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: Image.asset("assets/images/pt_one.png"),
                      ),
                    ],
                  ),
                  SizedBox(width: 15.w),
                  Container(
                    margin: EdgeInsets.only(top: 11.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Add image of the sheet",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: txtColor),
                        ),
                        SizedBox(height: 20.h),
                        RichText(
                          overflow: TextOverflow.clip,
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Scan',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: txtColor),
                              ),
                              TextSpan(
                                text: ' using the device camera or ',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: txtColor),
                              )
                            ])),
                        RichText(
                            text:  TextSpan(children: [
                              TextSpan(
                                text: 'Upload',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: txtColor),
                              ),
                              TextSpan(
                                text: ' from gallery',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: txtColor),
                              )
                            ])),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
            width: 428,
          ),
          Container(
            margin: EdgeInsets.only(left: 33.w, right: 33.w),
            width: 362.w,
            height: 150.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Container(
              alignment: AlignmentDirectional.topStart,
              padding: EdgeInsets.all(11.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 11.w),
                  Container(
                    margin: EdgeInsets.only(top: 11.h),
                    child: Text(
                      "02",
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: txtColor),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: 40.w,
                        child: SvgPicture.asset(
                          "assets/icons/ellipse.svg",
                          color: ellipseDashboard,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: Image.asset("assets/images/pt_two.png"),
                      ),
                    ],
                  ),
                  SizedBox(width: 15.w),
                  Container(
                    margin: EdgeInsets.only(top: 11.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "It's done!",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: txtColor),
                        ),
                        SizedBox(height: 20.h),
                        RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Get details about the sheet.',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: txtColor),
                              )
                            ])),
                        SizedBox(height: 6.h),
                        RichText(
                            text:  TextSpan(children: [
                              TextSpan(
                                text: 'Please leave your feedback',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.normal,
                                    color: txtColor),
                              )
                            ])),
                        RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'to verify the details.',
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                    color: txtColor),
                              )
                            ])),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30.h,
            width: 428,
          ),
          Container(
            margin: EdgeInsets.only(left: 33.w, right: 33.w),
            width: 362.w,
            height: 50.h,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () =>
              {
                showModalBottomSheet(
                    isDismissible: true,
                    enableDrag: false,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8.w),),),
                    context: context,
                    builder: (context) {
                      return
                        SizedBox(
                          height: 220.h,
                          child: Column(
                              children:[
                                SizedBox(height: 30.h,),
                                Text("Add image from",style: TextStyle(fontSize: 16.sp,color: txtColor),),
                                SizedBox(height: 30.h,),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const MyARCameraScreen())
                                          );
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.zero,
                                                height: 54.h,
                                                width: 54.w,
                                                child: SvgPicture.asset(
                                                  "assets/icons/ellipse_red.svg",
                                                  color: primaryColor,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.zero,
                                                height: 27.h,
                                                width: 27.w,
                                                child: const Icon(Icons.camera_alt_outlined,color: primaryColor,),
                                              ),
                                            ],
                                          ),),
                                        Text("Camera",style: TextStyle(fontSize: 14.sp,color: txtColor,fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _getFromGallery();
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.zero,
                                                height: 54.h,
                                                width: 54.w,
                                                child: SvgPicture.asset(
                                                  "assets/icons/ellipse_red.svg",
                                                  color: primaryColor,
                                                  fit: BoxFit.contain,
                                                ),

                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.zero,
                                                height: 27.h,
                                                width: 27.w,
                                                child: const Icon(Icons.folder_copy_outlined,color: primaryColor,),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text("Gallery",style: TextStyle(fontSize: 14.sp,color: txtColor,fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                  ],)
                              ]
                          ),
                        );
                    })
              },
              child: const Text('Get Started!'),
            ),
          ),
        ]),
      ),
    );
  }
}
