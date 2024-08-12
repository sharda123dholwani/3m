import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';

class HistoryWidget extends StatelessWidget {
  final String imageName;
  final File image;
  final String predictionType;
  final String predictionColor;

  const HistoryWidget({ Key? key, required this.imageName, required this.image, required this.predictionType, required this.predictionColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 382.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 24.w,),
          CircleAvatar(
            radius: 25.h,
            backgroundColor: const Color(0XFF433535),
            child: ClipOval(
              child: Image.file(
                width: 50.w,
                  height: 50.h,
                  fit: BoxFit.cover,
                  image,
                ),
            ),

          ),
          SizedBox(width: 15.w,),
          SizedBox(
            width: 55.w,
            child: Text(imageName,style: TextStyle(color: txtColor,fontSize: 14.sp,
            ),),
          ),
          SizedBox(width: 10.w,),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SizedBox(width: 10.h,),
              Text(predictionType,style: TextStyle(color: txtColor,fontSize: 14.sp,
              ),),
              SizedBox(width: 10.h,),
              Text(predictionColor,style: TextStyle(color: txtColor,fontSize: 14.sp,
              ),),
              SizedBox(width: 10.h,),
            ],
          )

          // Image.asset(
          //   'assets/images/mmm_logo.png',
          //   fit: BoxFit.fill,
          //   width: 22.w,
          //   height: 12.h,
          // ),

        ],
      ),
    );
  }
}
