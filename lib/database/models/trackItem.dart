/// Name: String
/// Tour: Int (Tour Id)

import 'dart:convert';

TrackItem trackItemFromJson(String str) {
  final jsonData = json.decode(str);
  return TrackItem.fromMap(jsonData);
}

String trackItemToJson(TrackItem data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class TrackItem {
  int id;
  String name;
  String info;
  DateTime timestamp;
  String latlng;
  List images;
  String createdAt;
  int markerId;

  TrackItem({
    this.id,
    this.name,
    this.info,
    this.timestamp,
    this.latlng,
    this.images,
    this.createdAt,
    this.markerId,
  });

  factory TrackItem.fromMap(Map<String, dynamic> json) => new TrackItem(
    id: json["id"],
    name: json["name"],
    info: json["info"],
    timestamp: DateTime.parse(json['timestamp']),
    latlng: json['latlng'],
    images: jsonDecode(json['images']),
    createdAt: json['createdAt'],
    markerId: json['markerId'],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "info": info,
    "timestamp": timestamp.toIso8601String(),
    "latlng": latlng,
    "images": jsonEncode(images),
    "createdAt": createdAt,
    "markerId" : markerId,
  };

}