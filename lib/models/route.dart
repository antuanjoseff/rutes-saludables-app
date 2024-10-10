// To parse this JSON data, do
//
//     final route = routeFromJson(jsonString);

import 'dart:convert';

Route routeFromJson(String str) => Route.fromJson(json.decode(str));

String routeToJson(Route data) => json.encode(data.toJson());

class Route {
  String campus;
  String title;
  double distance;
  int duration;
  Path path;
  Points points;

  Route({
    required this.campus,
    required this.title,
    required this.distance,
    required this.duration,
    required this.path,
    required this.points,
  });

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        campus: json["campus"],
        title: json["title"],
        distance: json['distance'],
        duration: json['duration'],
        path: Path.fromJson(json["path"]),
        points: Points.fromJson(json["points"]),
      );

  Map<String, dynamic> toJson() => {
        "campus": campus,
        "title": title,
        "path": path.toJson(),
        "points": points.toJson(),
      };
}

class Path {
  String type;
  List<List<List<double>>> coordinates;

  Path({
    required this.type,
    required this.coordinates,
  });

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        type: json["type"],
        coordinates: List<List<List<double>>>.from(json["coordinates"].map(
            (x) => List<List<double>>.from(
                x.map((x) => List<double>.from(x.map((x) => x?.toDouble())))))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) =>
            List<dynamic>.from(
                x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
      };
}

class Points {
  String type;
  List<Feature> features;

  Points({
    required this.type,
    required this.features,
  });

  factory Points.fromJson(Map<String, dynamic> json) => Points(
        type: json["type"],
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
      };
}

class Feature {
  String type;
  Geometry geometry;
  Properties properties;

  Feature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        geometry: Geometry.fromJson(json["geometry"]),
        properties: Properties.fromJson(json["properties"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
      };
}

class Geometry {
  String type;
  List<double> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}

class Properties {
  int id;
  String title;
  String description;

  Properties({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        id: json["id"],
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
      };
}
