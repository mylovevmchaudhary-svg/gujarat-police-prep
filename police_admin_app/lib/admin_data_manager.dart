class AdminDataManager {
  static final AdminDataManager _instance = AdminDataManager._internal();
  factory AdminDataManager() => _instance;
  AdminDataManager._internal() {
    _initQuestions();
  }

  // Supabase Configuration
  String supabaseUrl = 'https://sbujnpiaxyjtjgsszpdn.supabase.co';
  String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNidWpucGlheHlqdGpnc3N6cGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTUyNDk3MDQsImV4cCI6MjExMDgyNTcwNH0.crnzNtr5Kf7XM62E9CwjFua4kBzJ8U5e1UIKG6qNs0I';
  bool isConnectedToSupabase = true;

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
    {
      'id': 'std_4',
      'name': 'કિશન દેસાઈ',
      'email': 'kishan.desai@gmail.com',
      'coins': 90,
      'referrals': 1,
      'joinedDate': '20 Nov 2026',
      'isActive': true,
    },
    {
      'id': 'std_5',
      'name': 'જયદીપસિંહ જાડેજા',
      'email': 'jaydeep.jadeja@gmail.com',
      'coins': 480,
      'referrals': 8,
      'joinedDate': '12 Nov 2026',
      'isActive': true,
    },
  ];

  // Active Mock Tests list (Strictly 2 Exams: Constable LRD & PSI/ASI)
  final List<Map<String, dynamic>> tests = [
    {'id': 'constable_1', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 01', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_2', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 02', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_3', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 03', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'constable_4', 'exam': 'કોન્સ્ટેબલ (LRD)', 'title': 'મોક ટેસ્ટ 04', 'isFree': false, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_1', 'exam': 'PSI / ASI', 'title': 'PSI પ્રિલિમિનરી ટેસ્ટ 01', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_2', 'exam': 'PSI / ASI', 'title': 'PSI કાયદો & બંધારણ ટેસ્ટ 02', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_3', 'exam': 'PSI / ASI', 'title': 'PSI ભાષાકીય ટેસ્ટ 03', 'isFree': true, 'totalMcqs': 200, 'duration': 180},
    {'id': 'psi_4', 'exam': 'PSI / ASI', 'title': 'PSI પ્રીમિયમ ટેસ્ટ 04', 'isFree': false, 'totalMcqs': 200, 'duration': 180},
  ];

  // Distinct Authentic Question Bank per Test
  late final Map<String, List<Map<String, dynamic>>> testQuestions;

  void _initQuestions() {
    testQuestions = {
      'constable_1': [
        {
          'question': 'ભારતીય બંધારણના કયા અનુચ્છેદ મુજબ કાયદા સમક્ષ સમાનતાનો અધિકાર આપેલ છે?',
          'optionA': 'અનુચ્છેદ 14',
          'optionB': 'અનુચ્છેદ 19',
          'optionC': 'અનુચ્છેદ 21',
          'optionD': 'અનુચ્છેદ 32',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'ભારતીય બંધારણ',
          'explanation': 'અનુચ્છેદ 14 મુજબ ભારતના રાજ્યક્ષેત્રમાં કાયદા સમક્ષ સમાનતા અને કાયદાનું સમાન રક્ષણ સુનિશ્ચિત કરવામાં આવ્યું છે.',
        },
        {
          'question': 'ઇન્ડિયન પેનલ કોડ (IPC) ની કલમ 378 માં શાની વ્યાખ્યા આપવામાં આવી છે?',
          'optionA': 'ચોરી (Theft)',
          'optionB': 'લૂંટ (Robbery)',
          'optionC': 'ધાડ (Dacoity)',
          'optionD': 'છેતરપિંડી (Cheating)',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'કાયદો',
          'explanation': 'કલમ 378 માં ચોરીની વ્યાખ્યા અને કલમ 379 માં ચોરીની સજા (3 વર્ષ સુધીની કેદ) દર્શાવેલ છે.',
        },
        {
          'question': 'ગુજરાતનો સૌથી લાંબો દરિયાકિનારો કયા જિલ્લાને સ્પર્શે છે?',
          'optionA': 'જામનગર',
          'optionB': 'કચ્છ',
          'optionC': 'ભાવનગર',
          'optionD': 'ગીર સોમનાથ',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'B',
          'subject': 'ગુજરાતની ભૂગોળ',
          'explanation': 'કચ્છ જિલ્લાને આશરે 406 કિલોમીટર લાંબો દરિયાકિનારો મળેલ છે.',
        },
        {
          'question': 'સિદ્ધરાજ જયસિંહે પાટણમાં કયું ઐતિહાસિક તળાવ બંધાવ્યું હતું?',
          'optionA': 'સહસ્રલિંગ તળાવ',
          'optionB': 'મુનસર તળાવ',
          'optionC': 'મલાવ તળાવ',
          'optionD': 'હમીરસર તળાવ',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'ગુજરાતનો ઇતિહાસ',
          'explanation': 'પાટણમાં સરસ્વતી નદીના કાંઠે સહસ્રલિંગ તળાવ સિદ્ધરાજ જયસિંહે બંધાવ્યું હતું.',
        },
        {
          'question': 'જો A = 1, CAT = 24 હોય, તો POLICE = ?',
          'optionA': '60',
          'optionB': '63',
          'optionC': '65',
          'optionD': '68',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'રીઝનિંગ',
          'explanation': 'P(16) + O(15) + L(12) + I(9) + C(3) + E(5) = 60.',
        },
      ],
      'psi_1': [
        {
          'question': 'CrPC ની કઈ કલમ હેઠળ પોલીસ અધિકારી વોરંટ વગર ધરપકડ કરી શકે છે?',
          'optionA': 'કલમ 41',
          'optionB': 'કલમ 51',
          'optionC': 'કલમ 154',
          'optionD': 'કલમ 167',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'કાયદો (CrPC)',
          'explanation': 'CrPC કલમ 41 માં પોલીસ વોરંટ વગર ક્યારે ધરપકડ કરી શકે તેની તમામ પરિસ્થિતિઓ દર્શાવેલી છે.',
        },
        {
          'question': 'ભારતીય પુરાવા અધિનિયમ (Evidence Act) મુજબ મરણોન્મુખ નિવેદન (Dying Declaration) કઈ કલમ હેઠળ ગ્રાહ્ય છે?',
          'optionA': 'કલમ 32(1)',
          'optionB': 'કલમ 25',
          'optionC': 'કલમ 27',
          'optionD': 'કલમ 45',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'કાયદો (Evidence Act)',
          'explanation': 'મરણોન્મુખ નિવેદન કલમ 32(1) મુજબ અત્યંત મહત્વનો અને અદાલતમાં ગ્રાહ્ય પુરાવો છે.',
        },
        {
          'question': 'નીચેનામાંથી કયો શબ્દ "અલંકાર" ની દ્રષ્ટિએ "ઉત્પ્રેક્ષા" નું ઉદાહરણ છે?',
          'optionA': 'દમયંતીનું મુખ જાણે પૂનમનો ચંદ્ર',
          'optionB': 'કમળ જેવો કોમળ હાથ',
          'optionC': 'સાગર સમો ગંભીર',
          'optionD': 'નયન વાણી વિના બોલે',
          'optionE': 'પ્રયાસ કરેલ નથી',
          'correct': 'A',
          'subject': 'ગુજરાતી વ્યાકરણ',
          'explanation': '"જાણે, રખે, શકે" શબ્દો ઉત્પ્રેક્ષા અલંકાર દર્શાવે છે.',
        },
      ],
    };
  }

  // Student Coin management
  void updateStudentCoins(int index, int delta) {
    if (index >= 0 && index < students.length) {
      students[index]['coins'] = (students[index]['coins'] as int) + delta;
    }
  }

  // Toggle student active state
  void toggleStudentStatus(int index) {
    if (index >= 0 && index < students.length) {
      students[index]['isActive'] = !(students[index]['isActive'] as bool);
    }
  }

  // Toggle Test Free/Lock
  void toggleTestFree(int index) {
    if (index >= 0 && index < tests.length) {
      tests[index]['isFree'] = !(tests[index]['isFree'] as bool);
    }
  }

  // Add Question to Test
  void addQuestion(String testId, Map<String, dynamic> q) {
    testQuestions.putIfAbsent(testId, () => []);
    testQuestions[testId]!.insert(0, q);
    _updateTestCount(testId);
  }

  // Edit Question
  void editQuestion(String testId, int index, Map<String, dynamic> q) {
    if (testQuestions.containsKey(testId) && index < testQuestions[testId]!.length) {
      testQuestions[testId]![index] = q;
    }
  }

  // Delete Question
  void deleteQuestion(String testId, int index) {
    if (testQuestions.containsKey(testId) && index < testQuestions[testId]!.length) {
      testQuestions[testId]!.removeAt(index);
      _updateTestCount(testId);
    }
  }

  void _updateTestCount(String testId) {
    final idx = tests.indexWhere((t) => t['id'] == testId);
    if (idx != -1) {
      tests[idx]['totalMcqs'] = testQuestions[testId]?.length ?? 0;
    }
  }
}
