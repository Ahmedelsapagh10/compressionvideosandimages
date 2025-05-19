import 'package:flutter/material.dart';

createProgressDialog(BuildContext context, String msg) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 4),
          // width: getSize(context) / 4,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
        // content: Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Flexible(
        //         child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
        //       child: Text(msg),
        //     )),
        //     const CircularProgressIndicator(color: whiteColor),
        //   ],
        // ),
      );
    },
  );
}
