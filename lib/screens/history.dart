
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mmm_sheeting_app_ios_flutter/components/history_widget.dart';

import '../constants.dart';
import '../database_helper.dart';
import '../models/feedback.dart';
import '../print_text.dart';

class HistoryScreen extends StatefulWidget {

  // final List<File> imageFileList;
   const HistoryScreen({Key? key,}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
   List<FeedbackModel> listDBFeedback =[];
   List<FeedbackModel> listDBFeedbackYesterday =[];
   List<FeedbackModel> listDBFeedbackToday =[];
   List<FeedbackModel> listDBFeedbackPrevious =[];

   @override
   void initState() {
     loadDb();
     super.initState();

   }

   loadDb() async {
     var millis = DateTime.now().millisecondsSinceEpoch;
     var dt = DateTime.fromMillisecondsSinceEpoch(millis);
     var todayDate = new DateTime.now();
     var formatter = new DateFormat('yyyy-MM-dd');
     String formattedNow = formatter.format(todayDate);
     printLine(formattedNow);
     listDBFeedback= await feedbackList();
     for (var i = 0; i < listDBFeedback.length; i++) {
       var parsedDate = DateTime.parse(listDBFeedback[i].timeStamp);

       String formattedDb= formatter.format(parsedDate);
       printLine(formattedDb);
      if(formattedNow==formattedDb){
        printLine(formattedNow);

        listDBFeedbackToday.add(listDBFeedback[i]);
      }
       //
       // else if(dt.day==parsedDate.day-1 && dt.month==parsedDate.month && dt.year==parsedDate.year) {
       //   listDBFeedbackYesterday.add(listDBFeedback[i]);
       //
       // }

       else{
         listDBFeedbackPrevious.add(listDBFeedback[i]);
       }
       }
     setState(() {
       listDBFeedback;
       listDBFeedbackToday;
       listDBFeedbackPrevious;
     });
   }

   Future<List<FeedbackModel>> feedbackList() async {
    // Get a reference to the database.
    final db = DatabaseHelper();
    await db.init();

    printLine(await db.queryRowCountStatus0());

    final List<Map<String, dynamic>> maps = await db.queryAllRowsStatusNot0();
    List<FeedbackModel> feedbackRows =List.generate(maps.length, (i) {
      return FeedbackModel(
        maps[i]['_id'],
        maps[i]['image_path'],
        maps[i]['prediction_type'],
        maps[i]['prediction_color'],
        maps[i]['feedback'],
        maps[i]['correct_ans_type'],
        maps[i]['correct_ans_color'],
        maps[i]['flash'],
        maps[i]['image_name'],
        maps[i]['time_stamp'],
        maps[i]['status'],
      );
    }
    );
    return feedbackRows;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:dashboardBgColor ,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: txtColor,
        centerTitle: true,
        title: const Text('Scanning History',style: TextStyle(color: txtColor,fontSize: 16),),
        leading: GestureDetector(
            onTap:()
            {Navigator.of(context).pop();},
            child: const Icon(Icons.arrow_back)),

      ),

      body:  SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25.h,),
              Visibility(
                visible: listDBFeedbackToday.isNotEmpty ,
                child: Container(
                  margin: EdgeInsets.only(left: 31.w),
                  child:  Text("Today",style: TextStyle(color: titleTxtColor,fontSize: 14.sp,
                  ),),
                ),
              ),
              Visibility(
                      visible: listDBFeedbackToday.isNotEmpty ,
                      child: SizedBox(height: 9.h,)),
              Visibility(
                visible: listDBFeedbackToday.isNotEmpty ,
                child: Container(
                  margin: EdgeInsets.only(left: 23.w,right: 23.w,top: 20.h),
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: listDBFeedbackToday.length,
                        itemBuilder: (BuildContext context, int index) {
                          return HistoryWidget(
                              imageName: listDBFeedbackToday[index].imageName,
                              predictionColor: listDBFeedbackToday[index].predictionColor,
                              predictionType: listDBFeedbackToday[index].predictionType,
                              image: File(listDBFeedbackToday[index].imagePath),
                              );

                        }, separatorBuilder: (context, index) =>  SizedBox(
                           height: 10.h,
    )
                    ),

                ),
              ),
              Visibility(
                  visible: listDBFeedbackToday.isNotEmpty ,
                  child: SizedBox(height: 31.h,)),
              // Visibility(
              //   visible: listDBFeedbackYesterday.length!=0,
              //   child: Container(
              //     margin: EdgeInsets.only(left: 31.w),
              //     child:  Text("Yesterday",style: TextStyle(color: titleTxtColor,fontSize: 14.sp,
              //     ),),
              //   ),
              // ),
              // Visibility(
              //     visible: listDBFeedbackYesterday.length!=0 ,
              //     child: SizedBox(height: 9.h,)),
              //
              // Visibility(
              //   visible: listDBFeedbackYesterday.length!=0 ,
              //   child: Container(
              //     margin: EdgeInsets.only(left: 23.w,right: 23.w,top: 20.h),
              //
              //     child: ListView.separated(
              //         physics: const NeverScrollableScrollPhysics(),
              //         shrinkWrap: true,
              //         itemCount: listDBFeedbackYesterday.length,
              //         itemBuilder: (BuildContext context, int index) {
              //           return HistoryWidget(
              //             imageName: listDBFeedbackYesterday[index].imageName,
              //             predictionColor: listDBFeedbackYesterday[index].predictionColor,
              //             predictionType: listDBFeedbackYesterday[index].predictionType,
              //             image: File(listDBFeedbackYesterday[index].imagePath),
              //           );
              //
              //         }, separatorBuilder: (context, index) =>  SizedBox(
              //       height: 10.h,
              //     )
              //     ),
              //
              //   ),
              // ),
              // Visibility(
              //     visible: listDBFeedbackYesterday.length!=0 ,
              //     child: SizedBox(height: 31.h,)),
              Visibility(
                visible: listDBFeedbackPrevious.isNotEmpty ,
                child:  Container(
                  margin: EdgeInsets.only(left: 31.w),
                  child: Text("Older",style: TextStyle(color: titleTxtColor,fontSize: 14.sp,
                  ),),
                ),
              ),
              Visibility(
                  visible: listDBFeedbackPrevious.isNotEmpty ,
                  child: SizedBox(height: 9.h,)),

              Visibility(
                visible: listDBFeedbackPrevious.isNotEmpty ,
                child: Container(
                  margin: EdgeInsets.only(left: 23.w,right: 23.w,top: 20.h),

                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: listDBFeedbackPrevious.length,
                      itemBuilder: (BuildContext context, int index) {
                        return HistoryWidget(
                          imageName: listDBFeedbackPrevious[index].imageName,
                          predictionColor: listDBFeedbackPrevious[index].predictionColor,
                          predictionType: listDBFeedbackPrevious[index].predictionType,
                          image: File(listDBFeedbackPrevious[index].imagePath),
                        );

                      }, separatorBuilder: (context, index) =>  SizedBox(
                    height: 10.h,
                  )
                  ),

                ),
              ),

            ],
          ),
      ),



    );
  }

   Widget _buildRow(FeedbackModel feedback) {
     return HistoryWidget(imageName: feedback.imageName, image: File(feedback.imagePath), predictionType: feedback.predictionType, predictionColor:feedback.predictionColor);
   }


}
