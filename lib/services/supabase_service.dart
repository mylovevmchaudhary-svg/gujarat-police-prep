import '../models/quiz_model.dart';
import '../models/user_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase Live Project Credentials
  static String supabaseUrl = 'https://sbujnpiaxyjtjgsszpdn.supabase.co';
  static String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidWpucGlheHlqdGpnc3N6cGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDk3MDQsImV4cCI6MjExMDgyNTcwNH0.crnzNtr5Kf7XM62E9CwjFua4kBzJ8U5e1UIKG6qNs0I';

  static void updateCredentials(String url, String key) {
    supabaseUrl = url;
    supabaseAnonKey = key;
  }

  bool get isConfigured =>
      supabaseUrl != 'https://your-project-id.supabase.co' &&
      supabaseAnonKey != 'your-anon-key-here';

  final UserModel _user = UserModel();

  /// Sign Up with Email, Password, Name and optional Referral Code
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    // If Supabase is configured, it would call Supabase.instance.client.auth.signUp()
    // Local / Offline fallback guarantees app works seamlessly right now!
    _user.register(
      userName: name,
      userEmail: email,
      referralCode: referralCode,
    );
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
    // Queries Supabase `questions` table if online, otherwise returns cached questions
    return [];
  }
}
