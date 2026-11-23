import '../models/quiz_model.dart';
import '../services/supabase_service.dart';

class CuratedQuestionBank {
  // Dynamic question repository loaded from Supabase or Admin Console
  // ZERO hardcoded questions - 100% database driven as requested!
  static final Map<String, List<Question>> _cachedQuestions = {};

  // Dynamic Mock Tests cache grouped by Exam ID (Constable / PSI)
  static final Map<String, List<MockTest>> _dynamicTestsByExam = {};

  /// Set questions for a specific test
  static void setQuestions(String testId, List<Question> questions) {
    _cachedQuestions[testId] = List.from(questions);
  }

  /// Add a single question to a test
  static void addQuestion(String testId, Question question) {
    _cachedQuestions.putIfAbsent(testId, () => []).add(question);
  }

  /// Delete a question from a test
  static void removeQuestion(String testId, String questionId) {
    _cachedQuestions[testId]?.removeWhere((q) => q.id == questionId);
  }

  /// Load questions from Supabase for a test (Full Join + Pagination)
  static Future<List<Question>> loadQuestionsFromSupabase(String testId) async {
    final questions = await SupabaseService().fetchAllQuestionsForTest(testId);
    if (questions.isNotEmpty) {
      _cachedQuestions[testId] = questions;
      // Update in test list as well
      for (final list in _dynamicTestsByExam.values) {
        for (final t in list) {
          if (t.id == testId) {
            t.questions = questions;
          }
        }
      }
    }
    return _cachedQuestions[testId] ?? [];
  }

  /// Load all dynamic mock tests from Supabase `mock_tests` table (1 to 100+ tests!)
  static Future<List<MockTest>> loadAllTestsFromSupabase({String? examId}) async {
    final liveTests = await SupabaseService().fetchMockTests(examId: examId);
    if (liveTests.isNotEmpty) {
      for (final t in liveTests) {
        if (_cachedQuestions.containsKey(t.id)) {
          t.questions = _cachedQuestions[t.id]!;
        }
      }

      if (examId != null && examId.isNotEmpty) {
        _dynamicTestsByExam[examId] = liveTests;
      } else {
        _dynamicTestsByExam['constable'] =
            liveTests.where((t) => t.examId == 'constable').toList();
        _dynamicTestsByExam['psi'] =
            liveTests.where((t) => t.examId == 'psi').toList();
      }
      return liveTests;
    }
    return getCuratedTests(examId ?? 'constable');
  }

  /// Count questions available for a given subject keyword
  static int getQuestionCountForSubject(String subjectKeyword) {
    int count = 0;
    for (final list in _cachedQuestions.values) {
      for (final q in list) {
        if (q.subject.toLowerCase().contains(subjectKeyword.toLowerCase())) {
          count++;
        }
      }
    }
    return count;
  }

  /// Get mock tests for Constable or PSI - returns dynamic tests from Supabase!
  static List<MockTest> getCuratedTests(String examId) {
    if (_dynamicTestsByExam.containsKey(examId) &&
        _dynamicTestsByExam[examId]!.isNotEmpty) {
      return _dynamicTestsByExam[examId]!;
    }
    if (examId == 'psi') {
      return _getPsiTests();
    } else {
      return _getConstableTests();
    }
  }

  static List<MockTest> _getConstableTests() {
    return [
      MockTest(
        id: 'constable_1',
        title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 01',
        description: '🌟 મફત મોક ટેસ્ટ (નવા નિયમો મુજબ - 200 ગુણ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['constable_1'] ?? [],
      ),
      MockTest(
        id: 'constable_2',
        title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 02',
        description: '🌟 મફત મોક ટેસ્ટ (ઇતિહાસ, ભૂગોળ, કાયદો વિશેષ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['constable_2'] ?? [],
      ),
      MockTest(
        id: 'constable_3',
        title: 'કોન્સ્ટેબલ સંપૂર્ણ મોક ટેસ્ટ 03',
        description: '🌟 મફત મોક ટેસ્ટ (રીઝનિંગ, ગણિત અને બંધારણ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['constable_3'] ?? [],
      ),
      MockTest(
        id: 'constable_4',
        title: 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 04',
        description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)',
        category: 'Premium Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['constable_4'] ?? [],
      ),
      MockTest(
        id: 'constable_5',
        title: 'કોન્સ્ટેબલ પ્રીમિયમ મોક ટેસ્ટ 05',
        description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)',
        category: 'Premium Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['constable_5'] ?? [],
      ),
    ];
  }

  static List<MockTest> _getPsiTests() {
    return [
      MockTest(
        id: 'psi_1',
        title: 'PSI પ્રિલિમિનરી મોક ટેસ્ટ 01',
        description: '🌟 મફત મોક ટેસ્ટ (જનરલ સ્ટડીઝ, રીઝનિંગ, બંધારણ - 200 ગુણ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['psi_1'] ?? [],
      ),
      MockTest(
        id: 'psi_2',
        title: 'PSI કાયદો & બંધારણ મોક ટેસ્ટ 02',
        description: '🌟 મફત મોક ટેસ્ટ (IPC, CrPC, પુરાવા અને બંધારણ વિશેષ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['psi_2'] ?? [],
      ),
      MockTest(
        id: 'psi_3',
        title: 'PSI ભાષાકીય & વ્યાકરણ મોક ટેસ્ટ 03',
        description: '🌟 મફત મોક ટેસ્ટ (ગુજરાતી ભાષા & વ્યાકરણ વિશેષ)',
        category: 'Free Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['psi_3'] ?? [],
      ),
      MockTest(
        id: 'psi_4',
        title: 'PSI પ્રીમિયમ સંપૂર્ણ મોક ટેસ્ટ 04',
        description: '🔒 પ્રીમિયમ ટેસ્ટ (વિડિઓ એડ અથવા 10 કોઈન્સથી અનલોક)',
        category: 'Premium Mock',
        durationMinutes: 180,
        positiveMarksPerQuestion: 1.0,
        negativeMarksPerQuestion: 0.25,
        questions: _cachedQuestions['psi_4'] ?? [],
      ),
    ];
  }
}
