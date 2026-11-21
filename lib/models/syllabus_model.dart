class SyllabusTopic {
  final String id;
  final String name;
  final String nameGujarati;
  final List<String> keyPoints;
  final int mcqCount;
  bool isCompleted;

  SyllabusTopic({
    required this.id,
    required this.name,
    required this.nameGujarati,
    required this.keyPoints,
    required this.mcqCount,
    this.isCompleted = false,
  });
}

class SyllabusSubject {
  final String id;
  final String title;
  final String titleGujarati;
  final String iconName;
  final int totalMarksWeightage;
  final int mcqCount;
  final List<SyllabusTopic> topics;

  SyllabusSubject({
    required this.id,
    required this.title,
    required this.titleGujarati,
    required this.iconName,
    required this.totalMarksWeightage,
    required this.mcqCount,
    required this.topics,
  });

  int get completedTopicsCount =>
      topics.where((topic) => topic.isCompleted).length;

  double get progressPercentage =>
      topics.isEmpty ? 0.0 : (completedTopicsCount / topics.length);
}
