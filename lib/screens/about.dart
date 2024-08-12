
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
  appBar: AppBar(
    backgroundColor: Colors.white,
    foregroundColor: txtColor,
    centerTitle: true,
    title: const Text('About 3M',style: TextStyle(color: txtColor,fontSize: 16),),
    leading: GestureDetector(
      onTap:()
        {Navigator.of(context).pop();},
        child: const Icon(Icons.arrow_back)),

      ),

      body: Container(
        margin: EdgeInsets.only(left: 56.w,right: 56.w,top: 50.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Image.asset(
            'assets/images/mmm_logo.png',
            fit: BoxFit.fill,
            width: 82.w,
            height: 41.h,
          ),
          SizedBox(height: 20.h,),
            const Text(
              "Brighter signs for safer roads \n \n3M has provided some of the leading traffic safety solutions around the world. Retroreflective technology is one of them, and was pioneered for development by 3M some 80 years ago. As the technology advanced over the years, international road safety standards for urban, rural and highway roads have also changed to embrace the higher light return efficiency of newer retroreflective materials.",
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.normal,
                fontSize: 11.0,
                letterSpacing: 1,
                wordSpacing: 1,
              ),
            ),

            SizedBox(height: 20.h,),
            const Text(
              "For more details visit our website",
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                letterSpacing: 1,
                wordSpacing: 1,
              ),
            ),

            SizedBox(height: 20.h,),
            const Text(
              "For more details visit our website",
              style: TextStyle(
                color: txtColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
                letterSpacing: 1,
                wordSpacing: 1,
              ),
            ),
            SizedBox(height: 5.h,),
            InkWell(
              onTap: () {
                launchUrl(Uri.parse("https://www.3mindia.in/3M/en_IN/p/c/films-sheeting/reflective-sheeting/"));
              },
              child: const Text(
                "https://www.3mindia.in/3M/en_IN/p/c/films-sheeting/reflective-sheeting/",
                style: TextStyle(
                  color: Color(0Xff1232c4),
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                  letterSpacing: 1,
                  wordSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
