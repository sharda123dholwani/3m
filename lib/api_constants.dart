import 'env.dart';

class ApiConstants {
  //static String baseUrl = AppEnvironment.baseUrl;
   static String baseUrl='https://usermanagement-test.elorca.com/api';
  static String feedbackApi = '/analysis';
  static String otpApi = '/otp';
}

class AppConstants {
  static String appName='3M Reflective Verify';
  static const List<String> listAppUsage = <String>['Traffic Signs','Vehicle Markings'];
  static const List<String> listColors = <String>['Select Color','Fluorescent Yellow-Green','White','Red','Green','Fluorescent Yellow','Yellow','Blue','Brown','Fluorescent Orange','Orange','Galaxywhite',];
  static const List<String> listType = <String>['Select Type','Type IX','Type XI','Non 3M','Type IV','Type I','Type VIII','Invalid'];
  static const List<String> listFlash = <String>['Select Mode','ON','OFF'];
  static const String loginUserNotFound='Mobile No. not registered. Please contact Admin';
  static const String privacyNoticeURL="https://www.3m.com/3M/en_US/privacy-policy-select-location/";
  static const String privacyPolicyText='''3M takes your privacy seriously. 3M and its authorized third parties will use the personal information you provide in accordance with our Privacy Policy for the purpose of granting you access to use the app. Please be aware that this information may be stored on a server located in the U.S. For further information, please refer to 3M’s Privacy Policy .\nFor more information visit the following link''';

}