class ModelSyllabus {
  String title;
  String mediaPath;
  String mediaType;
  String timestamp;

  ModelSyllabus(this.title, this.mediaPath, this.mediaType, this.timestamp);

  factory ModelSyllabus.fromJson(Map<String, dynamic> parsedJson) {
    return ModelSyllabus(
        parsedJson['title'],
        parsedJson['media_path'],
        parsedJson['media_type'],
        parsedJson['created_timestamp']);
  }
}
