class SelectedAudience {
  bool areAllStaffSelected = false;
  bool oneDepartmentSelected = false;
  bool multipleDepartmentSelected = false;
  bool oneStaffSelected = false;
  bool multipleStaffSelected = false;

  List<String> selectedDepartments = [];
  List<String> selectedStaff = [];

  bool areAllStudentsSelected = false;
  bool oneClassSelected = false;
  bool multipleClassSelected = false;
  bool oneSectionSelected = false;
  bool multipleSectionSelected = false;
  bool oneStudentSelected = false;
  bool multipleStudentSelected = false;

  List<String> selectedClasses = [];
  List<String> selectedSections = [];
  List<String> selectedStudents = [];

  Set<int> checkedStaff = Set();
  Set<int> checkedStudents = Set();
}
