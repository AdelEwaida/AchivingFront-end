import 'dart:convert';
import 'dart:io';

import 'package:archiving_flutter_project/models/whatsapp_message_model.dart';
import 'package:archiving_flutter_project/service/handler/api_service.dart';
import 'package:archiving_flutter_project/utils/constants/api_constants.dart';

class WhatsappService {
  Future sendMessageMethod(
      WhatsAppMessageModel whatsAppMessageModel, var context) async {
    try {
      var response =
          await ApiService().postRequest(whatsAppSendPath, whatsAppMessageModel
              // api:whatsAppSendPath,
              // method: Api.POST,
              // body: whatsAppMessageModel,
              // // nUrl: Api.pdfUrl,
              // context: context
              );
      return response;
    } catch (e) {
      return null;
    }
  }
}
