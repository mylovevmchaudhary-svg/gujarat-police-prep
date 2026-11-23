import '../data/curated_question_bank.dart';

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
    this.mcqCount = 0,
    this.isCompleted = false,
  });
}

class SyllabusSubject {
  final String id;
  final String title;
  final String titleGujarati;
  final String iconName;
  final int totalMarksWeightage;
  final int _mcqCount;
  final List<SyllabusTopic> topics;

  SyllabusSubject({
    required this.id,
    required this.title,
    required this.titleGujarati,
    required this.iconName,
    required this.totalMarksWeightage,
    int mcqCount = 0,
    required this.topics,
  }) : _mcqCount = mcqCount;

  /// Dynamic MCQ count strictly calculated from actual database questions
  int get mcqCount {
    final realCount = CuratedQuestionBank.getQuestionCountForSubject(titleGujarati);
    return realCount;
  }

  int get completedTopicsCount =>
      topics.where((topic) => topic.isCompleted).length;

  double get progressPercentage =>
      topics.isEmpty ? 0.0 : (completedTopicsCount / topics.length);
}
