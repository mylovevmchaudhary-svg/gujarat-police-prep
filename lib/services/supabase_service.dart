import 'dart:convert';
import 'dart:io';
import '../models/quiz_model.dart';
import '../models/syllabus_model.dart';
import '../models/user_model.dart';
import 'security_vault.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Dynamic Cryptographic Vault Credentials (ZERO plaintext in binary)
  static String get supabaseUrl => SecurityVault.supabaseUrl;
  static String get supabaseAnonKey => SecurityVault.supabaseAnonKey;

  final UserModel _user = UserModel();

  /// Generic GET request to Supabase REST endpoint
  Future<dynamic> _restGet(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.getUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body);
      } else {
        debugPrint('[SupabaseService] GET error $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[SupabaseService] GET network error on $endpoint: $e');
    }
    return null;
  }

  /// Generic POST request to Supabase REST endpoint
  Future<bool> _restPost(String endpoint, Map<String, dynamic> data, {bool preferUpsert = false}) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.postUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Content-Type', 'application/json');
      if (preferUpsert) {
        request.headers.set('Prefer', 'resolution=merge-duplicates,return=representation');
      } else {
        request.headers.set('Prefer', 'return=representation');
      }

      request.write(jsonEncode(data));
      final response = await request.close();
      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (!success) {
        final body = await response.transform(utf8.decoder).join();
        debugPrint('[SupabaseService] POST $endpoint failed (${response.statusCode}): $body');
      }
      return success;
    } catch (e) {
      debugPrint('[SupabaseService] POST $endpoint network error: $e');
      return false;
    }
  }

  /// Generic PATCH request to Supabase REST endpoint
  Future<bool> _restPatch(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 6);
      final request = await client.patchUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=minimal');

      request.write(jsonEncode(data));
      final response = await request.close();
      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (!success) {
        debugPrint('[SupabaseService] PATCH $endpoint failed (${response.statusCode})');
      }
      return success;
    } catch (e) {
      debugPrint('[SupabaseService] PATCH $endpoint error: $e');
      return false;
    }
  }

  /// REAL Supabase Auth SignUp (Registers directly into Supabase auth.users & profiles)
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    int initialCoins = 30;
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      initialCoins += 20; // +50 total with referral
    }

    // 1. Update local user state immediately
    _user.register(
      userName: name,
      userEmail: email,
      referralCode: referralCode,
    );

    // 2. Call Supabase Auth API: POST /auth/v1/signup
    // This creates the user in Supabase Authentication -> Users dashboard!
    try {
      final authUri = Uri.parse('$supabaseUrl/auth/v1/signup');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(authUri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Content-Type', 'application/json');

      final authPayload = {
        'email': email,
        'password': password,
        'data': {
          'name': name,
          'referral_code': referralCode ?? '',
          'my_referral_code': _user.myReferralCode,
          'coins': _user.coins,
        },
      };

      request.write(jsonEncode(authPayload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> jsonResponse = jsonDecode(body);

      final userId = jsonResponse['id']?.toString() ?? jsonResponse['user']?['id']?.toString();

      // 3. Upsert into public.profiles table using authenticated user's actual UUID
      if (userId != null && userId.isNotEmpty) {
        final profileCreated = await _restPost('profiles?on_conflict=id', {
          'id': userId,
          'name': name,
          'email': email,
          'my_referral_code': _user.myReferralCode,
          'referred_by': referralCode,
          'coins': _user.coins,
        }, preferUpsert: true);
        debugPrint('[SupabaseService] Profile created in profiles: $profileCreated (UID: $userId)');
      }

      return {'success': true, 'userId': userId};
    } catch (e) {
      debugPrint('[SupabaseService] SignUp error: $e');
      return {'success': true, 'offline': true};
    }
  }

  /// REAL Supabase Auth SignIn (Authenticates against Supabase auth.users)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    // 1. Set local user state
    _user.login(userEmail: email);

    // 2. Call Supabase Auth API: POST /auth/v1/token?grant_type=password
    try {
      final tokenUri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.postUrl(tokenUri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Content-Type', 'application/json');

      request.write(jsonEncode({
        'email': email,
        'password': password,
      }));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> jsonResponse = jsonDecode(body);

      // If user signed in, load their live profile coins from Supabase
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userId = jsonResponse['user']?['id']?.toString();
        final userMetadata = jsonResponse['user']?['user_metadata'];
        final userName = userMetadata?['name']?.toString() ?? email.split('@').first;

        final profileData = await _restGet('profiles?email=eq.$email&select=*');
        if (profileData is List && profileData.isNotEmpty) {
          final p = profileData.first;
          final remoteCoins = (p['coins'] as num?)?.toInt();
          final remoteName = p['name']?.toString();
          if (remoteCoins != null) _user.setCoins(remoteCoins);
          if (remoteName != null && remoteName.isNotEmpty) _user.name = remoteName;
        } else if (userId != null && userId.isNotEmpty) {
          // If profile record missing in profiles table, upsert it with authenticated user's UUID
          await _restPost('profiles?on_conflict=id', {
            'id': userId,
            'name': userName,
            'email': email,
            'my_referral_code': _user.myReferralCode,
            'coins': _user.coins,
          }, preferUpsert: true);
        }
        return {'success': true, 'data': jsonResponse};
      } else {
        // If user not in Supabase auth yet, attempt auto-signup with the password
        debugPrint('[SupabaseService] User not in Auth, creating user via signUp for $email');
        await signUp(name: email.split('@').first, email: email, password: password);
        return {'success': true, 'autoRegistered': true};
      }
    } catch (e) {
      debugPrint('[SupabaseService] SignIn error: $e');
      return {'success': true, 'offline': true};
    }
  }

  /// Synchronize coins to Supabase profiles in real time
  Future<void> syncCoinsToDatabase(String email, int coins) async {
    if (email.isEmpty || !email.contains('@')) return;
    try {
      final patched = await _restPatch('profiles?email=eq.$email', {'coins': coins});
      if (!patched) {
        debugPrint('[SupabaseService] Coins patch failed for $email, coins: $coins');
      }
    } catch (e) {
      debugPrint('[SupabaseService] syncCoins error: $e');
    }
  }

  /// Helper to safely map raw database row to Question model
  Question _mapToQuestion(Map<String, dynamic> item) {
    final opts = item['options'];
    List<String> optionsList = [];
    if (opts is List) {
      optionsList = opts.map((e) => e.toString()).toList();
    }
    if (optionsList.length == 4) {
      optionsList.add('પ્રયાસ કરેલ નથી');
    }

    int correctIdx = 0;
    final rawCorrect = item['correct_option_index'];
    if (rawCorrect is num) {
      correctIdx = rawCorrect.toInt().clamp(0, 4);
    } else if (rawCorrect is String) {
      final s = rawCorrect.trim().toUpperCase();
      if (s == 'A' || s == '0') correctIdx = 0;
      if (s == 'B' || s == '1') correctIdx = 1;
      if (s == 'C' || s == '2') correctIdx = 2;
      if (s == 'D' || s == '3') correctIdx = 3;
      if (s == 'E' || s == '4') correctIdx = 4;
    }

    return Question(
      id: item['id']?.toString() ?? '',
      subject: item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
      questionText: item['question_text']?.toString() ?? '',
      options: optionsList,
      correctOptionIndex: correctIdx,
      explanation: item['explanation']?.toString() ?? '',
      topicId: item['topic_id']?.toString(),
      examId: item['exam_id']?.toString(),
      difficulty: item['difficulty']?.toString(),
    );
  }

  /// 1. Fetch DYNAMIC Mock Tests from Supabase `mock_tests` table (0 hardcoded limits)
  /// Always calculates actual MCQ counts dynamically from `mock_test_questions` table!
  Future<List<MockTest>> fetchMockTests({String? examId}) async {
    String endpoint = 'mock_tests?select=*,mock_test_questions(count)&order=id.asc';
    if (examId != null && examId.isNotEmpty) {
      endpoint = 'mock_tests?exam_id=eq.$examId&select=*,mock_test_questions(count)&order=id.asc';
    }

    final result = await _restGet(endpoint);
    if (result is List && result.isNotEmpty) {
      return result.map<MockTest>((item) {
        final isFreeVal = item['is_free'] == true;
        int actualCount = 0;
        final mtq = item['mock_test_questions'];
        if (mtq is List && mtq.isNotEmpty) {
          actualCount = (mtq.first['count'] as num?)?.toInt() ?? 0;
        }

        return MockTest(
          id: item['id']?.toString() ?? '',
          title: item['title']?.toString() ?? 'મોક ટેસ્ટ',
          description: item['description']?.toString() ?? '',
          category: isFreeVal ? 'Free Mock' : 'Premium Mock',
          durationMinutes: (item['duration_minutes'] as num?)?.toInt() ?? 180,
          positiveMarksPerQuestion: (item['positive_marks'] as num?)?.toDouble() ?? 1.0,
          negativeMarksPerQuestion: (item['negative_marks'] as num?)?.toDouble() ?? 0.25,
          isFree: isFreeVal,
          dbTotalQuestions: (item['total_questions'] as num?)?.toInt() ?? 200,
          actualMcqCount: actualCount,
          examId: item['exam_id']?.toString() ?? 'constable',
          questions: [],
        );
      }).toList();
    }
    return [];
  }

  /// 2. Fetch ALL Questions for a Test using Paginated JOIN with `mock_test_questions` and `questions`
  /// Handles 200, 500, 1000, 10,000+ MCQs without dropping a single question!
  Future<List<Question>> fetchAllQuestionsForTest(String testId) async {
    final List<Question> collected = [];
    final Set<String> seenIds = {};
    const int batchLimit = 500;
    int offset = 0;
    bool hasMore = true;

    // A. Query via `mock_test_questions` JOIN `questions`
    while (hasMore) {
      final endpoint =
          'mock_test_questions?test_id=eq.$testId&select=position,questions(*)&order=position.asc&limit=$batchLimit&offset=$offset';
      final batch = await _restGet(endpoint);
      if (batch is List && batch.isNotEmpty) {
        for (final row in batch) {
          final qData = row['questions'];
          if (qData is Map) {
            final q = _mapToQuestion(Map<String, dynamic>.from(qData));
            if (seenIds.add(q.id)) {
              collected.add(q);
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

    // B. Also query direct questions table where test_id = testId (if any added directly)
    offset = 0;
    hasMore = true;
    while (hasMore) {
      final endpoint =
          'questions?test_id=eq.$testId&select=*&order=created_at.asc&limit=$batchLimit&offset=$offset';
      final batch = await _restGet(endpoint);
      if (batch is List && batch.isNotEmpty) {
        for (final row in batch) {
          if (row is Map) {
            final q = _mapToQuestion(Map<String, dynamic>.from(row));
            if (seenIds.add(q.id)) {
              collected.add(q);
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

    return collected;
  }

  /// Alias for backward compatibility
  Future<List<Question>> fetchQuestionsForTest(String testId) async {
    return await fetchAllQuestionsForTest(testId);
  }

  /// 3. Fetch Real-time MCQ Counts grouped by Topic ID & Subject
  Future<Map<String, int>> fetchTopicMcqCounts() async {
    final Map<String, int> counts = {};
    const int batchLimit = 1000;
    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final batch = await _restGet(
          'questions?select=id,topic_id,subject&limit=$batchLimit&offset=$offset');
      if (batch is List && batch.isNotEmpty) {
        for (final item in batch) {
          final topicId = item['topic_id']?.toString();
          final subject = item['subject']?.toString();
          if (topicId != null && topicId.isNotEmpty) {
            counts[topicId] = (counts[topicId] ?? 0) + 1;
          }
          if (subject != null && subject.isNotEmpty) {
            counts[subject] = (counts[subject] ?? 0) + 1;
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
    return counts;
  }

  /// 4. Fetch DYNAMIC Syllabus & Topics directly from Supabase (ZERO hardcoded topics!)
  Future<List<SyllabusSubject>> fetchSyllabusWithTopics({String? examId}) async {
    String endpoint = 'syllabus?select=*,syllabus_topics(*)&order=created_at.asc';
    if (examId != null && examId.isNotEmpty) {
      endpoint = 'syllabus?exam_id=eq.$examId&select=*,syllabus_topics(*)&order=created_at.asc';
    }

    final dynamic result = await _restGet(endpoint);
    final counts = await fetchTopicMcqCounts();

    if (result is List && result.isNotEmpty) {
      return result.map<SyllabusSubject>((item) {
        final List<SyllabusTopic> parsedTopics = [];

        // Parse from joined `syllabus_topics` table
        final rawTopics = item['syllabus_topics'];
        if (rawTopics is List) {
          for (final t in rawTopics) {
            final topicId = t['id']?.toString() ?? '';
            final gujTitle = t['title_gujarati']?.toString() ?? t['title']?.toString() ?? '';
            final engTitle = t['title']?.toString() ?? gujTitle;
            final count = counts[topicId] ?? counts[gujTitle] ?? 0;

            parsedTopics.add(SyllabusTopic(
              id: topicId,
              name: engTitle,
              nameGujarati: gujTitle,
              syllabusId: t['syllabus_id']?.toString(),
              paperPart: t['paper_part']?.toString(),
              keyPoints: [],
              mcqCount: count,
            ));
          }
        }

        final subjectGujarati = item['title_gujarati']?.toString() ?? item['title']?.toString() ?? '';
        final subjectId = item['id']?.toString() ?? '';
        final totalSubjMcqs = counts[subjectId] ?? counts[subjectGujarati] ?? 0;

        return SyllabusSubject(
          id: subjectId,
          title: item['title']?.toString() ?? '',
          titleGujarati: subjectGujarati,
          iconName: item['icon_name']?.toString() ?? 'menu_book',
          totalMarksWeightage: (item['total_marks_weightage'] as num?)?.toInt() ?? 10,
          examId: item['exam_id']?.toString() ?? 'constable',
          dynamicMcqCount: totalSubjMcqs,
          topics: parsedTopics,
        );
      }).toList();
    }
    return [];
  }

  /// 5. Fetch MCQs specifically belonging to a Syllabus Topic for interactive practice
  Future<List<Question>> fetchQuestionsForTopic(String topicId, String subjectGujarati) async {
    final List<Question> questions = [];
    final Set<String> seenIds = {};

    // Match by topic_id or matching subject text
    final endpoint = 'questions?topic_id=eq.$topicId&select=*&limit=500';
    final result = await _restGet(endpoint);
    if (result is List && result.isNotEmpty) {
      for (final item in result) {
        final q = _mapToQuestion(Map<String, dynamic>.from(item));
        if (seenIds.add(q.id)) {
          questions.add(q);
        }
      }
    }

    if (questions.isEmpty && subjectGujarati.isNotEmpty) {
      final fallbackEndpoint = 'questions?subject=ilike.%$subjectGujarati%&select=*&limit=500';
      final fbResult = await _restGet(fallbackEndpoint);
      if (fbResult is List && fbResult.isNotEmpty) {
        for (final item in fbResult) {
          final q = _mapToQuestion(Map<String, dynamic>.from(item));
          if (seenIds.add(q.id)) {
            questions.add(q);
          }
        }
      }
    }

    return questions;
  }

  /// Fetch dynamic social & website links from app_settings
  Future<Map<String, String>> fetchSocialLinks() async {
    final result = await _restGet('app_settings?key=eq.social_links&select=value');
    if (result is List && result.isNotEmpty) {
      final val = result.first['value'];
      if (val is Map) {
        return {
          'website': val['website']?.toString() ?? 'https://gujaratpoliceprep.in',
          'whatsapp': val['whatsapp']?.toString() ?? 'https://chat.whatsapp.com/KhakhiPrep2026',
          'telegram': val['telegram']?.toString() ?? 'https://t.me/GujaratPolicePrep',
          'youtube': val['youtube']?.toString() ?? 'https://youtube.com/@GujaratPolicePrep',
          'instagram': val['instagram']?.toString() ?? 'https://instagram.com/gujaratpoliceprep',
        };
      }
    }
    return {
      'website': 'https://gujaratpoliceprep.in',
      'whatsapp': 'https://chat.whatsapp.com/KhakhiPrep2026',
      'telegram': 'https://t.me/GujaratPolicePrep',
      'youtube': 'https://youtube.com/@GujaratPolicePrep',
      'instagram': 'https://instagram.com/gujaratpoliceprep',
    };
  }

  /// Fetch real notifications from Supabase (ZERO hardcoded fallback)
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final result = await _restGet('notifications?is_active=eq.true&order=created_at.desc&select=*');
    if (result is List && result.isNotEmpty) {
      return List<Map<String, dynamic>>.from(result);
    }
    // Return empty list if no notifications added in database yet!
    return [];
  }

  /// Submit UPI Cashout / Withdrawal
  Future<bool> submitWithdrawal({
    required String studentName,
    required String studentEmail,
    required int coins,
    required double amountInr,
    required String upiId,
  }) async {
    return await _restPost('withdrawals', {
      'student_name': studentName,
      'student_email': studentEmail,
      'coins_deducted': coins,
      'amount_inr': amountInr,
      'upi_id': upiId,
      'status': 'pending',
    });
  }
}
