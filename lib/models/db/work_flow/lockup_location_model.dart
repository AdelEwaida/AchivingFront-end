class LockupLocationModel {
  final String? key;
  final String? lockupCode;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LockupLocationModel({
    this.key,
    this.lockupCode,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory LockupLocationModel.fromJson(Map<String, dynamic> json) {
    return LockupLocationModel(
      key: json['key'] as String?,
      lockupCode: json['lockupCode'] as String?,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Body for INSERT — only lockupCode + name
  Map<String, dynamic> toInsertJson() => {
        'lockupCode': lockupCode ?? '',
        'name': name ?? '',
      };

  /// Body for UPDATE — only name
  Map<String, dynamic> toUpdateJson() => {
        'name': name ?? '',
      };

  LockupLocationModel copyWith({
    String? key,
    String? lockupCode,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LockupLocationModel(
      key: key ?? this.key,
      lockupCode: lockupCode ?? this.lockupCode,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    final nameVal = (name ?? '').trim();
    final codeVal = (lockupCode ?? '').trim();

    if (nameVal.isEmpty) return codeVal;
    return '$nameVal ($codeVal)';
  }
}
