import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mmm_sheeting_app_ios_flutter/Screens/dashboard_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/api_service.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../print_text.dart';

class OTPAuthenticationScreen extends StatefulWidget {
  const OTPAuthenticationScreen({Key? key}) : super(key: key);



  @override
  State<OTPAuthenticationScreen> createState() => _OTPAuthenticationScreenState();
}



class _OTPAuthenticationScreenState extends State<OTPAuthenticationScreen> {
  TextEditingController dig1Controller = TextEditingController();

  bool isAuth=false;
  String mobileNumber = "";

  void getMobileNumber() async {
    mobileNumber = (await LocalStorage().getMobileNo()) ?? "";
    setState(() {
      mobileNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    getMobileNumber();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      backgroundColor: bgColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 232.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w),
            width: 60.w,
            height: 52.h,

            child: SvgPicture.asset(
              "assets/icons/message.svg",
            ),
          ),
          SizedBox(height: 36.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w),
            child: Text("Enter Verification Code",
              style: TextStyle(fontSize:20.sp ,fontWeight: FontWeight.bold, color: txtColor),),
          ),
          SizedBox(height: 23.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w,right: 129.w),
            child: Text("Please enter OTP send to ",
              style: TextStyle(fontSize:16.sp ,fontWeight: FontWeight.normal, color: txtColor),),
          ),
          Container(
            margin: EdgeInsets.only(left: 61.w,right: 129.w),
            child: Text(" $mobileNumber",
              style: TextStyle(fontSize:16.sp ,fontWeight: FontWeight.normal, color: txtColor),),
          ),
          SizedBox(height: 30.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w,right: 61.w),
            child: PinCodeTextField(
              textStyle: const TextStyle(color: txtColor,),
              obscuringCharacter: '*',
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              keyboardType: TextInputType.number,
              obscureText: true,
              cursorColor: txtColor,
              appContext: context,
              length: 4,
              onChanged: (value) {
                if (kDebugMode) {
                  printLine(value);
                }
              },
              //
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(2.w),
                fieldHeight: 50.h,
                fieldWidth: 35.w,
                inactiveColor: otpBoxBorder,
                activeColor: otpBoxBg,
                selectedColor: otpBoxBorder,

              ),
              onCompleted: (value) async {
                int? otp = await LocalStorage().getTempOTP();
                printLine("otp_auth_screen: otp: $otp");
                if(value ==  otp.toString()){
                  isAuth=true;
                  await ApiService().getAuthToken();
                } else {
                  isAuth=false;
                }
              },
            ),
          ),
          // child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child:  TextField(
          //           textAlign: TextAlign.center,
          //           controller: dig1Controller,
          //           keyboardType: TextInputType.number,
          //           maxLength: 1,
          //           enabled: true,
          //           style: TextStyle(fontSize: 14.sp,color: Colors.black),
          //           decoration: const InputDecoration(
          //             counterText: "",
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child:  TextField(
          //           enabled: false,
          //           decoration: const InputDecoration(
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child: const TextField(
          //           enabled: false,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child: const TextField(
          //           enabled: false,
          //
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child: const TextField(
          //           enabled: false,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //       Container(
          //         alignment: Alignment.center,
          //         width: 35.w,
          //         height: 50.h,
          //         decoration: BoxDecoration(
          //           color: otpBoxBg,
          //           border: Border.all(color: otpBoxBorder),
          //           borderRadius: BorderRadius.circular(2.w),
          //         ),
          //         child: const TextField(
          //           enabled: false,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //           ),
          //         ),
          //       ),
          //
          //
          //     ],
          //   ),

          SizedBox(height: 15.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w),
            child: Text("Resend OTP?",
              style: TextStyle(fontSize:14.sp ,fontWeight: FontWeight.normal, color: primaryColor),),
          ),
          SizedBox(height: 30.h,width: 428.w,),
          Container(
            margin: EdgeInsets.only(left: 61.w),
            width: 306.w,
            height: 50.h,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              onPressed: () async {
                if (kDebugMode) {
                  printLine("get temp otp");
                  int? otp = await LocalStorage().getTempOTP();
                  printLine("otp: $otp");
                }
                FocusScope.of(context).requestFocus(FocusNode());
                if(isAuth){
                  await LocalStorage().setLoggedIn(true);
                  printLine("otp auth screen: is logged in: ${await LocalStorage().getIsLoggedIn()}");
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder:
                        (context) =>

                        const DashboardScreen()
                    ),);
                }

                else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Incorrect OTP"),
                  ));
                }

              },
              child: const Text('Submit'),
            ),
          ),
          SizedBox(height: 256.h,width: 428.w,),
        ],
    ),);
  }
}
