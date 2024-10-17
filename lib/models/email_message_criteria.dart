class SendingEmailCirteria {
  String? body;
  String? subject;
  String? encodedFileContent;
  String? recipient;
  String? fileName;

  SendingEmailCirteria({
    this.body,
    this.subject,
    this.encodedFileContent,
    this.recipient,
    this.fileName,
  });

  factory SendingEmailCirteria.fromJson(Map<String, dynamic> json) {
    return SendingEmailCirteria(
      body: json['body'],
      subject: json['subject'],
      encodedFileContent: json['encodedFileContent'],
      recipient: json['recipient'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['recipient'] = recipient;
    data['body'] = body;
    data['subject'] = subject;
    data['encodedFileContent'] = encodedFileContent;
    data['fileName'] = fileName;
    return data;
  }
}