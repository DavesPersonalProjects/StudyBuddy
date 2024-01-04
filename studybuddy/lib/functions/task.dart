class Task {
  int? id;
  String? title;
  bool? isDone;
  String due = "";

  Task({this.id, required this.title, this.isDone = false, this.due = ""});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone! ? 1 : 0,
      'due' : due
    };
  }

  Task.fromMap(Map map) {
    id = map['id'];
    title = map['title'];
    isDone = (map['isDone']==1) ? true : false;
    due = map['due'];
  }
}