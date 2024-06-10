import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

BackdropFilter showLoadingWhatsapp(BuildContext context) {
  return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Lottie.asset("assets/images/sendingEn.json",
          width: 250, height: 250));
  // showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
  //           child: Lottie.asset("assets/images/sendingEn.json",
  //               width: 250, height: 250));
  //     });
}
