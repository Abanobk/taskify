import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


Future<bool?> flutterToastCustom({required String msg,Color? color}){
  return    Fluttertoast.showToast(
    msg:msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: color ?? Colors.red,
    textColor: Colors.white,
  );
}