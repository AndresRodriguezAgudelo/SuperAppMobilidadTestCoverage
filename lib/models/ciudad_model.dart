class Ciudad {
  final int id;
  final String cityName;

  Ciudad({
    required this.id,
    required this.cityName,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      id: json['id'] as int,
      cityName: json['cityName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityName': cityName,
    };
  }
}
