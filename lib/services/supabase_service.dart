import 'dart:convert';
import 'dart:io';
import '../models/quiz_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase Live Project Credentials
  static String supabaseUrl = 'https://sbujnpiaxyjtjgsszpdn.supabase.co';
  static String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidWpucGlheHlqdGpnc3N6cGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDk3MDQsImV4cCI6MjExMDgyNTcwNH0.crnzNtr5Kf7XM62E9CwjFua4kBzJ8U5e1UIKG6qNs0I';

  static void updateCredentials(String url, String key) {
    supabaseUrl = url;
    supabaseAnonKey = key;
  }

  final UserModel _user = UserModel();

  /// Generic GET request to Supabase REST endpoint
  Future<dynamic> _restGet(String endpoint) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Accept', 'application/json');

      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body);
      }
    } catch (_) {
      // Graceful fallback if network is offline or table is not created yet
    }
    return null;
  }

  /// Generic POST request to Supabase REST endpoint
  Future<bool> _restPost(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/$endpoint');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.postUrl(uri);
      request.headers.set('apikey', supabaseAnonKey);
      request.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Prefer', 'return=minimal');

      request.write(jsonEncode(data));
      final response = await request.close();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  /// Sign Up with Email, Password, Name and optional Referral Code
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    _user.register(
      userName: name,
      userEmail: email,
      referralCode: referralCode,
    );
    // Sync with Supabase profiles table in background
    _restPost('profiles', {
      'name': name,
      'email': email,
      'my_referral_code': _user.myReferralCode,
      'referred_by': referralCode,
      'coins': _user.coins,
    });
    return true;
  }

  /// Sign In with Email and Password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _user.login(userEmail: email);
    return true;
  }

  /// Fetch questions for a mock test
  Future<List<Question>> fetchQuestionsForTest(String testId) async {
    final result = await _restGet('questions?test_id=eq.$testId&select=*');
    if (result is List && result.isNotEmpty) {
      return result.map((item) {
        final opts = item['options'];
        List<String> optionsList = [];
        if (opts is List) {
          optionsList = opts.map((e) => e.toString()).toList();
        }
        return Question(
          id: item['id']?.toString() ?? '',
          subject: item['subject']?.toString() ?? 'સામાન્ય જ્ઞાન',
          question: item['question_text']?.toString() ?? '',
          options: optionsList,
          correctOptionIndex: (item['correct_option_index'] as num?)?.toInt() ?? 0,
          explanation: item['explanation']?.toString(),
        );
      }).toList();
    }
    return [];
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

  /// Fetch notifications from Supabase
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final result = await _restGet('notifications?is_active=eq.true&order=created_at.desc&select=*');
    if (result is List && result.isNotEmpty) {
      return List<Map<String, dynamic>>.from(result);
    }
    // Default system alerts fallback
    return [
      {
        'id': 'notif_1',
        'title': '🚨 ગુજરાત પોલીસ કોન્સ્ટેબલ અને PSI પરીક્ષા 2026 અપડેટ',
        'message': 'સત્તાવાર ભરતી બોર્ડ દ્વારા પરીક્ષાનું નવું માળખું જાહેર કરવામાં આવ્યું છે. તમામ ઉમેદવારોએ સિલેબસ ચેક કરવો.',
        'type': 'exam',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'notif_2',
        'title': '✨ નવી મોક ટેસ્ટ સીરીઝ લાઈવ!',
        'message': 'નવા 200 ગુણના પેપર મુજબ મોક ટેસ્ટ ઉપલબ્ધ કરવામાં આવી છે. તમારા મિત્રોને રેફર કરો અને ફ્રી કોઈન્સ મેળવો!',
        'type': 'test',
        'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'id': 'notif_3',
        'title': '🪙 દૈનિક લોગિન બોનસ મેળવો',
        'message': 'દરરોજ એપ્લિકેશન ખોલીને 10 ફ્રી કોઈન્સ મેળવો અને પ્રીમિયમ ટેસ્ટ ફ્રીમાં અનલોક કરો.',
        'type': 'alert',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
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
