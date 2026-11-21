import 'package:flutter/material.dart';
import '../data/syllabus_data.dart';
import '../models/exam_type.dart';
import '../models/syllabus_model.dart';

class SyllabusScreen extends StatefulWidget {
  final ExamType? examType;
  final List<SyllabusSubject>? subjects;
  final String? initialSubjectFilter;

  const SyllabusScreen({
    super.key,
    this.examType,
    this.subjects,
    this.initialSubjectFilter,
  });

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  late ExamType _selectedExam;
  late List<SyllabusSubject> _currentSubjects;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedExam = widget.examType ?? ExamType.constable;
    _currentSubjects = widget.subjects ?? SyllabusData.getSyllabus(_selectedExam);
  }

  void _onExamChanged(ExamType newExam) {
    setState(() {
      _selectedExam = newExam;
      _currentSubjects = SyllabusData.getSyllabus(newExam);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _currentSubjects.where((subject) {
      if (widget.initialSubjectFilter != null) {
        if (!subject.id.contains(widget.initialSubjectFilter!)) {
          return false;
        }
      }
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final matchSubject = subject.title.toLowerCase().contains(query) ||
          subject.titleGujarati.toLowerCase().contains(query);
      final matchTopics = subject.topics.any((t) =>
          t.name.toLowerCase().contains(query) ||
          t.nameGujarati.toLowerCase().contains(query));
      return matchSubject || matchTopics;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'સત્તાવાર અભ્યાસક્રમ (Syllabus)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              _selectedExam.badgeText,
              style: const TextStyle(fontSize: 11, color: Color(0xFFFFC107)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Exam Switcher Selector (Constable vs PSI)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectorTab(
                    title: 'કોન્સ્ટેબલ (LRD)',
                    exam: ExamType.constable,
                    isSelected: _selectedExam == ExamType.constable,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSelectorTab(
                    title: 'PSI / ASI',
                    exam: ExamType.psi,
                    isSelected: _selectedExam == ExamType.psi,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ટોપિક કે વિષય શોધો (દા.ત. બંધારણ, IPC, ભૂગોળ)...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D253F)),
                filled: true,
                fillColor: const Color(0xFFF0F4F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Subject List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSubjects.length,
              itemBuilder: (context, index) {
                final subject = filteredSubjects[index];
                return _buildSubjectCard(subject);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTab({
    required String title,
    required ExamType exam,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onExamChanged(exam),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D253F) : const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(SyllabusSubject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF0D253F).withOpacity(0.08),
          child: const Icon(Icons.menu_book, color: Color(0xFF0D253F)),
        ),
        title: Text(
          subject.titleGujarati,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF0D253F),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${subject.title} • ભારાંક: ${subject.totalMarksWeightage} ગુણ',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: subject.progressPercentage,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${subject.completedTopicsCount}/${subject.topics.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: subject.topics.map((topic) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
            ),
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF2E7D32),
              title: Text(
                topic.nameGujarati,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration:
                      topic.isCompleted ? TextDecoration.lineThrough : null,
                  color: topic.isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (topic.keyPoints.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: topic.keyPoints.map((point) {
                        return Chip(
                          label: Text(
                            point,
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: const Color(0xFFE8F5E9),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
              value: topic.isCompleted,
              onChanged: (bool? newVal) {
                setState(() {
                  topic.isCompleted = newVal ?? false;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
