import '../services/supabase_service.dart';

class AdminDataManager {
  static final AdminDataManager _instance = AdminDataManager._internal();
  factory AdminDataManager() => _instance;
  AdminDataManager._internal();

  String supabaseUrl = 'https://sbujnpiaxyjtjgsszpdn.supabase.co';
  String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidWpucGlheHlqdGpnc3N6cGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDk3MDQsImV4cCI6MjExMDgyNTcwNH0.crnzNtr5Kf7XM62E9CwjFua4kBzJ8U5e1UIKG6qNs0I';
  bool isConnectedToSupabase = true;

  int totalStudents = 14850;
  int totalQuestionsInBank = 45000;
  int totalTestsCount = 20;

  // Active Tests list
  final List<Map<String, dynamic>> tests = [
    {'id': 'constable_1', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 01', 'isFree': true, 'mcqs': 200},
    {'id': 'constable_2', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 02', 'isFree': true, 'mcqs': 200},
    {'id': 'constable_3', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 03', 'isFree': true, 'mcqs': 200},
    {'id': 'constable_4', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 04', 'isFree': false, 'mcqs': 200},
    {'id': 'psi_1', 'exam': 'PSI / ASI', 'title': 'PSI પ્રિલિમિનરી ટેસ્ટ 01', 'isFree': true, 'mcqs': 200},
    {'id': 'psi_2', 'exam': 'PSI / ASI', 'title': 'PSI કાયદો & બંધારણ ટેસ્ટ 02', 'isFree': true, 'mcqs': 200},
    {'id': 'psi_3', 'exam': 'PSI / ASI', 'title': 'PSI ભાષાકીય ટેસ્ટ 03', 'isFree': true, 'mcqs': 200},
    {'id': 'psi_4', 'exam': 'PSI / ASI', 'title': 'PSI પ્રીમિયમ ટેસ્ટ 04', 'isFree': false, 'mcqs': 200},
  ];

  void toggleTestFree(int index) {
    tests[index]['isFree'] = !tests[index]['isFree'];
  }

  void saveSupabaseConfig(String url, String key) {
    supabaseUrl = url;
    supabaseKey = key;
    isConnectedToSupabase = url.contains('supabase.co') && key.isNotEmpty;
    SupabaseService.updateCredentials(url, key);
  }
}
