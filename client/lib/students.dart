import 'package:sats/select_loc.dart';

class Students {
  String image;
  String matric;
  String name;

  Students({this.image, this.matric, this.name});

  factory Students.fromJson(Map<String, dynamic> json) {
    return Students(
      image: json['image'],
      matric: json['matric'],
      name: json['name'],
    );
  }
}
