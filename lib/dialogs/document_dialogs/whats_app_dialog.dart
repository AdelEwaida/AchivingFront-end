import 'package:archiving_flutter_project/dialogs/error_dialgos/show_error_dialog.dart';
import 'package:archiving_flutter_project/models/db/document_models/upload_file_mode.dart';
import 'package:archiving_flutter_project/models/whatsapp_message_model.dart';
import 'package:archiving_flutter_project/service/controller/masseges_service.dart';
import 'package:archiving_flutter_project/utils/constants/colors.dart';
import 'package:archiving_flutter_project/utils/constants/styles.dart';
import 'package:archiving_flutter_project/utils/func/responsive.dart';
import 'package:archiving_flutter_project/utils/loading.dart';
import 'package:archiving_flutter_project/widget/dialog_widgets/title_dialog_widget.dart';
import 'package:archiving_flutter_project/widget/text_field_widgets/custom_text_field2_.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WhatsAppDialog extends StatefulWidget {
  String base64String;

  WhatsAppDialog({
    super.key,
    required this.base64String,
  });

  @override
  State<WhatsAppDialog> createState() => _WhatsAppDialogState();
}

class _WhatsAppDialogState extends State<WhatsAppDialog> {
  double width = 0;
  double height = 0;
  TextEditingController patientFileController = TextEditingController();
  TextEditingController creditFileController = TextEditingController();
  TextEditingController doctorNumberController = TextEditingController();

  bool isDesktop = false;
  late AppLocalizations _locale;
  MassegesService whatsappService = MassegesService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = AppLocalizations.of(context)!;
    // if (widget.patientModel.txtMobileNum != "") {
    //   patientFileController.text = widget.patientModel.txtMobileNum ?? "";
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isDesktop = Responsive.isDesktop(context);
    return AlertDialog(
      titlePadding: EdgeInsets.all(0),
      title: TitleDialogWidget(
        title: _locale.sendViaWhatsApp,
        width: isDesktop ? width * 0.2 : width * 0.8,
        height: height * 0.09,
      ),
      content: Container(
        height: height * 0.15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField2(
              width: width * 0.2,
              height: height * 0.05,
              controller: patientFileController,
              text: Text("WhatsApp Number"),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                sendAction();
              },
              style: customButtonStyle(    context,
                  Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.045),
                  14,
                  primary),
              child: Text(
                _locale.send,
                style: const TextStyle(color: whiteColor),
              ),
            ),
            SizedBox(width: width * 0.01),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: customButtonStyle(    context,
                  Size(isDesktop ? width * 0.1 : width * 0.4, height * 0.045),
                  14,
                  redColor),
              child: Text(
                _locale.cancel,
                style: const TextStyle(color: whiteColor),
              ),
            )
          ],
        ),
      ],
    );
  }

  void sendAction() async {
    openLoadinDialog(context);
    var response = await whatsappService.sendMessageMethod(
        WhatsAppMessageModel(
            file: widget.base64String,
            mobNum: patientFileController.text,
            alias: "user1",
            mobNumList: [],
            msg: ""),
        context);
    Navigator.pop(context);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(
              icon: Icons.done_all,
              errorDetails: _locale.done,
              errorTitle: _locale.sentDone,
              color: Colors.green,
              statusCode: 200);
        },
      ).then((value) {
        Navigator.pop(context);
      });
    }
  }

  void openLoadinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
