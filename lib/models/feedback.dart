import 'package:flutter/material.dart';

class FeedbackModel {
  late int _id;
  late int _status;
  late String _imagePath, _imageName,_predictionType, _predictionColor,_feedback,_correctAnsType,_correctAnsColor,_flash,_timeStamp;
FeedbackModel(this._id,this._imagePath,this._predictionType,this._predictionColor,this._feedback,this._correctAnsColor,this._correctAnsType,this._flash,this._imageName,this._timeStamp,this._status);
  FeedbackModel.fromMap(dynamic obj) {
    _id=obj['_id'];
    _imagePath = obj['image_path'];
    _predictionType = obj['prediction_type'];
    _predictionColor = obj['prediction_color'];
    _feedback=obj['feedback'];
    _correctAnsType=obj['correct_ans_type'];
    _correctAnsColor=obj['correct_ans_color'];
    _flash=obj['flash'];
    _imageName = obj['image_name'];
    _timeStamp = obj['time_stamp'];
    _status = obj['status'];

  }
  int get id => _id;
  String get imagePath => _imagePath;
  String get predictionType => _predictionType;
  String get predictionColor => _predictionColor;
  String get imageName => _imageName;
  String get feedback => _feedback;
  String get flash => _flash;
  String get correctAnsType => _correctAnsType;
  String get correctAnsColor => _correctAnsColor;
  String get timeStamp => _timeStamp;
  int get status => _status;


  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['_id'] = id;
    map["image_path"] = imagePath;
    map["prediction_type"] = predictionType;
    map["prediction_color"] = predictionColor;
    map["feedback"] = feedback;
    map["correct_ans_type"] = correctAnsType;
    map["correct_ans_color"] = correctAnsColor;
    map["flash"] = flash;
    map["image_name"] = imageName;
    map["time_stamp"] = timeStamp;
    map["status"] = status;

    return map;
  }

}