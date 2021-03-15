class TheClass {
  int classId;
  String className;
  String sortOrder;

  TheClass(this.classId, this.className, this.sortOrder);

  factory TheClass.fromJson(Map<String, dynamic> parsedJson) {
    return TheClass(int.parse(parsedJson['id']), parsedJson['class_name'],
        parsedJson['class_order']);
  }
}
