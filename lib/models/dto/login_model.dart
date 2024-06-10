class LogInModel {
  String? username;
  String? password;
  int? force;
  LogInModel(this.username, this.password);

  LogInModel.fromJson(Map<String, dynamic> user) {
    username = user['username'].toString() == "null"
        ? ""
        : user['username'].toString();
    password = user['password'].toString() == "null"
        ? ""
        : user['password'].toString();
    force = user['force'].toString() == "null" ? 0 : user['force'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = <String, dynamic>{};

    user['username'] = username;
    user['password'] = password;
    user['force'] = force ?? 0;
    return user;
  }
}
