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

  // Active Mock Tests list - 100% DYNAMIC from Supabase `mock_tests` table!
  final List<Map<String, dynamic>> tests = [];

  // Dynamic Question Bank per Test - 100% REAL from Supabase / Admin additions
  final Map<String, List<Map<String, dynamic>>> testQuestions = {};

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
    testQuestions['constable_1'] = [];
  }

  // Generic REST GET with error logging
  Future<dynamic> restGet(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req = await client.getUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Accept', 'application/json');

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body);
      } else {
        print('[AdminDataManager] GET $endpoint failed [Status ${res.statusCode}]: $body');
      }
    } catch (e) {
      print('[AdminDataManager] GET error on $endpoint: $e');
    }
    return null;
  }

  // Generic REST POST with error logging
  Future<bool> restPost(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req = await client.postUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Prefer', 'return=representation');

      req.write(jsonEncode(data));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final success = res.statusCode >= 200 && res.statusCode < 300;
      if (!success) {
        print('[AdminDataManager] POST $endpoint failed [Status ${res.statusCode}]: $body');
      }
      return success;
    } catch (e) {
      print('[AdminDataManager] POST error on $endpoint: $e');
      return false;
    }
  }

  // Generic REST PATCH with error logging
  Future<bool> restPatch(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req = await client.patchUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      req.headers.set('Content-Type', 'application/json');
      req.headers.set('Prefer', 'return=minimal');

      req.write(jsonEncode(data));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      final success = res.statusCode >= 200 && res.statusCode < 300;
      if (!success) {
        print('[AdminDataManager] PATCH $endpoint failed [Status ${res.statusCode}]: $body');
      }
      return success;
    } catch (e) {
      print('[AdminDataManager] PATCH error on $endpoint: $e');
      return false;
    }
  }

  // Generic REST DELETE with error logging
  Future<bool> restDelete(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final req = await client.deleteUrl(uri);
      req.headers.set('apikey', supabaseKey);
      req.headers.set('Authorization', 'Bearer $supabaseKey');
      final res = await req.close();
      final success = res.statusCode >= 200 && res.statusCode < 300;
      if (!success) {
        final body = await res.transform(utf8.decoder).join();
        print('[AdminDataManager] DELETE $endpoint failed [Status ${res.statusCode}]: $body');
      }
      return success;
    } catch (e) {
      print('[AdminDataManager] DELETE error on $endpoint: $e');
      return false;
    }
  }

  /// 1. Fetch Real Mock Tests from Supabase (All 9 tests dynamically, 0 hardcoded fallback)
  Future<void> fetchRealMockTests() async {
    final result = await restGet('mock_tests?select=*,mock_test_questions(count)&order=id.asc');
    if (result is List && result.isNotEmpty) {
      tests.clear();
      for (final item in result) {
        final examId = item['exam_id']?.toString() ?? 'constable';
        final testId = item['id']?.toString() ?? '';
        int mcqCount = 0;
        final mtq = item['mock_test_questions'];
        if (mtq is List && mtq.isNotEmpty) {
          mcqCount = (mtq.first['count'] as num?)?.toInt() ?? 0;
        }

        tests.add({
          'id': testId,
          'exam': examId == 'psi' ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
          'exam_id': examId,
          'title': item['title']?.toString() ?? 'મોક ટેસ્ટ',
          'description': item['description']?.toString() ?? '',
          'isFree': item['is_free'] == true,
          'totalMcqs': mcqCount,
          'duration': (item['duration_minutes'] as num?)?.toInt() ?? 180,
        });

        if (!testQuestions.containsKey(testId)) {
          testQuestions[testId] = [];
        }
      }
    }
  }

  /// 2. Fetch Real Students from Supabase `profiles` table
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
          'phone': item['phone']?.toString() ?? item['mobile']?.toString() ?? '',
          'coins': (item['coins'] as num?)?.toInt() ?? 0,
          'referrals': (item['total_referrals'] as num?)?.toInt() ?? 0,
          'referralCode': item['my_referral_code']?.toString() ?? '',
          'joinedDate': joinedStr,
          'isActive': true,
        });
      }
    }
  }

  /// 3. Fetch Real Withdrawals from Supabase `withdrawals` table
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

  /// 4. Fetch Real Questions from Supabase (`mock_test_questions` JOIN & `questions`)
  /// Correctly handles 200, 500, 1000, 10,000+ MCQs with pagination!
  Future<void> fetchRealQuestions() async {
    // Clear question bank
    for (final key in testQuestions.keys) {
      testQuestions[key]?.clear();
    }

    // A. Fetch via `mock_test_questions` join with `questions`
    int offset = 0;
    const int batchLimit = 500;
    bool hasMore = true;

    while (hasMore) {
      final batch = await restGet(
          'mock_test_questions?select=test_id,position,questions(*)&order=position.asc&limit=$batchLimit&offset=$offset');
      if (batch is List && batch.isNotEmpty) {
        for (final row in batch) {
          final testId = row['test_id']?.toString() ?? 'constable_1';
          final q = row['questions'];
          if (q is Map) {
            _addQuestionToTestMap(testId, Map<String, dynamic>.from(q));
          }
        }
        if (batch.length < batchLimit) {
          hasMore = false;
        } else {
          offset += batchLimit;
        }
      } else {
        hasMore = false;
      }
    }

    // B. Also fetch from `questions` table for any questions with direct `test_id`
    offset = 0;
    hasMore = true;
    while (hasMore) {
      final batch = await restGet(
          'questions?select=*&order=created_at.asc&limit=$batchLimit&offset=$offset');
      if (batch is List && batch.isNotEmpty) {
        for (final item in batch) {
          if (item is Map) {
            final testId = item['test_id']?.toString();
            if (testId != null && testId.isNotEmpty) {
              _addQuestionToTestMap(testId, Map<String, dynamic>.from(item));
            }
          }
        }
        if (batch.length < batchLimit) {
          hasMore = false;
        } else {
          offset += batchLimit;
        }
      } else {
        hasMore = false;
      }
    }

    // Update totalMcqs for all tests based on loaded testQuestions
    for (final t in tests) {
      final tid = t['id']?.toString();
      if (tid != null && testQuestions.containsKey(tid)) {
        t['totalMcqs'] = testQuestions[tid]!.length;
      }
    }
  }

  void _addQuestionToTestMap(String testId, Map<String, dynamic> item) {
    if (!testQuestions.containsKey(testId)) {
      testQuestions[testId] = [];
    }

    final questionId = item['id']?.toString() ?? '';
    // Avoid duplicates
    if (testQuestions[testId]!.any((q) => q['id'] == questionId)) {
      return;
    }

    final opts = item['options'];
    List<String> optionsList = [];
    if (opts is List) {
      optionsList = opts.map((e) => e.toString()).toList();
    }

    int correctIndex = 0;
    final rawCorrect = item['correct_option_index'];
    if (rawCorrect is num) {
      correctIndex = rawCorrect.toInt().clamp(0, 4);
    } else if (rawCorrect is String) {
      final s = rawCorrect.trim().toUpperCase();
      if (s == 'B' || s == '1') correctIndex = 1;
      if (s == 'C' || s == '2') correctIndex = 2;
      if (s == 'D' || s == '3') correctIndex = 3;
      if (s == 'E' || s == '4') correctIndex = 4;
    }

    String correctLetter = 'A';
    if (correctIndex == 1) correctLetter = 'B';
    if (correctIndex == 2) correctLetter = 'C';
    if (correctIndex == 3) correctLetter = 'D';
    if (correctIndex == 4) correctLetter = 'E';

    testQuestions[testId]?.add({
      'id': questionId,
      'question': item['question_text']?.toString() ?? '',
      'optionA': optionsList.isNotEmpty ? optionsList[0] : '',
      'optionB': optionsList.length > 1 ? optionsList[1] : '',
      'optionC': optionsList.length > 2 ? optionsList[2] : '',
      'optionD': optionsList.length > 3 ? optionsList[3] : '',
      'optionE': optionsList.length > 4 ? optionsList[4] : 'પ્રયાસ કરેલ નથી',
      'correct': correctLetter,
      'subject': item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
      'explanation': item['explanation']?.toString() ?? '',
      'topic_id': item['topic_id']?.toString(),
    });
  }

  /// 5. Fetch Dynamic Social Media & Website Settings
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

  /// 6. Load All Data from Supabase
  Future<void> loadAllData() async {
    isLoading = true;
    try {
      await Future.wait([
        fetchRealMockTests(),
        fetchRealStudents(),
        fetchRealWithdrawals(),
        fetchRealQuestions(),
        fetchSocialLinks(),
      ]);
    } catch (_) {}
    isLoading = false;
  }

  /// Add new Mock Test dynamically
  Future<bool> createMockTest({
    required String id,
    required String examId,
    required String title,
    required String description,
    required bool isFree,
    required int durationMinutes,
    required int totalQuestions,
  }) async {
    final success = await restPost('mock_tests', {
      'id': id,
      'exam_id': examId,
      'title': title,
      'description': description,
      'is_free': isFree,
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'positive_marks': 1.0,
      'negative_marks': 0.25,
    });

    if (success) {
      tests.add({
        'id': id,
        'exam': examId == 'psi' ? 'PSI / ASI' : 'કોન્સ્ટેબલ (LRD)',
        'exam_id': examId,
        'title': title,
        'description': description,
        'isFree': isFree,
        'totalMcqs': 0,
        'duration': durationMinutes,
      });
      testQuestions[id] = [];
    }
    return success;
  }

  /// Add question and persist to Supabase `questions` and `mock_test_questions`
  /// Verifies both inserts succeeded before displaying success (Part 6)
  Future<bool> addQuestion(String testId, Map<String, dynamic> question) async {
    final questionId = 'q_${DateTime.now().millisecondsSinceEpoch}';

    // Exactly 4 options for Supabase check constraint (questions_options_four_distinct_check)
    final optionsList = [
      question['optionA'] ?? '',
      question['optionB'] ?? '',
      question['optionC'] ?? '',
      question['optionD'] ?? '',
    ];
    int correctIdx = 0;
    if (question['correct'] == 'B') correctIdx = 1;
    if (question['correct'] == 'C') correctIdx = 2;
    if (question['correct'] == 'D') correctIdx = 3;
    if (question['correct'] == 'E') correctIdx = 4;

    // 1. Insert into questions table
    final qSuccess = await restPost('questions', {
      'id': questionId,
      'test_id': testId,
      'exam_id': testId.startsWith('psi') ? 'psi' : 'constable',
      'subject': question['subject'] ?? 'સામાન્ય જ્ઞાન',
      'question_text': question['question'] ?? '',
      'options': optionsList,
      'correct_option_index': correctIdx,
      'explanation': question['explanation'] ?? '',
    });

    if (!qSuccess) {
      return false;
    }

    // 2. Insert into mock_test_questions
    final currentPos = (testQuestions[testId]?.length ?? 0) + 1;
    final mtqSuccess = await restPost('mock_test_questions', {
      'test_id': testId,
      'question_id': questionId,
      'position': currentPos,
    });

    if (!mtqSuccess) {
      // Rollback question if mapping fails
      await restDelete('questions?id=eq.$questionId');
      return false;
    }

    // 3. Only add locally once confirmed from Supabase, prevent duplicate
    final qMap = Map<String, dynamic>.from(question);
    qMap['id'] = questionId;

    if (!testQuestions.containsKey(testId)) {
      testQuestions[testId] = [];
    }
    if (!testQuestions[testId]!.any((q) => q['id'] == questionId)) {
      testQuestions[testId]?.add(qMap);
    }

    // Refresh test totalMcqs count
    final testIdx = tests.indexWhere((t) => t['id'] == testId);
    if (testIdx >= 0) {
      tests[testIdx]['totalMcqs'] = testQuestions[testId]?.length ?? 0;
    }

    return true;
  }

  void editQuestion(String testId, int index, Map<String, dynamic> question) {
    if (testQuestions[testId] != null && index < testQuestions[testId]!.length) {
      final existing = testQuestions[testId]![index];
      testQuestions[testId]![index] = question;

      final questionId = existing['id']?.toString();
      if (questionId != null && questionId.isNotEmpty) {
        // Exactly 4 options for Supabase check constraint
        final optionsList = [
          question['optionA'] ?? '',
          question['optionB'] ?? '',
          question['optionC'] ?? '',
          question['optionD'] ?? '',
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
        restDelete('mock_test_questions?question_id=eq.$questionId');
        restDelete('questions?id=eq.$questionId');
      }
      final testIdx = tests.indexWhere((t) => t['id'] == testId);
      if (testIdx >= 0) {
        tests[testIdx]['totalMcqs'] = testQuestions[testId]?.length ?? 0;
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
