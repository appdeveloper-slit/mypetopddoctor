import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_pet_opd/bn_home.dart';
import 'package:my_pet_opd/bottom_navigation/bottom_navigation.dart';
import 'package:my_pet_opd/manage/static_method.dart';
import 'package:my_pet_opd/values/colors.dart';
import 'package:my_pet_opd/values/dimens.dart';
import 'package:my_pet_opd/values/strings.dart';
import 'package:my_pet_opd/values/styles.dart';

class AddPrescription extends StatefulWidget {
  final String? id;
  final details;
  const AddPrescription({Key? key,this.id,this.details}) : super(key: key);

  @override
  State<AddPrescription> createState() => _AddPrescriptionState();
}

class _AddPrescriptionState extends State<AddPrescription> {
  late BuildContext ctx;
  TextEditingController precCtrl = TextEditingController();
  TextEditingController dosageCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();
  // MULTI
  List<Map<String, dynamic>> prescreptionList = [
    {
      "name": '',
      "dosage": '',
    }
  ];
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(onWillPop: ()async{
      STM().back2Previous(ctx);
      return false;
    },
      child: Scaffold(
        bottomNavigationBar: bottomBarLayout(ctx, 0),
        backgroundColor: Clr().white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().white,
          leading: InkWell(
            onTap: () {
              STM().back2Previous(ctx);
            },
            child: Padding(
              padding: EdgeInsets.only(left: Dim().d16),
              child: SvgPicture.asset(
                'assets/back.svg',
              ),
            ),
          ),
          title: Text(
            'Prescription',
            style: Sty().largeText.copyWith(
                color: Clr().accentColor, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dim().d20),
            child: Column(
              children: [
                SizedBox(height: Dim().d20),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prescreptionList.length,
                    itemBuilder: (context,index){
                     return cardLayout(context,index,prescreptionList);
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    prescreptionList.length == 1 ? Container() : Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: SvgPicture.asset(
                          "assets/plus.svg",
                        ),
                        onPressed: () {
                          setState(() {
                            prescreptionList.removeLast();
                          });
                        },
                        label: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '- Remove one',
                            style: Sty()
                                .smallText
                                .copyWith(color: Clr().primaryDarkColor),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: SvgPicture.asset(
                          "assets/plus.svg",
                        ),
                        onPressed: () {
                          setState(() {
                            prescreptionList.add({
                              "name": "",
                              "dosage": "",
                            });
                          });
                        },
                        label: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '+ Add more',
                            style: Sty()
                                .smallText
                                .copyWith(color: Clr().primaryDarkColor),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                TextField(
                  maxLines: null,
                  minLines: 5,
                  style: Sty().mediumText,
                  controller: remarkCtrl,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  decoration: Sty().TextFormFieldOutlineDarkStyle.copyWith(
                      errorBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
                      enabledBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
                      focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
                      hintText: 'Enter Remark',
                      hintStyle:
                      Sty().mediumText.copyWith(color: Clr().hintColor)),
                ),
                SizedBox(
                  height: Dim().d12,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Clr().primaryColor),
                  onPressed: () {
                    addPrecesptiopn(widget.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Submit',
                      style: Sty().mediumText.copyWith(color: Clr().white),
                    ),
                  ),
                ),
                SizedBox(
                  height: Dim().d12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void addPrecesptiopn(id) async {
    FormData body = FormData.fromMap({
      'appointment_id': id,
      'prescription': jsonEncode(prescreptionList),
      'remark': remarkCtrl.text
    });
    var result =
    await STM().post(ctx, Str().processing, 'add_prescription', body);
    var success = result['success'];
    var message = result['message'];
    if (success) {
      status(status: 1, id: id);
    } else {
      STM().errorDialog(ctx, message);
    }
  }

  Widget cardLayout(ctx,index,list){
   var v =  list[index];
    return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text('Medicine name:- ',
            style: Sty()
                .mediumText
                .copyWith(fontWeight: FontWeight.w500)),
        SizedBox(height: Dim().d4),
        TextField(
          maxLines: null,
          minLines: 1,
          style: Sty().mediumText,
          textInputAction: TextInputAction.newline,
          onChanged: (value) {
            setState(() {
              v['name'] = value;
            });
          },
          keyboardType: TextInputType.multiline,
          decoration: Sty().TextFormFieldOutlineDarkStyle.copyWith(
              errorBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              hintText: 'Enter Medicine Name',
              hintStyle: Sty()
                  .mediumText
                  .copyWith(color: Clr().hintColor)),
        ),
        SizedBox(height: Dim().d8),
        Text('Dosage:- ',
            style: Sty()
                .mediumText
                .copyWith(fontWeight: FontWeight.w500)),
        SizedBox(height: Dim().d4),
        TextField(
          maxLines: null,
          minLines: 2,
          style: Sty().mediumText,
          textInputAction: TextInputAction.newline,
          onChanged: (value) {
            setState(() {
              v['dosage'] = value;
            });
          },
          keyboardType: TextInputType.multiline,
          decoration: Sty().TextFormFieldOutlineDarkStyle.copyWith(
              errorBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              enabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              focusedBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12))),
              hintText: 'Enter Dosage',
              hintStyle: Sty()
                  .mediumText
                  .copyWith(color: Clr().hintColor)),
        ),
      ]),
      SizedBox(height: Dim().d20),
    ],
    );
  }

  void status({id, status}) async {
    FormData body = FormData.fromMap({
      'appointment_id': id,
      'type': status,
    });
    var result =
    await STM().postWithoutDialog(ctx, 'change_appointment_status', body);
    var success = result['success'];
    var message = result['message'];
    if (success) {
      setState(() {
        widget.details['status'] = status;
      });
      STM().successDialogWithReplace(ctx, message, Home());
    }else{
      STM().errorDialog(ctx, message);
    }
  }
}
