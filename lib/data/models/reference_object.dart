
class ReferenceObject{
  String parentName;
  String parentMobile;
  String parentType;
  String studentName;
  String appliedClass;
  String prevSchool;
  String address;
  String remark;
  String refByType;
  String refById;

  ReferenceObject({this.parentName, this.parentMobile, this.parentType,
    this.studentName, this.appliedClass, this.prevSchool, this.address,
    this.remark, this.refByType, this.refById});

  Map<String, dynamic> toJson() =>
      {
        'parent_name': parentName,
        'parent_mobile': parentMobile,
        'parent_type': parentType,
        'student_name': studentName,
        'applied_class': appliedClass,
        'prevSchool': prevSchool,
        'address': address,
        'remark': remark,
        'refByType': refByType,
        'refById': refById
      };
}