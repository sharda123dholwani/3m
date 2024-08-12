
import 'package:flutter/material.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';

class PrivacyScreen extends StatelessWidget {

  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: txtColor,
        centerTitle: true,
        title: const Text('Privacy Policy',style: TextStyle(color: txtColor,fontSize: 16),),
      leading: GestureDetector(
            onTap:()
            {Navigator.of(context).pop();},
            child: const Icon(Icons.arrow_back)),

      ),

    );
  }
}
