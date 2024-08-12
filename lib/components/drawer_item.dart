import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:60.h,width:400.w,
      child: Row(children: [
        SizedBox(
            width: 59.w,
            height: 61.h,

            child: Icon(icon,color: primaryColor,)
        ),

        Text(title,style: TextStyle(color: txtColor,fontSize: 16.sp),)
      ],),
    );
  }
}
