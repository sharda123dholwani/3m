import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mmm_sheeting_app_ios_flutter/print_text.dart';
import 'package:mmm_sheeting_app_ios_flutter/shared_preference.dart';

import 'api_constants.dart';
import 'database_helper.dart';
import 'models/feedback.dart';

class ApiService {
  Future<int?> getOTP(String mobileNo) async {
    try {
      printLine("api base url: ${ApiConstants.baseUrl}");
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.otpApi);
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'mobile': mobileNo,
        }),
      );
      printLine("request:${response.request?.url}");

      printLine("response: ${response.body}");
      printLine("${response.request}");

      if (response.statusCode == 404) {
        return response.statusCode;
      }
      else
        if (response.statusCode == 200){
        final jsonBody = json.decode(response.body);
        int userId = (jsonBody['user_id']);
        await LocalStorage().setUserId(userId);
        await LocalStorage().setLoggedIn(false);
        print("api_services:getOTP:${jsonBody['otp']}");
        await LocalStorage().setTempOTP(jsonBody['otp']);
        printLine ("${jsonBody['otp']}"
        );
        await LocalStorage().setMobileNo(jsonBody['mobile']);
        return response.statusCode;
      }
      else {
        return 0;
      }
    } catch (e) {
      log(e.toString());
      return 0;
    }
  }
  Future<void> getAuthToken() async {
    String url = ApiConstants.baseUrl+ApiConstants.otpApi;
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET',Uri.parse(url));
    int? userId = await LocalStorage().getUserId();
    int? otp  = await LocalStorage().getTempOTP();

    request.body = json.encode({
      "user_id":userId,
      "otp":otp
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
   // printLine("response:apiservices:getauthtoken: ${await response.stream.bytesToString()}");
    var responseData = await response.stream.bytesToString();
      printLine("responseData: $responseData");
    var jsonBody = await jsonDecode(responseData);
    printLine("jsonbody: $jsonBody");
    String data = jsonBody['data'];

    await LocalStorage().setAuthToken(data);
    printLine("tokn: ${await LocalStorage().getToken()}");

}
  Future<int?> sendFeedback(FeedbackModel feedbackStatus1) async {
  printLine("api base url: ${ApiConstants.baseUrl}");
  printLine("feedback: ${feedbackStatus1.correctAnsColor}");
  printLine("feedback: ${feedbackStatus1.predictionColor}");
  printLine(feedbackStatus1.predictionType);
  printLine(feedbackStatus1.correctAnsType);


  printLine("feedback status image path: ${feedbackStatus1.imagePath}");
    if (kDebugMode) {
      printLine('New feedback');
    }
    String flash;
    printLine("feedbackstatus1: ${feedbackStatus1.flash}");
    // if(feedbackStatus1.flash=='Select Mode'|| feedbackStatus1.flash=='ON'|| feedbackStatus1.flash==''){
    //   flash='1';
    // }
    // else {
    //   flash= '0';
    // }
  if(feedbackStatus1.flash=='true'){
    flash='1';
  }
  else  {
    flash= '0';
  }
    final db = DatabaseHelper();
    await db.init();
    int? userId = await LocalStorage().getUserId();
    printLine("user_id: $userId");
    String? authToken = await LocalStorage().getToken();
    printLine("send Feedback authToken: $authToken");
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.baseUrl + ApiConstants.feedbackApi));
    //request.files.add(await http.MultipartFile.fromPath('image', feedbackStatus1.imagePath));
    // request.fields['feedback']=feedbackStatus1.feedback;
    // request.fields['prediction']=feedbackStatus1.predictionType;
    // request.fields['createdBy']=userId.toString();
    // request.fields['feedbackType']=feedbackStatus1.correctAnsType;
    // request.fields['feedbackColor']=feedbackStatus1.correctAnsColor;
    // request.fields['predictionType']=feedbackStatus1.predictionType;
    // request.fields['predictionColor']=feedbackStatus1.predictionColor;
    // request.fields['isFlash']=flash;

  request.fields.addAll({
    'feedback': feedbackStatus1.feedback,
    'predictionType': feedbackStatus1.predictionType,
    'predictionColor': feedbackStatus1.predictionColor,
    'feedbackType': feedbackStatus1.correctAnsType,
    'feedbackColor':feedbackStatus1.correctAnsColor,
    'createdBy': userId.toString(),
    'isFlash': flash
  });
  request.files.add(await http.MultipartFile.fromPath('image', feedbackStatus1.imagePath));
  request.headers.addAll(
      {
      'Authorization': authToken!,
      'userid': userId.toString()
    });
    printLine("request:");

    printLine({request.fields});

    try {
      printLine("entering into try block");
      var response = await request.send();
      printLine("response: ${response.statusCode}");
      printLine("response: ${response.request}");

      var feedbackResponse=await http.Response.fromStream(response);
      printLine("feedbackResponse: ${feedbackResponse.body}");
      final responseData=json.decode(feedbackResponse.body);
      printLine("responseData: $responseData");
      printLine("feedback response");
      printLine(response.statusCode);
      if (response.statusCode == 200) {
        printLine(responseData);
        return 1;
      }

      else if (response.statusCode == 201) {
        await db.updateFeedbackStatusTo2(feedbackStatus1);
        printLine(responseData);
        return 1;
      }

      else if (response.statusCode == 400) {
        printLine(responseData);
        return 0;
      }

      else {
        printLine("error");
        return 0;
      }


    } catch (e) {
      printLine("error:$e");

      return 0;
    }
  }
}