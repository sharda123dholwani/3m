import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mmm_sheeting_app_ios_flutter/api_service.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/models/feedback.dart';
import 'package:mmm_sheeting_app_ios_flutter/print_text.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';
import 'package:pytorch_mobile/model.dart';
import 'package:pytorch_mobile/pytorch_mobile.dart';
import '../Screens/dashboard_screen.dart';
import '../api_constants.dart';
import '../database_helper.dart';
class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key,
    required this.croppedFile,
    required this.imageFile,
    required this.imagePath,
    required this.fileList, required this.flashModeStatus,}) : super(key: key);

  final File imageFile;
  final String imagePath;
  final File croppedFile;
  final List<File> fileList;
  final bool flashModeStatus;

  @override
  State<PredictScreen> createState() => _PredictScreenState();
}


class _PredictScreenState extends State<PredictScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Model? _imageModel;
  String dropdownValueType = AppConstants.listType.first;
  String dropdownValueColor = AppConstants.listColors.first;
  String dropdownValueFlash= AppConstants.listFlash.first;
  List<String>? _imagePrediction;
  String? predictionType,feedbackType;
  String? predictionColor,feedbackColor;
  String? actualPredictionType;
  String? actualPredictionColor;
  String? timestamp ; //22/12/2022 00:00:00
  String feedback="";
  String rightAns="";

  bool yesClicked= false;
  bool noClicked=  false;
  bool notSureClicked= false;
  final dbHelper = DatabaseHelper();

  int? returnStatus;
  bool isLoading=false;

  @override
  void initState()  {
    super.initState();
    initializeDb();
    loadModel();
  }

  Future<void> initializeDb() async{

    await dbHelper.init();
  }

//load your model
   loadModel() async {
    printLine("App Usage and Country :${LocalStorage().getAppUsage()}  ${LocalStorage().getCountry()}");
    String pathImageModel = "assets/models/best_scripted.pt";
    try {
      _imageModel = await PyTorchMobile.loadModel(pathImageModel);
    } on PlatformException {
      printLine("only supported for android and ios so far");
    }
    runImageModel();
    printLine("After model");
  }

  Future runImageModel() async {

    _imagePrediction = await _imageModel!.getImagePrediction(
      widget.croppedFile, 512, 512, "assets/labels/color_labels.csv");
      printLine(_imagePrediction);
      printLine(DateTime.now());
      await getPredictions();

    setState(() {
      _imagePrediction = _imagePrediction;
      predictionType;
      predictionColor;

    });
  }

  Future<void> getPredictions() async {
    String? appUsage=await LocalStorage().getAppUsage();
    String? country=await LocalStorage().getCountry();
    actualPredictionColor=_imagePrediction![0];
    actualPredictionType=_imagePrediction![1];
    if(appUsage=="Vehicle Markings")   {
      String type=_imagePrediction![1];
      String color=_imagePrediction![0];
      switch(country){
        case "India":
          switch(type){
            case "3M Type VIII":
              predictionType="3M 983 AIS Certified Tape";
              break;
            case "Invalid":
              predictionType="Invalid";
              break;
            case "Non 3M":
              predictionType="Non 3M Tape";
              break;
            default :
              predictionType="3M non AIS Certified Tape";
              break;

          }
          switch(color){
            case "White":
              predictionColor="White";
              break;
            case "Red":
              predictionColor="Red";
              break;
            case "Yellow":
              predictionColor="Yellow";
              break;
            default:
              predictionColor="NA";
              break;
          }
          break;

        case "Malaysia":
          switch(type){
            case "3M Type VIII":
              predictionType="3M MS828 certified";
              break;
            case "Invalid":
              predictionType="Invalid";
              break;
            case "Non 3M":
              predictionType="Non 3M";
              break;
            default :
              predictionType="3M non MS828 certified";
              break;

          }

          switch(color){
            case "White":
              predictionColor="White";
              break;
            case "Red":
              predictionColor="Red";
              break;
            case "Yellow":
              predictionColor="Yellow";
              break;
            default:
              predictionColor="NA";
              break;
          }
          break;

        default:
          predictionType=_imagePrediction![1];
          predictionColor=_imagePrediction![0];
          break;

      }

    }

    else if(appUsage=="Traffic Signs"){
      predictionType=_imagePrediction![1];
      predictionColor=_imagePrediction![0];
    }
  }
  void navigateToDashboard() async{
    setState(() {
      isLoading=true;
    });
    await _insertFeedback();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
          (Route<dynamic> route) => false,
    );

    setState(() {
      isLoading=false;
    });
  }

  Future<bool>? _onBackPressed(BuildContext context) {

    try{
      Navigator.pop(context,true);
    }
    catch(ex){
      return null;
    }

  }

  Future<void> _insertFeedback() async {

    String feedback ='';
    if(yesClicked) {
      feedback="Yes";
    } else if(noClicked) {
      feedback="No";
    }
    else if(notSureClicked){
      feedback="Not Sure";
    }

    else {
      feedback="Not Selected";
    }
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnImagePath: widget.imagePath,
      DatabaseHelper.columnPredictionType:actualPredictionType,
      DatabaseHelper.columnPredictionColor:actualPredictionColor,
      DatabaseHelper.columnTimeStamp: DateTime.now().toString(),
      DatabaseHelper.columnFeedback:feedback,
      DatabaseHelper.columnCorrectAnsType:noClicked?dropdownValueType:'None',
      DatabaseHelper.columnCorrectAnsColor:noClicked?dropdownValueColor:'None',
      DatabaseHelper.columnFlash:noClicked?dropdownValueFlash:'1',
      DatabaseHelper.columnImageName:"3M-${DateTime.now().millisecond}",

    };
    final id = await dbHelper. insertFeedback(row);
    printLine('inserted row id: $id');

    FeedbackModel feedbackModel =FeedbackModel((id), widget.imagePath, actualPredictionType!, actualPredictionColor!,
        feedback,  noClicked?dropdownValueColor:'None',noClicked?dropdownValueType:'None',
        noClicked?widget.flashModeStatus.toString():widget.flashModeStatus.toString(), "3M-${DateTime.now().millisecond}", DateTime.now().toString(), 1);
    printLine("feedback status: ${feedbackModel.status}");
    printLine("feedback id: ${feedbackModel.id}");
    printLine("feedback timestamp: ${feedbackModel.timeStamp}");
    printLine("feedback image path: ${feedbackModel.imagePath}");
    printLine("feedback feedback: ${feedbackModel.feedback}");
    printLine("feedback flash: ${feedbackModel.flash}");
    printLine("feedback correct ans type: ${feedbackModel.correctAnsType}");
    printLine("feedback correct answer color: ${feedbackModel.correctAnsColor}");
    printLine("feedback predict color: ${feedbackModel.predictionColor}");
    printLine("feedback predict type: ${feedbackModel.predictionType}");
    printLine("feedback image name: ${feedbackModel.imageName}");

    try {
      returnStatus= await ApiService().sendFeedback(feedbackModel);
    } on Exception catch (_){
      if(returnStatus==0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please check your internet connection'),
          ),
        );
      }

    }


  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      } ,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            child:
            Stack(
                children: [
                  SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Image.file(widget.imageFile,fit: BoxFit.contain,)),
                  Visibility(
                      visible: _imagePrediction != null,
                      child:Stack(
                        children: [
                          SingleChildScrollView(
                            child: Container(
                            padding: EdgeInsets.only(left: 35.w,right: 35.w,top: 35.w),
                            margin: EdgeInsets.only(top: 340.h),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 20.h,
                                      width: 20.w,
                                      child: GestureDetector(
                                        onTap: () async{

                                          setState(() {
                                            isLoading=true;
                                          });
                                          await _insertFeedback();
                                          Navigator.pop(context,true);

                                          setState(() {
                                            isLoading=false;
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/back.svg",
                                          color: primaryColor,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Image.asset(
                                        'assets/images/mmm_logo.png',
                                        fit: BoxFit.fill,
                                        width: 40.w,
                                        height: 20.h,
                                      ),
                                    ),
                                    Container(
                                      child: GestureDetector(
                                        onTap: () {
                                          navigateToDashboard();
                                        },
                                        child: Icon(
                                          Icons.home,
                                          color: primaryColor,
                                          size: 30.w,
                                        ),
                                      ),
                                    ),


                                  ],
                                ),

                                SizedBox(height: 30.h,),
                                Text("Sheet Details",style: TextStyle(color: titleTxtColor,fontSize: 14.sp),),
                                const Divider(
                                    color: Colors.black
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Sheet Type: ",style: TextStyle(color: titleTxtColor,fontSize: 14.sp),),
                                    SizedBox(width: 10.w,),
                                    Text('$predictionType',style: TextStyle(color: txtColor, fontWeight: FontWeight.bold, fontSize: 14.sp),),
                                  ],
                                ),
                                SizedBox(height: 10.h,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Color: ",style: TextStyle(color: titleTxtColor,fontSize: 14.sp),),
                                    SizedBox(width: 44.w,),
                                    Text('$predictionColor',style: TextStyle(color: txtColor, fontWeight: FontWeight.bold, fontSize: 14.sp),),
                                  ],
                                ),
                                SizedBox(height: 10.h,),
                                Text("This is an AI-powered application that provides indicative identification results based on input data. The identification results are generated through algorithms and machine learning, and there may be instances where the app provides incorrect or incomplete information. The identification results may not be 100% accurate and is not intended to be conclusive. For confirmation on the 3M products, please contact your 3M sales representative.3M does not guarantee the accuracy or reliability of the results. The use of this app and reliance on its results are at your own risk. 3M shall not be liable for the use of this app or the reliance on its results. By using this app, you acknowledge and agree to the terms of this disclaimer.",
                                  style: TextStyle(color: titleTxtColor,fontSize: 11.sp,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),),
                                SizedBox(height: 28.h,),
                                Text("Your Feedback",style: TextStyle(color: titleTxtColor,fontSize: 14.sp),),
                                const Divider(
                                    color: Colors.black
                                ),
                                SizedBox(
                                  width: 344.w,
                                  height: 120.h,
                                  child: Column(
                                    children: [
                                      Container(
                                      margin: EdgeInsets.only(left: 13.w),
                                      alignment: Alignment.center,
                                      height: 42.h,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                          color: feedbackBg,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5))
                                      ),
                                      child: Text("Did we predict it correctly?",style: TextStyle(color: Colors.white,fontSize: 16.sp),),
                                    ),
                                      Container(
                                        margin: EdgeInsets.only(left: 13.w),
                                        alignment: Alignment.center,
                                        height: 78.h,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                            color: Color(0Xfff1f1f1),
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5))
                                        ),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            style: !yesClicked? ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                            ): ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            ),
                                            onPressed: (){
                                              yesClicked= !yesClicked;
                                              notSureClicked=false;
                                              noClicked=false;
                                              setState(() {
                                                feedback= yesClicked ? 'Yes' : '';
                                                noClicked;
                                                yesClicked;
                                                notSureClicked;
                                              });

                                            },
                                            child: const Text('Yes'),
                                          ),
                                          TextButton(
                                            style: !notSureClicked? ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                            ): ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            ),
                                            onPressed: (){
                                              notSureClicked= !notSureClicked;
                                              yesClicked=false;
                                              noClicked=false;
                                              setState(() {
                                                feedback= notSureClicked ? 'Not Sure' : '';
                                                noClicked;
                                                yesClicked;
                                                notSureClicked;
                                              });
                                            },
                                            child: const Text('Not Sure'),
                                          ),
                                          TextButton(
                                            style: !noClicked ? ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                            ): ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            ),
                                            onPressed: (){
                                              noClicked= !noClicked;
                                              yesClicked=false;
                                              notSureClicked=false;
                                              setState(() {
                                                feedback= noClicked ? 'No' : '';
                                                noClicked;
                                                yesClicked;
                                                notSureClicked;
                                              });
                                            },
                                            child: const Text('No'),
                                          ),
                                        ],),

                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15.h,),
                                yesClicked||noClicked||notSureClicked ? const Center(child: Text("Thank You for your feedback!",style: TextStyle(color: txtColor,fontSize: 14),)):SizedBox(height: 20.h,),
                                SizedBox(height: 20.h,),
                                Visibility(
                                    visible: noClicked,
                                    child: SizedBox(
                                      width: 400.w,
                                      height: 60.h,
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            width: 90.w,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: dropdownValueType,
                                                icon: const Icon(Icons.arrow_downward),
                                                elevation: 16,
                                                style: const TextStyle(color: txtColor),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    dropdownValueType = value!;
                                                  });
                                                },
                                                items: AppConstants.listType.map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120.w,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: dropdownValueColor,
                                                icon: const Icon(Icons.arrow_downward),
                                                elevation: 16,
                                                style: const TextStyle(color: txtColor),
                                                // underline: Container(
                                                //   height: 2,
                                                //   color: txtColor,
                                                // ),
                                                onChanged: (String? value) {
                                                  // This is called when the user selects an item.
                                                  setState(() {
                                                    dropdownValueColor = value!;
                                                  });
                                                },
                                                items: AppConstants.listColors.map<DropdownMenuItem<String>>((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ),
                                      //     SizedBox(
                                      //       width: 120.w,
                                      //       child: DropdownButtonHideUnderline(
                                      //         child: DropdownButton<String>(
                                      //           isExpanded: true,
                                      //           value: dropdownValueFlash,
                                      //   icon: const Icon(Icons.arrow_downward),
                                      //   elevation: 16,
                                      //   style: const TextStyle(color: txtColor),
                                      //   onChanged: (String? value) {
                                      //         setState(() {
                                      //           dropdownValueFlash = value!;
                                      //           printLine("drop down value flash: $dropdownValueFlash");
                                      //         });
                                      //   },
                                      //   items: AppConstants.listFlash.map<DropdownMenuItem<String>>((String value) {
                                      //         return DropdownMenuItem<String>(
                                      //           value: value,
                                      //           child: Text(value),
                                      //         );
                                      //   }).toList(),
                                      // ),
                                      //       ),
                                      //     ),
                                        ],),
                                    )),


                              ],
                            ),
                                                ),
                          ),
                          isLoading ? const Center(
                            child: CircularProgressIndicator(
                              color: feedbackBg,
                            ),
                          ):const SizedBox()]
                      )
                  ),

                  Center(
                    child: Visibility(
                      visible: _imagePrediction == null,
                      child: Container(
                        alignment: Alignment.center,
                        width: 196.w,
                        height: 92.h,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.all(Radius.circular(8))
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white
                              ,strokeWidth: 2,),
                           Text("Analyzing Image"),

                        ],),

                      )
                    ),
                  )
                ]
            ),

          ),


        ),
      ),
    );
  }

}
// Text("$_imagePrediction",style: const TextStyle(color: Colors.red),),
