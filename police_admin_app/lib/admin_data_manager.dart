import 'dart:convert';
import 'dart:io';
import 'security_vault.dart';

class AdminDataManager {
  static final AdminDataManager _instance = AdminDataManager._internal();
  factory AdminDataManager() => _instance;
  AdminDataManager._internal() {
    _initEmptyQuestions();
  }

  // Dynamic Cryptographic Vault Credentials (ZERO plaintext in binary)
  String get supabaseUrl => SecurityVault.supabaseUrl;
  String get supabaseKey => SecurityVault.supabaseAnonKey;
  bool isConnectedToSupabase = true;
  bool isLoading = false;

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

  // Dynamic Question Bank per Test - 100% REAL from Supabase / Admin additions
  late final Map<String, List<Map<String, dynamic>>> testQuestions;

  // Real Registered Students List - 100% database driven from Supabase `profiles`
  final List<Map<String, dynamic>> students = [];

  // Real Withdrawal Requests List - 100% database driven from Supabase `withdrawals`
  final List<Map<String, dynamic>> withdrawals = [];

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

  // Generic REST GET
  Future<dynamic> restGet(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.getUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Accept', 'application/json');

      final res = await req.close();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = await res.transform(utf8.decoder).join();
        return jsonDecode(body);
      }
    } catch (_) {}
    return null;
  }

  // Generic REST POST
  Future<bool> restPost(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.postUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Prefer', 'return=minimal');

      req.write(jsonEncode(data));
      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // Generic REST PATCH
  Future<bool> restPatch(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.patchUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Prefer', 'return=minimal');

      req.write(jsonEncode(data));
      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // Generic REST DELETE
  Future<bool> restDelete(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final req = await client.deleteUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      final res = await req.close();
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // Backwards compatibility alias
  Future<void> postToSupabase(String endpoint, Map<String, dynamic> data) async {
    await restPost(endpoint, data);
  }

  /// 1. Fetch Real Students from Supabase `profiles` table
  Future<void> fetchRealStudents() async {
    final result = await restGet('profiles?select=*&order=created_at.desc');
    if (result is List) {
      students.clear();
      for (final item in result) {
        String joinedStr = 'તાજેતરમાં';
        if (item['created_at'] != null) {
          try {
            final dt = DateTime.parse(item['created_at'].toString());
            joinedStr = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {}
        }
        students.add({
          'id': item['id']?.toString() ?? '',
          'name': item['name']?.toString() ?? 'વિદ્યાર્થી',
          'email': item['email']?.toString() ?? '',
          'coins': (item['coins'] as num?)?.toInt() ?? 0,
          'referrals': (item['total_referrals'] as num?)?.toInt() ?? 0,
          'joinedDate': joinedStr,
          'isActive': true,
        });
      }
    }
  }

  /// 2. Fetch Real Withdrawals from Supabase `withdrawals` table
  Future<void> fetchRealWithdrawals() async {
    final result = await restGet('withdrawals?select=*&order=created_at.desc');
    if (result is List) {
      withdrawals.clear();
      for (final item in result) {
        final statusStr = item['status']?.toString().toLowerCase() ?? 'pending';
        final isPending = statusStr == 'pending';
        final isApproved = statusStr == 'approved';

        String dateStr = 'આજે';
        if (item['created_at'] != null) {
          try {
            final dt = DateTime.parse(item['created_at'].toString());
            dateStr = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {}
        }

        withdrawals.add({
          'id': item['id']?.toString() ?? '',
          'studentName': item['student_name']?.toString() ?? 'વિદ્યાર્થી',
          'email': item['student_email']?.toString() ?? '',
          'amount': '₹${(item['amount_inr'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}',
          'coins': (item['coins_deducted'] as num?)?.toInt() ?? 0,
          'upi': item['upi_id']?.toString() ?? '',
          'status': isApproved ? 'મંજૂર થયેલ (Paid) ✅' : (isPending ? 'પેન્ડિંગ (Pending)' : 'અસ્વીકાર (Rejected) ❌'),
          'isPending': isPending,
          'date': dateStr,
        });
      }
    }
  }

  /// 3. Fetch Real Questions from Supabase `questions` table
  Future<void> fetchRealQuestions() async {
    final result = await restGet('questions?select=*&order=created_at.asc');
    if (result is List) {
      // Clear questions for each test
      for (final key in testQuestions.keys) {
        testQuestions[key]?.clear();
      }

      for (final item in result) {
        final testId = item['test_id']?.toString() ?? 'constable_1';
        if (!testQuestions.containsKey(testId)) {
          testQuestions[testId] = [];
        }

        final opts = item['options'];
        List<String> optionsList = [];
        if (opts is List) {
          optionsList = opts.map((e) => e.toString()).toList();
        }

        int correctIndex = (item['correct_option_index'] as num?)?.toInt() ?? 0;
        String correctLetter = 'A';
        if (correctIndex == 1) correctLetter = 'B';
        if (correctIndex == 2) correctLetter = 'C';
        if (correctIndex == 3) correctLetter = 'D';
        if (correctIndex == 4) correctLetter = 'E';

        testQuestions[testId]?.add({
          'id': item['id']?.toString() ?? '',
          'question': item['question_text']?.toString() ?? '',
          'optionA': optionsList.isNotEmpty ? optionsList[0] : '',
          'optionB': optionsList.length > 1 ? optionsList[1] : '',
          'optionC': optionsList.length > 2 ? optionsList[2] : '',
          'optionD': optionsList.length > 3 ? optionsList[3] : '',
          'optionE': optionsList.length > 4 ? optionsList[4] : 'પ્રયાસ કરેલ નથી',
          'correct': correctLetter,
          'subject': item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
          'explanation': item['explanation']?.toString() ?? '',
        });
      }
    }
  }

  /// 4. Fetch Dynamic Social Media & Website Settings
  Future<void> fetchSocialLinks() async {
    final result = await restGet('app_settings?key=eq.social_links&select=value');
    if (result is List && result.isNotEmpty) {
      final val = result.first['value'];
      if (val is Map) {
        socialLinks['website'] = val['website']?.toString() ?? socialLinks['website']!;
        socialLinks['whatsapp'] = val['whatsapp']?.toString() ?? socialLinks['whatsapp']!;
        socialLinks['telegram'] = val['telegram']?.toString() ?? socialLinks['telegram']!;
        socialLinks['youtube'] = val['youtube']?.toString() ?? socialLinks['youtube']!;
        socialLinks['instagram'] = val['instagram']?.toString() ?? socialLinks['instagram']!;
      }
    }
  }

  /// 5. Load All Data from Supabase
  Future<void> loadAllData() async {
    isLoading = true;
    try {
      await Future.wait([
        fetchRealStudents(),
        fetchRealWithdrawals(),
        fetchRealQuestions(),
        fetchSocialLinks(),
      ]);
    } catch (_) {}
    isLoading = false;
  }

  /// Add question and persist to Supabase
  void addQuestion(String testId, Map<String, dynamic> question) {
    testQuestions[testId]?.add(question);

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

    restPost('questions', {
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
      final existing = testQuestions[testId]![index];
      testQuestions[testId]![index] = question;

      final questionId = existing['id']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
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

        restPatch('questions?id=eq.$questionId', {
          'subject': question['subject'] ?? 'સામાન્ય જ્ઞાન',
          'question_text': question['question'] ?? '',
          'options': optionsList,
          'correct_option_index': correctIdx,
          'explanation': question['explanation'] ?? '',
        });
      }
    }
  }

  void deleteQuestion(String testId, int index) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      final q = testQuestions[testId]!.removeAt(index);
      final questionId = q['id']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
        restDelete('questions?id=eq.$questionId');
      }
    }
  }

  void updateStudentCoins(int index, int delta) {
    if (index >= 0 && index < students.length) {
      final student = students[index];
      final newCoins = ((student['coins'] as int? ?? 0) + delta).clamp(0, 99999);
      student['coins'] = newCoins;

      final email = student['email']?.toString();
      if (email != null && email.isNotEmpty) {
        restPatch('profiles?email=eq.$email', {'coins': newCoins});
      }
    }
  }

  Future<void> updateWithdrawalStatus(String id, String newStatus) async {
    final idx = withdrawals.indexWhere((w) => w['id'] == id);
    if (idx != -1) {
      withdrawals[idx]['status'] = newStatus == 'approved' ? 'મંજૂર થયેલ (Paid) ✅' : 'અસ્વીકાર (Rejected) ❌';
      withdrawals[idx]['isPending'] = false;
    }
    await restPatch('withdrawals?id=eq.$id', {'status': newStatus});
  }

  void toggleTestFree(int index) {
    if (index >= 0 && index < tests.length) {
      final current = tests[index]['isFree'] as bool? ?? false;
      tests[index]['isFree'] = !current;
      final testId = tests[index]['id']?.toString();
      if (testId != null) {
        restPatch('mock_tests?id=eq.$testId', {'is_free': !current});
      }
    }
  }

  Future<bool> saveSocialLinks(Map<String, String> newLinks) async {
    socialLinks = Map.from(newLinks);
    await restPost('app_settings', {
      'key': 'social_links',
      'value': socialLinks,
      'updated_at': DateTime.now().toIso8601String(),
    });
    return true;
  }

  Future<bool> broadcastNotification(String title, String message, String type) async {
    await restPost('notifications', {
      'title': title,
      'message': message,
      'type': type,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
