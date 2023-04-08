import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_pet_opd/values/colors.dart';
import 'package:my_pet_opd/viewfullimage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_details.dart';
import 'bn_home.dart';
import 'manage/static_method.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class OPDAppointment extends StatefulWidget {
  @override
  State<OPDAppointment> createState() => _OPDAppointmentState();
}

class _OPDAppointmentState extends State<OPDAppointment>
    with TickerProviderStateMixin {
  late BuildContext ctx;
  List<dynamic> todaysList = [];
  List<dynamic> upcomingList = [];
  List<dynamic> completedList = [];
  String? Userid;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      Userid = sp.getString('userid');
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        opdAppoinment();
      }
    });
  }

  @override
  void initState() {
    getSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    TabController _controller = TabController(length: 3, vsync: this);
    return WillPopScope(
      onWillPop: () async {
        STM().finishAffinity(ctx, Home());
        return false;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
            backgroundColor: Clr().white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Clr().white,
              bottom: TabBar(
                isScrollable: true,
                padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                labelColor: Clr().primaryColor,
                indicatorColor: Clr().primaryColor,
                automaticIndicatorColorAdjustment: true,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(
                    text: 'Today',
                  ),
                  Tab(
                    text: 'Upcoming',
                  ),
                  Tab(
                    text: 'Completed',
                  ),
                ],
              ),
              leading: InkWell(
                onTap: () {
                  STM().finishAffinity(ctx, Home());
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SvgPicture.asset(
                    'assets/back.svg',
                  ),
                ),
              ),
              title: Text(
                'OPD Appointment',
                style: Sty().largeText.copyWith(
                    color: Clr().accentColor, fontWeight: FontWeight.w500),
              ),
              centerTitle: true,
            ),
            body: TabBarView(
              children: [
                todaysList.isEmpty
                    ? Center(
                        child: Text(
                        "No Appointments Today",
                        style: Sty().mediumBoldText,
                      ))
                    : ListView.builder(
                        itemCount: todaysList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: todaysLayout(context, index, todaysList),
                          );
                        }),
                upcomingList.isEmpty
                    ? Center(
                        child: Text(
                          'No Upcoming Appointments',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : ListView.builder(
                        itemCount: upcomingList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: upcomingLayout(context, index, upcomingList),
                          );
                        }),
                completedList.isEmpty
                    ? Center(
                        child: Text(
                          'No Completed Appointments',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : ListView.builder(
                        itemCount: completedList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child:
                                completedLayout(context, index, completedList),
                          );
                        }),
              ],
            )),
      ),
    );
  }

  Widget todaysLayout(ctx, index, list) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.1,
              blurRadius: 10,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            STM().redirect2page(
                ctx,
                AppointmentDetails(
                  details: list[index],
                ));
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Clr().borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        STM().redirect2page(
                            ctx,
                            ViewfullImage(
                              url: list[index]['pet']['image_path'].toString(),
                            ));
                      },
                      child: Container(
                          width: Dim().d120,
                          height: Dim().d120,
                          child: Image.network(
                            '${list[index]['pet']['image_path'].toString()}',
                            fit: BoxFit.cover,
                          ))),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Dim().d160,
                        child: Text(
                          'Appointment ID : #${list[index]['appointment_id'].toString()}',
                          style: Sty().mediumText.copyWith(
                                color: Clr().accentColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Text(
                          '${list[index]['user']['name'].toString()}',
                          overflow: TextOverflow.fade,
                          style: Sty().smallText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Text(
                          'Pet Name : ${list[index]['pet']['name'].toString()}',
                          overflow: TextOverflow.fade,
                          style: Sty().smallText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Row(
                          children: [
                            Text(
                              'Date : ${list[index]['appointment_date'].toString()}',
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            SizedBox(
                              width: Dim().d8,
                            ),
                            Text(
                              '${list[index]['slot']['slot'].toString()}',
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget upcomingLayout(ctx, index, list) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.1,
              blurRadius: 10,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            STM().redirect2page(
                ctx,
                AppointmentDetails(
                  details: list[index],
                ));
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Clr().borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        STM().redirect2page(
                            ctx,
                            ViewfullImage(
                              url: list[index]['pet']['image_path'].toString(),
                            ));
                      },
                      child: Container(
                          width: Dim().d120,
                          height: Dim().d120,
                          child: Image.network(
                            '${list[index]['pet']['image_path'].toString()}',
                            fit: BoxFit.cover,
                          ))),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Dim().d160,
                        child: Text(
                          'Appointment ID : #${list[index]['appointment_id'].toString()}',
                          style: Sty().mediumText.copyWith(
                                color: Clr().accentColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Text(
                          '${list[index]['user']['name'].toString()}',
                          overflow: TextOverflow.fade,
                          style: Sty().smallText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Text(
                          'Pet Name : ${list[index]['pet']['name'].toString()}',
                          overflow: TextOverflow.fade,
                          style: Sty().smallText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Row(
                          children: [
                            Text(
                              'Date : ${list[index]['appointment_date'].toString()}',
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            SizedBox(
                              width: Dim().d8,
                            ),
                            Text(
                              '${list[index]['slot']['slot'].toString()}',
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget completedLayout(ctx, index, list) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.1,
              blurRadius: 10,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            STM().redirect2page(
                ctx,
                AppointmentDetails(
                  details: list[index],
                ));
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Clr().borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        STM().redirect2page(
                            ctx,
                            ViewfullImage(
                              url: list[index]['pet']['image_path'].toString(),
                            ));
                      },
                      child: Container(
                          width: Dim().d120,
                          height: Dim().d120,
                          child: Image.network(
                            '${list[index]['pet']['image_path'].toString()}',
                            fit: BoxFit.cover,
                          ))),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Dim().d160,
                        child: Text(
                          'Appointment ID : #${list[index]['appointment_id'].toString()}',
                          style: Sty().mediumText.copyWith(
                                color: Clr().accentColor,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Text(
                          '${list[index]['user']['name'].toString()}',
                          overflow: TextOverflow.fade,
                          style: Sty().smallText.copyWith(
                                color: Clr().black,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      // list[index]['status'] == 0 ? Container() : SizedBox(
                      //   height: 8,
                      // ),
                      // list[index]['status'] == 0 ? Container(
                      //   width: Dim().d160,
                      //   child: Text(
                      //     'Pet Name : ${list[index]['pet']['name'].toString()}',
                      //     overflow: TextOverflow.fade,
                      //     style: Sty().smallText.copyWith(
                      //       color: Clr().black,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                      // ) : Container(),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: Dim().d160,
                        child: Wrap(
                          children: [
                            Text(
                              'Date : ${list[index]['appointment_date'].toString()}',
                              overflow: TextOverflow.fade,
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            SizedBox(
                              width: Dim().d8,
                            ),
                            Text(
                              '${list[index]['slot']['slot'].toString()}',
                              overflow: TextOverflow.fade,
                              style: Sty().smallText.copyWith(
                                    color: Clr().black,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        list[index]['status'] == 1 ? 'Completed' : 'Cancelled',
                        style: Sty().smallText.copyWith(
                              color: list[index]['status'] == 1
                                  ? Clr().green
                                  : Clr().errorRed,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void opdAppoinment() async {
    FormData body = FormData.fromMap({'doctor_id': Userid, 'type': 1});
    var result = await STM().postWithoutDialog(ctx, 'opd_appointment', body);
    var success = result['success'];
    var message = result['message'];
    if (success) {
      setState(() {
        todaysList = result['today_appointments'];
        upcomingList = result['upcoming_appointments'];
        completedList = result['completed_appointments'];
      });
    } else {
      STM().errorDialog(ctx, message);
    }
  }
}
