import 'package:flutter/material.dart';

openLoadinDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (builder) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(),
            ),
          ],
        );
      });
}

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
