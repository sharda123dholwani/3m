import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
   static  final LocalStorage _instance = LocalStorage._privateConstructor();
   final FlutterSecureStorage storage = FlutterSecureStorage();
  factory LocalStorage() {
    return _instance;
  }
   SharedPreferences? _prefs;

  LocalStorage._privateConstructor() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
    });
  }
/////////
  clearPref(){
    _prefs?.clear();
  }

  clearStorage() async {
    storage.delete(key: 'temp_otp');
    storage.delete(key: 'isLoggedIn');
    storage.delete(key: "user_id");
    storage.delete(key: "mobile");
    storage.delete(key: 'app_usage');
    storage.delete(key: 'country');
    storage.delete(key: 'auth_token');
  }

   setTempOTP(int otp){
    // _prefs?.setInt("temp_otp", otp);
     storage.write(key: "temp_otp", value: otp.toString());
   }

   Future<int?> getTempOTP() async{
    var tempOtpVar = await storage.read(key: "temp_otp");
     //int? tempOTP= _prefs?.getInt("temp_otp");
    int? tempOTP= int.parse(tempOtpVar!);
     return tempOTP;
   }

   setLoggedIn(bool loginFlag){
     //_prefs?.setBool("isLoggedIn", loginFlag);
     storage.write(key: "isLoggedIn", value: loginFlag.toString());
   }

   Future<bool?> getIsLoggedIn() async{
     //bool? tempOTP= _prefs?.getBool("isLoggedIn");
     var isLoggedIn = await storage.read(key: "isLoggedIn");
     bool? tempOTP= bool.parse(isLoggedIn ?? 'false');
     return tempOTP;
   }

  setUserId(int userId){
    //_prefs?.setInt("user_id", userId);
    storage.write(key: "user_id", value: userId.toString());
  }

   Future<int?> getUserId() async {
    var tempuserID = await storage.read(key: "user_id");
     int? userid= int.parse(tempuserID!);
     return userid;
   }

   setMobileNo(String mobileNo) async{
     //_prefs?.setString("mobile", mobileNo);
     storage.write(key: "mobile", value: mobileNo);
   }

   Future<String?> getMobileNo() async{
     String? mobile= await storage.read(key: "mobile");
     return mobile;
   }

   setAppUsage(String appUsage){
     // _prefs?.setString("app_usage", appUsage);
     storage.write(key: "app_usage", value: appUsage);
   }

   Future<String?> getAppUsage() async{
     //String? appUsage= _prefs?.getString("app_usage");
     String? appUsage= await storage.read(key: "app_usage");

     return appUsage;
   }

   setCountry(String country){
    // _prefs?.setString("country", country);
     storage.write(key: "country", value: country);
   }

   Future<String?> getCountry() async{
     //String? country= _prefs?.getString("country");
     String? country= await storage.read(key: "country");

     return country;
   }


   setAuthToken(String token){
    storage.write(key: "auth_token", value: token);
   }

   Future<String?> getToken() async {
    String? authToken = await storage.read(key: "auth_token");
    return authToken;
   }
}