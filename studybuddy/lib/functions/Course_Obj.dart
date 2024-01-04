/// Represents a course with its basic information and a list of assignments.
class Course {
  /// The name of the course.
  String name = "";

  /// The unique identifier for the course.
  int courseID = 0;

  /// List of assignments associated with the course.
  List<Assignment> assignments = [];

  /// Constructs a [Course] with the given [name] and [courseID].
  Course(this.name, this.courseID);

  /// Returns the string representation of the course, which is its name.
  @override
  String toString() {
    return name;
  }
}

/// Represents an assignment with its basic information.
class Assignment {
  /// The name of the assignment.
  String name = "";

  /// The due date and time of the assignment.
  DateTime dueDate = DateTime(1977, 1, 1, 1, 1, 1);

  /// The maximum points achievable for the assignment.
  int maxPoints = 0;

  /// Constructs an [Assignment] with the given [name], [dueDate], and [maxPoints].
  Assignment(this.name, this.dueDate, this.maxPoints);
}