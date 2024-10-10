import 'package:rutes_saludables/models/route.dart';
import 'coordinates.dart';

Feature fa = Feature(
    type: "Feature",
    geometry: Geometry(type: "Point", coordinates: [2.827357, 41.985692]),
    properties: Properties(
        id: 18, title: "Exercici 1", description: "bla, bla, bla..."));

Feature fb = Feature(
    type: "Feature",
    geometry: Geometry(type: "Point", coordinates: [2.827906, 41.984199]),
    properties: Properties(
        id: 18, title: "Exercici 1", description: "más bla, bla, bla..."));

Points pts = Points(type: "FeatureCollection", features: [fa, fb]);

List<Route> routes = [
  Route(
      campus: "Campus Barri Vell",
      title: "Curt",
      distance: 1,
      duration: 25,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus Barri Vell",
      title: "Curt",
      distance: 1,
      duration: 25,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus Montilivi",
      title: "Curt",
      distance: 1.5,
      duration: 30,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus centre",
      title: "Curt",
      distance: 1.2,
      duration: 30,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus Barri Vell",
      title: "Llarg",
      distance: 2.1,
      duration: 35,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus Montilivi",
      title: "Llarg",
      distance: 2.6,
      duration: 42,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
  Route(
      campus: "Campus centre",
      title: "Llarg",
      distance: 5.1,
      duration: 70,
      path: Path(type: "MultiLinestring", coordinates: coordinates),
      points: pts),
];
