import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';

class Circle extends StatelessWidget {
  const Circle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
      height: 10,
      width: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [BoxShadow(color: txtColor ,spreadRadius: 5,blurRadius: 7,offset: Offset(0,3))]
      ),
    ));
  }
}
