import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import 'dashboard_screen.dart';
import 'phone_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';

import '../constants.dart';
import '../print_text.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key, required this.title});

  final String title;

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

bool isLoggedin = false;

void getLoginStatus() async {
  bool isLoggedIn=  await LocalStorage().getIsLoggedIn()??false;
  setState(() {
    isLoggedin = isLoggedIn;
    printLine("splash screen => login status=> $isLoggedin");
  });

  if (!isLoggedin) {

    Timer(const Duration(seconds: 3),
            ()=>
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder:
                    (context) =>
                const PhoneScreen()
                )
            )
    );
  }

  else {
    Timer(const Duration(seconds: 3),
            ()=>
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder:
                    (context) =>
                    const DashboardScreen()
                )
            )
    );
  }
}

void checkUpdate() async {
  InAppUpdate.checkForUpdate().then((updateInfo) {
    printLine("checkForUpdate: $updateInfo");
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      if (updateInfo.immediateUpdateAllowed) {
        // Perform immediate update
        InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
          if (appUpdateResult == AppUpdateResult.success) {
            //App Update successful
          }
        });
      } else if (updateInfo.flexibleUpdateAllowed) {
        //Perform flexible update
        InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
          if (appUpdateResult == AppUpdateResult.success) {
            //App Update successful
            InAppUpdate.completeFlexibleUpdate();
          }
        });
      }
    }
  });
}

  @override
  initState()  {
    checkUpdate();
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      // Prints after 1 second.
    });
    getLoginStatus();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 390.h),
            width: 104.w,
            height: 55.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/mmm_logo.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 20.h),
            child: Text("3M Reflective Verify",
              style: TextStyle(fontSize:16.sp , color: txtColor),),
          )
        ],
      ),
    );
  }
}
