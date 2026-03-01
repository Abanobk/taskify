class TimeZoneInfoModel {
  final String time;
  final String utcOffset;
  final String region;

  TimeZoneInfoModel({
    required this.time,
    required this.utcOffset,
    required this.region,
  });

  factory TimeZoneInfoModel.fromList(List<dynamic> data) {
    return TimeZoneInfoModel(
      time: data[0] as String,
      utcOffset: data[1] as String,
      region: data[2] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time,
      "utcOffset": utcOffset,
      "region": region,
    };
  }
}
