import 'dart:convert';

///
TrackCoord trackCoordFromJson(String str) {
  final jsonData = json.decode(str);
  return TrackCoord.fromMap(jsonData);
}

String trackCoordToJson(TrackCoord data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}


class TrackCoord {
  int id;
  double latitude;
  double longitude;
  double altitude;
  DateTime timestamp;
  double accuracy;
  double heading;
  double speed;
  double speedAccuracy;
  int item;

  TrackCoord({
    this.id,
    this.latitude,
    this.longitude,
    this.altitude,
    this.timestamp,
    this.accuracy,
    this.heading,
    this.speed,
    this.speedAccuracy,
    this.item,
  });

  factory TrackCoord.fromMap(Map<String, dynamic> json) => TrackCoord(
    id: json["id"],
    latitude: json['latitude'],
    longitude: json['longitude'],
    altitude: json['altitude'],
    timestamp: DateTime.parse(json['timestamp']),
    accuracy: json['accuracy'],
    heading: json['heading'],
    speed: json['speed'],
    speedAccuracy: json['speedAccuracy'],
    item: json['item'],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "latitude": latitude,
    "longitude": longitude,
    "altitude": altitude,
    "timestamp": timestamp.toIso8601String(),
    "accuracy": accuracy,
    "heading": heading,
    "speed": speed,
    "speedAccuracy": speedAccuracy,
    "item": item,
  };

}
