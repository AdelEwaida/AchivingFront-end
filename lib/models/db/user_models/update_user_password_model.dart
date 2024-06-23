class UpdateUserPassword {
  String? oldPassword;
  String? password;

  UpdateUserPassword({
    this.oldPassword,
    this.password,
  });

  // Method to create an UpdateUserPassword instance from a JSON object
  factory UpdateUserPassword.fromJson(Map<String, dynamic> json) {
    return UpdateUserPassword(
      oldPassword: json['oldPassword'],
      password: json['password'],
    );
  }

  // Method to convert an UpdateUserPassword instance into a JSON object
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oldPassword'] = oldPassword;
    data['password'] = password;
    return data;
  }
}
