import 'dart:convert';
import 'dart:io';

class AdminDataManager {
  static final AdminDataManager _instance = AdminDataManager._internal();
  factory AdminDataManager() => _instance;
  AdminDataManager._internal() {
    _initEmptyQuestions();
  }

  // Supabase Configuration
  String supabaseUrl = 'https://sbujnpiaxyjtjgsszpdn.supabase.co';
  String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidWpucGlheHlqdGpnc3N6cGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDk3MDQsImV4cCI6MjExMDgyNTcwNH0.crnzNtr5Kf7XM62E9CwjFua4kBzJ8U5e1UIKG6qNs0I';
  bool isConnectedToSupabase = true;

  // Active Mock Tests list
  final List<Map<String, dynamic>> tests = [
    {'id': 'constable_1', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 01', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_2', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 02', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_3', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 03', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_4', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 04', 'isFree': false, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_5', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 05', 'isFree': false, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_1', 'exam': 'PSI / ASI', 'title': 'PSI પ્રિલિમિનરી ટેસ્ટ 01', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_2', 'exam': 'PSI / ASI', 'title': 'PSI કાયદો & બંધારણ ટેસ્ટ 02', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_3', 'exam': 'PSI / ASI', 'title': 'PSI ભાષાકીય ટેસ્ટ 03', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_4', 'exam': 'PSI / ASI', 'title': 'PSI પ્રીમિયમ ટેસ્ટ 04', 'isFree': false, 'totalMcqs': 200, 'duration': 180},
  ];

  // Dynamic Question Bank per Test - ZERO HARDCODED QUESTIONS!
  // All questions are added by Admin or fetched from Supabase
  late final Map<String, List<Map<String, dynamic>>> testQuestions;

  // Dynamic Social & Website links
  Map<String, String> socialLinks = {
    'website': 'https://gujaratpoliceprep.in',
    'whatsapp': 'https://chat.whatsapp.com/KhakhiPrep2026',
    'telegram': 'https://t.me/GujaratPolicePrep',
    'youtube': 'https://youtube.com/@GujaratPolicePrep',
    'instagram': 'https://instagram.com/gujaratpoliceprep',
  };

  void _initEmptyQuestions() {
    testQuestions = {
      'constable_1': [],
      'constable_2': [],
      'constable_3': [],
      'constable_4': [],
      'constable_5': [],
      'psi_1': [],
      'psi_2': [],
      'psi_3': [],
      'psi_4': [],
    };
  }

  // Registered Students List
  final List<Map<String, dynamic>> students = [
    {
      'id': 'std_1',
      'name': 'રમેશ ચૌધરી',
      'email': 'ramesh.chaudhary@gmail.com',
      'coins': 350,
      'referrals': 5,
      'joinedDate': '18 Nov 2026',
      'isActive': true,
    },
    {
      'id': 'std_2',
      'name': 'ભાવિક પટેલ',
      'email': 'bhavik.patel@gmail.com',
      'coins': 200,
      'referrals': 3,
      'joinedDate': '19 Nov 2026',
      'isActive': true,
    },
    {
      'id': 'std_3',
      'name': 'પૂજા ઠાકોર',
      'email': 'pooja.thakor@gmail.com',
      'coins': 620,
      'referrals': 11,
      'joinedDate': '15 Nov 2026',
      'isActive': true,
    },
  ];

  Future<void> postToSupabase(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final req = await client.postUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Prefer', 'return=minimal');
      req.write(jsonEncode(data));
      await req.close();
    } catch (_) {}
  }

  void addQuestion(String testId, Map<String, dynamic> question) {
    testQuestions[testId]?.add(question);

    // Sync to Supabase `questions` table
    final optionsList = [
      question['optionA'] ?? '',
      question['optionB'] ?? '',
      question['optionC'] ?? '',
      question['optionD'] ?? '',
      question['optionE'] ?? 'પ્રયાસ કરેલ નથી',
    ];
    int correctIdx = 0;
    if (question['correct'] == 'B') correctIdx = 1;
    if (question['correct'] == 'C') correctIdx = 2;
    if (question['correct'] == 'D') correctIdx = 3;
    if (question['correct'] == 'E') correctIdx = 4;

    postToSupabase('questions', {
      'test_id': testId,
      'exam_id': testId.startsWith('psi') ? 'psi' : 'constable',
      'subject': question['subject'] ?? 'સામાન્ય જ્ઞાન',
      'question_text': question['question'] ?? '',
      'options': optionsList,
      'correct_option_index': correctIdx,
      'explanation': question['explanation'] ?? '',
    });
  }

  void editQuestion(String testId, int index, Map<String, dynamic> question) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      testQuestions[testId]![index] = question;
    }
  }

  void deleteQuestion(String testId, int index) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      testQuestions[testId]!.removeAt(index);
    }
  }

  void updateStudentCoins(int index, int delta) {
    if (index >= 0 && index < students.length) {
      students[index]['coins'] = ((students[index]['coins'] as int? ?? 0) + delta).clamp(0, 99999);
    }
  }

  void toggleTestFree(int index) {
    if (index >= 0 && index < tests.length) {
      tests[index]['isFree'] = !(tests[index]['isFree'] as bool? ?? false);
    }
  }

  Future<bool> saveSocialLinks(Map<String, String> newLinks) async {
    socialLinks = Map.from(newLinks);
    await postToSupabase('app_settings', {
      'key': 'social_links',
      'value': socialLinks,
      'updated_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  Future<bool> broadcastNotification(String title, String message, String type) async {
    await postToSupabase('notifications', {
      'title': title,
      'message': message,
      'type': type,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
