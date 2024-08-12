import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        // it enables scrolling
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 50.h,
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_outlined,color: txtColor),
                    Text("Menu")
                ],),
              ),
              SizedBox(height: 10.h,),
              DrawerListTile(
                title: "Scan History",
                iconData: Icons.history,
                press: () {},
              ),
              SizedBox(height: 10.h,),

              DrawerListTile(
                title: "About 3M",
                iconData: Icons.info_outline,
                press: () {},
              ),
              DrawerListTile(
                title: "Privacy Policy",
                iconData: Icons.privacy_tip_outlined,
                press: () {},
              ),
              DrawerListTile(
                title: "Log Out",
                iconData: Icons.logout,
                press: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.iconData,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(

      onTap: press,
      horizontalTitleGap: 0.0,
      iconColor: primaryColor,
      leading: Icon(iconData),
      title: Text(
        title,
        style: TextStyle(color: txtColor,fontSize: 16.sw,fontWeight: FontWeight.bold),
      ),
    );
  }
}
