import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Generic GET request to Supabase REST endpoint with error logging
  Future<dynamic> _restGet(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(body);
      } else {
        debugPrint('[SupabaseService] GET $endpoint failed [Status ${response.statusCode}]: $body');
      }
    } catch (e) {
      debugPrint('[SupabaseService] GET network error on $endpoint: $e');
    }
    return null;
  }

  /// Generic POST request to Supabase REST endpoint with error logging
  Future<bool> _restPost(String endpoint, Map<String, dynamic> data, {bool preferUpsert = false}) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
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
      final body = await response.transform(utf8.decoder).join();
      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (!success) {
        debugPrint('[SupabaseService] POST $endpoint failed [Status ${response.statusCode}]: $body');
      }
      return success;
    } catch (e) {
      debugPrint('[SupabaseService] POST $endpoint network error: $e');
      return false;
    }
  }

  /// Generic PATCH request to Supabase REST endpoint with error logging
  Future<bool> _restPatch(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.patchUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=minimal');

      request.write(jsonEncode(data));
      final response = await request.close();
      final success = response.statusCode >= 200 && response.statusCode < 300;
      if (!success) {
        final body = await response.transform(utf8.decoder).join();
        debugPrint('[SupabaseService] PATCH $endpoint failed [Status ${response.statusCode}]: $body');
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

    try {
      final authUri = Uri.parse('$supabaseUrl/auth/v1/signup');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
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
          'coins': initialCoins,
        },
      };

      request.write(jsonEncode(authPayload));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final dynamic decoded = jsonDecode(body);
      final Map<String, dynamic> jsonResponse = decoded is Map<String, dynamic> ? decoded : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userId = jsonResponse['id']?.toString() ?? jsonResponse['user']?['id']?.toString();

        if (userId != null && userId.isNotEmpty) {
          // Upsert into public.profiles table using authenticated user's actual UUID
          await _restPost('profiles?on_conflict=id', {
            'id': userId,
            'name': name,
            'email': email,
            'my_referral_code': _user.myReferralCode,
            'referred_by': referralCode,
            'coins': initialCoins,
          }, preferUpsert: true);
        }

        _user.register(
          userName: name,
          userEmail: email,
          referralCode: referralCode,
        );
        _user.setCoins(initialCoins);

        return {'success': true, 'userId': userId};
      } else {
        final errorMsg = jsonResponse['msg'] ??
            jsonResponse['error_description'] ??
            jsonResponse['message'] ??
            'નોંધણી નિષ્ફળ થઈ (${response.statusCode})';
        debugPrint('[SupabaseService] SignUp error [Status ${response.statusCode}]: $errorMsg');
        return {'success': false, 'error': errorMsg.toString()};
      }
    } catch (e) {
      debugPrint('[SupabaseService] SignUp network error: $e');
      return {'success': false, 'error': 'નેટવર્ક કનેક્શન ક્ષતિ: $e'};
    }
  }

  /// REAL Supabase Auth SignIn (Authenticates against Supabase auth.users)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final tokenUri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.postUrl(tokenUri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Content-Type', 'application/json');

      request.write(jsonEncode({
        'email': email,
        'password': password,
      }));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final dynamic decoded = jsonDecode(body);
      final Map<String, dynamic> jsonResponse = decoded is Map<String, dynamic> ? decoded : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userId = jsonResponse['user']?['id']?.toString();
        final userMetadata = jsonResponse['user']?['user_metadata'];
        final userName = userMetadata?['name']?.toString() ?? email.split('@').first;

        String nameToSet = userName;
        int coinsToSet = 30;

        if (userId != null && userId.isNotEmpty) {
          final profileData = await _restGet('profiles?id=eq.$userId&select=*');
          if (profileData is List && profileData.isNotEmpty) {
            final p = profileData.first;
            final remoteCoins = (p['coins'] as num?)?.toInt();
            final remoteName = p['name']?.toString();
            if (remoteCoins != null) coinsToSet = remoteCoins;
            if (remoteName != null && remoteName.isNotEmpty) nameToSet = remoteName;
          } else {
            // Upsert profile record if missing
            await _restPost('profiles?on_conflict=id', {
              'id': userId,
              'name': userName,
              'email': email,
              'my_referral_code': _user.myReferralCode,
              'coins': coinsToSet,
            }, preferUpsert: true);
          }
        }

        _user.login(userEmail: email);
        _user.name = nameToSet;
        _user.setCoins(coinsToSet);

        return {'success': true, 'userId': userId, 'data': jsonResponse};
      } else {
        // STRICT: Return authentication error. No silent login and no auto-registration!
        final errorMsg = jsonResponse['error_description'] ??
            jsonResponse['msg'] ??
            jsonResponse['message'] ??
            'અમાન્ય ઈમેલ અથવા પાસવર્ડ.';
        debugPrint('[SupabaseService] SignIn authentication rejected [Status ${response.statusCode}]: $errorMsg');
        return {'success': false, 'error': errorMsg.toString()};
      }
    } catch (e) {
      debugPrint('[SupabaseService] SignIn network error: $e');
      return {'success': false, 'error': 'કૃપા કરીને ઇન્ટરનેટ કનેક્શન તપાસો.'};
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

    // Fallback: If joined query returned empty, do two-step fetch
    if (collected.isEmpty) {
      final mtqRows = await _restGet(
          'mock_test_questions?test_id=eq.$testId&select=question_id,position&order=position.asc&limit=1000');
      if (mtqRows is List && mtqRows.isNotEmpty) {
        final List<String> qIds = [];
        final Map<String, int> posMap = {};
        for (final r in mtqRows) {
          if (r is Map) {
            final qId = r['question_id']?.toString();
            if (qId != null && qId.isNotEmpty) {
              qIds.add(qId);
              posMap[qId] = (r['position'] as num?)?.toInt() ?? 0;
            }
          }
        }
        if (qIds.isNotEmpty) {
          // Chunk in batches of 50 for the in. filter
          for (int i = 0; i < qIds.length; i += 50) {
            final chunk = qIds.sublist(i, (i + 50 > qIds.length) ? qIds.length : i + 50);
            final inList = chunk.join(',');
            final qRows = await _restGet('questions?id=in.($inList)&select=*');
            if (qRows is List && qRows.isNotEmpty) {
              for (final row in qRows) {
                if (row is Map) {
                  final q = _mapToQuestion(Map<String, dynamic>.from(row));
                  if (seenIds.add(q.id)) {
                    collected.add(q);
                  }
                }
              }
            }
          }
          // Sort questions strictly by assigned position
          collected.sort((a, b) => (posMap[a.id] ?? 0).compareTo(posMap[b.id] ?? 0));
        }
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
  /// Correctly links syllabus and syllabus_topics via syllabus_id foreign key relationship.
  Future<List<SyllabusSubject>> fetchSyllabusWithTopics({String? examId}) async {
    // 1. Fetch live topic MCQ counts
    final counts = await fetchTopicMcqCounts();

    // 2. Fetch Syllabus sections
    String syllabusEndpoint = 'syllabus?order=id.asc';
    if (examId != null && examId.isNotEmpty) {
      syllabusEndpoint = 'syllabus?exam_id=eq.$examId&order=id.asc';
    }
    final syllabusData = await _restGet(syllabusEndpoint);
    if (syllabusData is! List || syllabusData.isEmpty) {
      return [];
    }

    // 3. Fetch syllabus_topics separately for 100% reliable mapping
    String topicsEndpoint = 'syllabus_topics?order=id.asc&limit=1000';
    final topicsData = await _restGet(topicsEndpoint);

    final Map<String, List<SyllabusTopic>> topicsBySyllabusId = {};
    if (topicsData is List) {
      for (final t in topicsData) {
        if (t is Map) {
          final sylId = t['syllabus_id']?.toString() ?? '';
          final topicId = t['id']?.toString() ?? '';
          final gujTitle = t['title_gujarati']?.toString() ?? t['title']?.toString() ?? '';
          final engTitle = t['title']?.toString() ?? gujTitle;
          final count = counts[topicId] ?? 0;

          final topic = SyllabusTopic(
            id: topicId,
            name: engTitle,
            nameGujarati: gujTitle,
            syllabusId: sylId,
            paperPart: t['paper_part']?.toString(),
            contentType: t['content_type']?.toString(),
            keyPoints: [],
            mcqCount: count,
          );

          topicsBySyllabusId.putIfAbsent(sylId, () => []).add(topic);
        }
      }
    }

    final List<SyllabusSubject> subjects = [];
    for (final item in syllabusData) {
      if (item is Map) {
        final subjectId = item['id']?.toString() ?? '';
        final subjectGujarati = item['title_gujarati']?.toString() ?? item['title']?.toString() ?? '';
        final subjectEnglish = item['title']?.toString() ?? subjectGujarati;
        final exId = item['exam_id']?.toString() ?? 'constable';

        // Retrieve mapped topics
        final List<SyllabusTopic> sectionTopics = topicsBySyllabusId[subjectId] ?? [];

        // If topicsData was not available separately, check embedded join
        if (sectionTopics.isEmpty && item['syllabus_topics'] is List) {
          for (final t in (item['syllabus_topics'] as List)) {
            if (t is Map) {
              final topicId = t['id']?.toString() ?? '';
              final gujTitle = t['title_gujarati']?.toString() ?? t['title']?.toString() ?? '';
              final engTitle = t['title']?.toString() ?? gujTitle;
              final count = counts[topicId] ?? 0;
              sectionTopics.add(SyllabusTopic(
                id: topicId,
                name: engTitle,
                nameGujarati: gujTitle,
                syllabusId: subjectId,
                paperPart: t['paper_part']?.toString(),
                contentType: t['content_type']?.toString(),
                keyPoints: [],
                mcqCount: count,
              ));
            }
          }
        }

        // Calculate dynamic section MCQ total from topics
        int totalSubjMcqs = 0;
        for (final st in sectionTopics) {
          totalSubjMcqs += st.mcqCount;
        }

        subjects.add(SyllabusSubject(
          id: subjectId,
          title: subjectEnglish,
          titleGujarati: subjectGujarati,
          iconName: item['icon_name']?.toString() ?? 'menu_book',
          totalMarksWeightage: (item['total_marks_weightage'] as num?)?.toInt() ?? 10,
          examId: exId,
          dynamicMcqCount: totalSubjMcqs,
          topics: sectionTopics,
        ));
      }
    }

    return subjects;
  }

  /// 5. Fetch MCQs specifically belonging to a Syllabus Topic by `topic_id`
  /// Strictly queries by `topic_id` (Part 3)
  Future<List<Question>> fetchQuestionsForTopic(String topicId, [String? subjectGujarati]) async {
    final List<Question> questions = [];
    final endpoint = 'questions?topic_id=eq.$topicId&select=*&order=id.asc&limit=1000';
    final result = await _restGet(endpoint);
    if (result is List && result.isNotEmpty) {
      for (final item in result) {
        if (item is Map) {
          questions.add(_mapToQuestion(Map<String, dynamic>.from(item)));
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
