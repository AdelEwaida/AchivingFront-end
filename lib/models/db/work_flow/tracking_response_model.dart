import 'tracking_info_model.dart';
import 'tracking_step_info_model.dart';

class TrackingResponseModel {
  TrackingInfoModel? tracking;
  List<TrackingStepInfoModel>? steps;

  TrackingResponseModel({
    this.tracking,
    this.steps,
  });

  factory TrackingResponseModel.fromJson(Map<String, dynamic> json) {
    return TrackingResponseModel(
      tracking: json['tracking'] != null
          ? TrackingInfoModel.fromJson(json['tracking'])
          : null,
      steps: json['steps'] != null
          ? (json['steps'] as List)
              .map((s) => TrackingStepInfoModel.fromJson(s))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking': tracking?.toJson(),
      'steps': steps?.map((s) => s.toJson()).toList(),
    };
  }

  /// Parse the root list directly
  static List<TrackingResponseModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => TrackingResponseModel.fromJson(item))
        .toList();
  }
}
