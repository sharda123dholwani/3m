import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mmm_sheeting_app_ios_flutter/api_constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';

import 'constants.dart';
import 'screens/splash.dart';

List<CameraDescription> cameras = [];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        minTextAdapt: true,
        builder:(context , child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          // theme: ThemeData(
          //   scaffoldBackgroundColor: bgColor,
          //   textTheme: GoogleFonts.poppinsTextTheme(Theme
          //       .of(context)
          //       .textTheme)
          //       .apply(bodyColor: Colors.white),
          //   canvasColor: secondaryColor,
          // ),
          home: const MySplashScreen(title: 'Splash Screen'),
        );

      }
    );

  }
}

