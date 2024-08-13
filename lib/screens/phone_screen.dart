
import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dashboard_screen.dart';
import 'package:mmm_sheeting_app_ios_flutter/api_constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/constants.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api_service.dart';
import '../print_text.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({Key? key}) : super(key: key);


  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {

  TextEditingController phoneNoController = TextEditingController();
  String phoneCode='91';
  String countryName='India';
  String countryCode='in';
  String dropdownValueAppUsage = AppConstants.listAppUsage.first;
  bool isLoading=false;
  bool isButtonDisabled = false;


  void login() async {
    if(phoneNoController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Phone No. cannot be Empty"),
      ));
      return;
    }
    else {
      setState(() {
        isLoading=true;
        isButtonDisabled=true;
      });

      int? userResponseStatus= await ApiService().getOTP('+$phoneCode${phoneNoController.text}')  ;
      printLine("user Response phone screen: $userResponseStatus");
      if(userResponseStatus==404){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(AppConstants.loginUserNotFound),
        ));
        setState(() {
          isLoading=false;
          isButtonDisabled=false;

        });
      }
      else if(userResponseStatus==200){
        LocalStorage().setCountry(countryName);
        LocalStorage().setAppUsage(dropdownValueAppUsage);
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
          content: Text("logged in successfully!!"),
        ));

        Navigator.pushReplacement(context,
          MaterialPageRoute(builder:
              (context) =>

          const DashboardScreen()
          ),);

        setState(() {
          isLoading=false;
        });
      }

      else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong. Please try again later                                                                                                                                                                                                                                                        "),
        ));

        setState(() {
          isLoading=false;
          isButtonDisabled=false;
        });
      }


    }
  }

  @override
  void initState() {
    super.initState();

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:true,
      backgroundColor: bgColor,
      body : Stack(
        children: [SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 132.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                width: 59.w,
                height: 61.h,
          
                child: SvgPicture.asset(
                  "assets/icons/login_phone.svg",
                ),
              ),
              SizedBox(height: 32.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                child: Text("Hello!",
                  style: TextStyle(fontSize:22.sp ,fontWeight: FontWeight.bold, color: txtColor),),
              ),
              SizedBox(height: 11.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                child: Text("Let’s Get Started",
                  style: TextStyle(fontSize:16.sp ,fontWeight: FontWeight.normal, color: txtColor),),
              ),
              SizedBox(height: 56.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                child: Text("Country",
                  style: TextStyle(fontSize:16.sp ,fontWeight: FontWeight.normal, color: txtColor),),
              ),
              SizedBox(height: 10.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                width: 306.w,
                height: 50.h,
                decoration: BoxDecoration(
                  border: Border.all(color: boxBorder),
                  borderRadius: BorderRadius.circular(5.w),
                ),
          
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 14.w,height: 50.h,),
                    // Container(
                    //   alignment: Alignment.center,
                    //   width: 20.w,
                    //   height: 20.h,
                    //
                    //   child: Image.asset("assets/flags/in.svg",fit: BoxFit.cover),
                    // ),
                    SizedBox(width: 20.w,height: 50.h,),
                    SizedBox(
                      width: 160.w,
                      child: Text(countryName,
                        style: TextStyle(fontSize:16.sp ,fontWeight: FontWeight.normal, color: txtColor),),
                    ),
                    SizedBox(width: 60.w,height: 50.h,),
          
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        printLine("Print country");
                        showCountryPicker(
                          context: context,
                          favorite: <String>['IN','AU','MY','ID','TH','PH'],
                          //Optional. Shows phone code before the country name.
                          showPhoneCode: true,
                          onSelect: (Country country) {
          
                            phoneCode=country.phoneCode;
                            countryName=country.name;
                            setState(() {
                              phoneCode;
                              countryName;
                            });
                            if (kDebugMode) {
                              printLine(country.name);
                            }
                          },
                          // Optional. Sets the theme for the country list picker.
                          countryListTheme: CountryListThemeData(
                            textStyle:TextStyle(
                              color: txtColor,
                              fontSize: 14.sp,
                            ) ,
                            // Optional. Sets the border radius for the bottom sheet.
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.w),
                              topRight: Radius.circular(20.w),
                            ),
                            // Optional. Styles the search field.
                            inputDecoration: InputDecoration(
                              labelText: 'Search',
                              hintText: 'Start typing to search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:  txtColor.withOpacity(0.2),
                                ),
                              ),
                            ),
                            // Optional. Styles the text in the search field
                            searchTextStyle: TextStyle(
                              color: txtColor,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 12.w,
                        height: 7.2.h,
                        margin: EdgeInsets.only(right: 16.w),
                        child: SvgPicture.asset(
                          "assets/icons/arrow_expand.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
          
                  ],
                ),
          
          
          
              ),
              SizedBox(height: 39.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                width: 306.w,
                height: 50.h,
                decoration: BoxDecoration(
                  border: Border.all(color: boxBorder),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 20.w,right: 20.w),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValueAppUsage,
                      icon: SvgPicture.asset(
                        "assets/icons/arrow_expand.svg",
                        fit: BoxFit.fill,
                      ),
                      elevation: 16,
                      style: const TextStyle(color: txtColor),

                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValueAppUsage = value!;
                        });
                      },
                      items: AppConstants.listAppUsage.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 39.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                child: Text("Phone Number",
                  style: TextStyle(fontSize:12.sp ,fontWeight: FontWeight.normal, color: txtColor),),
              ),
              SizedBox(height: 11.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                width: 306.w,
                height: 50.h,
                decoration: BoxDecoration(
                  border: Border.all(color: boxBorder),
                  borderRadius: BorderRadius.circular(5.w),
                ),
          
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
          
                    Container(
                      alignment: Alignment.center,
                      width: 54.w,
                      color: boxBorder,
                      height: 50.h,
                      child: Text('+$phoneCode',style: TextStyle(fontSize:14.sp ,fontWeight: FontWeight.normal, color: txtColor),),
                    ),
          
                    SizedBox(height: 50.h,width: 18.w,),
          
                    Container(
                      alignment: Alignment.center,
                      height: 50.h,
                      width: 230.w,
                      child: TextField(
                        controller: phoneNoController,
                        enabled: true,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 14.sp,color: txtColor),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Phone Number',
                        ),
                      ),
                    ),
                  ],
                ),
          
              ),
              SizedBox(height: 30.h,width: 428.w,),

              Container(
                margin: EdgeInsets.only(left: 57.w),
                alignment: Alignment.center,
                width: 230.w,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: "By creating an account, you are agreeing to our\n",
                      style: const TextStyle(color: txtColor),
                      children: [
                        TextSpan(
                          text: "Privacy Notice",
                          style: const TextStyle(fontWeight: FontWeight.bold,color: txtColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showModal(
                                context: context);
                                },
                              )
                  ],),),
                ),
              ),
              SizedBox(height: 10.h,width: 428.w,),
              Container(
                margin: EdgeInsets.only(left: 57.w),
                width: 306.w,
                height: 50.h,
                child: TextButton(
                  style: isButtonDisabled?
                  ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(secondaryColor),
                    foregroundColor: MaterialStateProperty.all<Color>(feedbackBg),
                  )
                      :ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: isButtonDisabled? null: (){
                    FocusScopeNode currentFocus = FocusScope.of(context);
          
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    login();
          
                  },
                  child: const Text('Next'),
                ),
              ),
              SizedBox(height: 29.h,width: 428.w,),
              Container(
                alignment: Alignment.center,
                child: Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Text("You will receive a ",
                              style: TextStyle(fontSize:14.sp ,fontWeight: FontWeight.normal, color: txtColor),
                            ),
                            Text("One Time Password",
                              style: TextStyle(fontSize:14.sp ,fontWeight: FontWeight.normal, color: primaryColor), ),]
                      ),
                      Text("on this number to Log In",
                        style: TextStyle(fontSize:14.sp ,fontWeight: FontWeight.normal, color: txtColor),
                      ),
          
                    ]
                ),
              ),
              SizedBox(height: 160.h,width: 428.w,),

            ],
          ),
        ),
        isLoading ? const Center(child: CircularProgressIndicator(
          backgroundColor: bgColor,
          color: feedbackBg,
        ),): const SizedBox()
        ],
      ),

    );
  }

  Future<void> showModal({required BuildContext context}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: const Text('Privacy Notice',style: TextStyle(color: txtColor),),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  style:TextStyle(color: txtColor),
                  text:
                  AppConstants.privacyPolicyText,
                ),
                TextSpan(
                  style: const TextStyle(color: Colors.blue),
                  text: "\nPrivacy Notice",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const url = AppConstants.privacyNoticeURL;
                      launchUrl(Uri.parse(url));
                    },
                ),
              ]
            )
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('OK',style: TextStyle(color: primaryColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
