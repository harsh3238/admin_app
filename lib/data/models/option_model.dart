import 'dart:convert';

class Option {
  String option;
  String image;

  Option(this.option,this.image);


  set mOption(String value) {
    option = value;
  }

  set mImage(String value) {
    image = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'option': this.option,
      'image': this.image,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return new Option(
      map['option'] as String,
      map['image'] as String
    );
  }


  String convertToJson(List<Option> options) {
    List<Map<String, dynamic>> jsonData =
    options.map((option) => option.toMap()).toList();
    return jsonEncode(jsonData);
  }

}