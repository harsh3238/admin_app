class ModelHomework {
  int id;
  String assignmentTitle;
  String subjectName;
  String assignmentType;
  String classSection;
  String content;
  int attachmentCount;
  String startDate;
  String submissionDate;
  String timestampCreated;
  String givenBy;
  String maxMarks;
  String givenByPhoto;

  ModelHomework(
      this.id,
      this.assignmentTitle,
      this.subjectName,
      this.assignmentType,
      this.classSection,
      this.content,
      this.attachmentCount,
      this.startDate,
      this.submissionDate,
      this.timestampCreated,
      this.givenBy,
      this.maxMarks,
      this.givenByPhoto);

  factory ModelHomework.fromJson(Map<String, dynamic> item) {
    return ModelHomework(
        int.parse(item['id']),
        item['assignment_title'],
        item['subject_name'],
        item['assignment_type'],
        item['class_section'],
        item['content'],
        int.parse(item['attachment_count']),
        item['start_date'],
        item['submission_date'],
        item['timestamp_created'],
        item['given_by'],
        item['max_marks'],
        item['given_by_photo'] != null ? item['given_by_photo'] : "");
  }
}
