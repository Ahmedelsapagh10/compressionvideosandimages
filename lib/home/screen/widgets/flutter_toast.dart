import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

flutterToast({required String msg}) {
  return Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
// EasyLoading.showToast(msg);
