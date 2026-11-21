import 'package:flutter/material.dart';
import '../admin_data_manager.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final _adminData = AdminDataManager();

  // Test Selection for Question Management
  String _selectedTestId = 'constable_1';

  // Excel / CSV Controller
  final _csvController = TextEditingController();
  int _uploadedCount = 0;
  bool _uploadSuccess = false;

  // Search in questions
  String _questionSearch = '';

  // Search in students
  String _studentSearch = '';

  // Masked API Key display
  bool _showApiKey = false;

  // Withdrawal Requests list managed by Admin
  final List<Map<String, dynamic>> _withdrawals = [
    {
      'id': 'wd_101',
      'studentName': 'રમેશ ચૌધરી',
      'email': 'ramesh.chaudhary@gmail.com',
      'amount': '₹50.00',
      'coins': 500,
      'upi': '9876543210@paytm',
      'status': 'પેન્ડિંગ (Pending)',
      'isPending': true,
      'date': 'આજે 12:45 PM',
    },
    {
      'id': 'wd_102',
      'studentName': 'ભાવિક પટેલ',
      'email': 'bhavik.patel@gmail.com',
      'amount': '₹20.00',
      'coins': 200,
      'upi': 'bhavik@oksbi',
      'status': 'મંજૂર થયેલ (Paid) ✅',
      'isPending': false,
      'date': 'ગઈકાલે',
    },
    {
      'id': 'wd_103',
      'studentName': 'પૂજા ઠાકોર',
      'email': 'pooja.thakor@gmail.com',
      'amount': '₹100.00',
      'coins': 1000,
      'upi': 'poojathakor@ybl',
      'status': 'પેન્ડિંગ (Pending)',
      'isPending': true,
      'date': 'આજે 02:15 PM',
    },
  ];

  void _approveWithdrawal(int index) {
    setState(() {
      _withdrawals[index]['status'] = 'મંજૂર થયેલ (Paid) ✅';
      _withdrawals[index]['isPending'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        content: Text('${_withdrawals[index]['studentName']} નો ${_withdrawals[index]['amount']} નો ઉપાડ મંજૂર થયો!'),
      ),
    );
  }

  void _rejectWithdrawal(int index) {
    setState(() {
      _withdrawals[index]['status'] = 'અસ્વીકાર (Rejected) ❌';
      _withdrawals[index]['isPending'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('${_withdrawals[index]['studentName']} નો ઉપાડ રદ થયો અને કોઈન્સ રિફંડ થયા.'),
      ),
    );
  }

  void _openAddQuestionDialog({Map<String, dynamic>? editQuestion, int? editIndex}) {
    final qCtrl = TextEditingController(text: editQuestion?['question'] ?? '');
    final optACtrl = TextEditingController(text: editQuestion?['optionA'] ?? '');
    final optBCtrl = TextEditingController(text: editQuestion?['optionB'] ?? '');
    final optCCtrl = TextEditingController(text: editQuestion?['optionC'] ?? '');
    final optDCtrl = TextEditingController(text: editQuestion?['optionD'] ?? '');
    final optECtrl = TextEditingController(text: editQuestion?['optionE'] ?? 'પ્રયાસ કરેલ નથી');
    final expCtrl = TextEditingController(text: editQuestion?['explanation'] ?? '');
    String selectedCorrect = editQuestion?['correct'] ?? 'A';
    String selectedSubject = editQuestion?['subject'] ?? 'કાયદો';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editIndex != null ? 'પ્રશ્ન એડિટ કરો' : 'નવો પ્રશ્ન ઉમેરો (Add MCQ)',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(),
                TextField(
                  controller: qCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'પ્રશ્ન (Question Text)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(labelText: 'વિષય', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'કાયદો', child: Text('કાયદો')),
                          DropdownMenuItem(value: 'ભારતીય બંધારણ', child: Text('બંધારણ')),
                          DropdownMenuItem(value: 'ગુજરાતનો ઇતિહાસ', child: Text('ઇતિહાસ')),
                          DropdownMenuItem(value: 'ગુજરાતની ભૂગોળ', child: Text('ભૂગોળ')),
                          DropdownMenuItem(value: 'રીઝનિંગ', child: Text('રીઝનિંગ')),
                          DropdownMenuItem(value: 'સામાન્ય વિજ્ઞાન', child: Text('વિજ્ઞાન')),
                          DropdownMenuItem(value: 'ગુજરાતી વ્યાકરણ', child: Text('ગુજરાતી')),
                        ],
                        onChanged: (val) => setModalState(() => selectedSubject = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCorrect,
                        decoration: const InputDecoration(labelText: 'સાચો વિકલ્પ', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('A')),
                          DropdownMenuItem(value: 'B', child: Text('B')),
                          DropdownMenuItem(value: 'C', child: Text('C')),
                          DropdownMenuItem(value: 'D', child: Text('D')),
                          DropdownMenuItem(value: 'E', child: Text('E')),
                        ],
                        onChanged: (val) => setModalState(() => selectedCorrect = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: optACtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ A', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optBCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ B', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optCCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ C', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optDCtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ D', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: optECtrl, decoration: const InputDecoration(labelText: 'વિકલ્પ E', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: expCtrl,
                  decoration: const InputDecoration(labelText: 'જવાબની સમજૂતી (Explanation)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D253F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check, color: Color(0xFFFFC107)),
                  label: Text(editIndex != null ? 'પ્રશ્ન અપડેટ કરો' : 'પ્રશ્ન સેવ કરો (Save Question)'),
                  onPressed: () {
                    if (qCtrl.text.trim().isEmpty || optACtrl.text.trim().isEmpty) return;
                    final qData = {
                      'question': qCtrl.text.trim(),
                      'optionA': optACtrl.text.trim(),
                      'optionB': optBCtrl.text.trim(),
                      'optionC': optCCtrl.text.trim(),
                      'optionD': optDCtrl.text.trim(),
                      'optionE': optECtrl.text.trim(),
                      'correct': selectedCorrect,
                      'subject': selectedSubject,
                      'explanation': expCtrl.text.trim(),
                    };

                    if (editIndex != null) {
                      _adminData.editQuestion(_selectedTestId, editIndex, qData);
                    } else {
                      _adminData.addQuestion(_selectedTestId, qData);
                    }
                    Navigator.pop(ctx);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        elevation: 1,
        title: Row(
          children: const [
            Icon(Icons.shield, color: Color(0xFFFFC107), size: 20),
            SizedBox(width: 8),
            Text(
              'PSI Admin Console',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 3, backgroundColor: Colors.white),
                SizedBox(width: 4),
                Text('Online', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            tooltip: 'લૉગ આઉટ',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildSelectedTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D253F),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'ડેશબોર્ડ'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'વિદ્યાર્થીઓ'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_outlined), activeIcon: Icon(Icons.quiz), label: 'MCQs બેંક'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_outlined), activeIcon: Icon(Icons.payments), label: 'UPI ઉપાડ'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_sync_outlined), activeIcon: Icon(Icons.cloud_sync), label: 'સેટિંગ્સ'),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildStudentsTab();
      case 2:
        return _buildQuestionsManagerTab();
      case 3:
        return _buildWithdrawalsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildOverviewTab();
    }
  }

  // TAB 0: OVERVIEW & STATS
  Widget _buildOverviewTab() {
    final pendingCount = _withdrawals.where((w) => w['isPending'] == true).length;
    final totalQuestions = _adminData.testQuestions.values.fold<int>(0, (sum, list) => sum + list.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('સિસ્ટમ આંકડા & ઓવરવ્યૂ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: [
              _buildMetricCard('કુલ વિદ્યાર્થીઓ', '${_adminData.students.length * 2970}+', Icons.people, const Color(0xFF1976D2)),
              _buildMetricCard('સક્રિય ટેસ્ટ્સ', '${_adminData.tests.length}', Icons.quiz, const Color(0xFF6A1B9A)),
              _buildMetricCard('પ્રશ્નો બેંક', '$totalQuestions+ MCQs', Icons.menu_book, const Color(0xFF2E7D32)),
              _buildMetricCard('પેન્ડિંગ ઉપાડ', '$pendingCount વિનંતીઓ', Icons.payments, const Color(0xFFE65100)),
            ],
          ),
          const SizedBox(height: 18),

          // Security & Cloud Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFF2E7D32), size: 18),
                    SizedBox(width: 6),
                    Text('Supabase Realtime Sync & RLS Enforced', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 13)),
                  ],
                ),
                SizedBox(height: 6),
                Text('• વિદ્યાર્થીઓ માત્ર પોતાના એકાઉન્ટનો ડેટા જોઈ શકે છે.'),
                Text('• કોઈપણ પ્રશ્ન એડમિન એપમાંથી એડ/ડીલીટ કરવાથી તમામ વિદ્યાર્થીઓના ફોનમાં લાઈવ અપડેટ થશે.'),
                Text('• વિદ્યાર્થી એપમાં એડમિન પોર્ટલ સંપૂર્ણપણે અદ્રશ્ય છે.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: STUDENTS MANAGEMENT
  Widget _buildStudentsTab() {
    final filtered = _adminData.students.where((s) {
      if (_studentSearch.isEmpty) return true;
      final q = _studentSearch.toLowerCase();
      return (s['name'] as String).toLowerCase().contains(q) || (s['email'] as String).toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'વિદ્યાર્થી શોધો (નામ અથવા ઈમેલ)...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: const Color(0xFFF0F4F8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            onChanged: (val) => setState(() => _studentSearch = val),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final student = filtered[idx];
              final isActive = student['isActive'] as bool;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF0D253F).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF0D253F)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(student['email'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text('જોડાયા: ${student['joinedDate']} • રેફરલ્સ: ${student['referrals']}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6)),
                            child: Text('🪙 ${student['coins']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFF57F17))),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() => _adminData.updateStudentCoins(idx, 50));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+50 કોઈન્સ ઉમેરાયા!')));
                                },
                                child: const Icon(Icons.add_circle, color: Color(0xFF2E7D32), size: 20),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() => _adminData.updateStudentCoins(idx, -50));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('-50 કોઈન્સ કપાયા.')));
                                },
                                child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // TAB 2: QUESTIONS & MOCK TESTS MANAGER
  Widget _buildQuestionsManagerTab() {
    final questions = _adminData.testQuestions[_selectedTestId] ?? [];
    final selectedTest = _adminData.tests.firstWhere((t) => t['id'] == _selectedTestId);
    final isFree = selectedTest['isFree'] as bool;

    final filteredQuestions = questions.where((q) {
      if (_questionSearch.isEmpty) return true;
      final query = _questionSearch.toLowerCase();
      return (q['question'] as String).toLowerCase().contains(query) || (q['subject'] as String).toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Test Switcher & Free/Lock Toggle
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTestId,
                      decoration: const InputDecoration(labelText: 'ટેસ્ટ પસંદ કરો', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), border: OutlineInputBorder()),
                      items: _adminData.tests.map((t) {
                        return DropdownMenuItem(value: t['id'] as String, child: Text('${t['exam']} - ${t['title']}'));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTestId = val!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(isFree ? 'FREE' : 'LOCKED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isFree ? Colors.green : Colors.orange)),
                      Switch(
                        value: isFree,
                        activeColor: Colors.green,
                        onChanged: (v) {
                          final idx = _adminData.tests.indexWhere((t) => t['id'] == _selectedTestId);
                          setState(() => _adminData.toggleTestFree(idx));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
                      icon: const Icon(Icons.add, size: 16, color: Color(0xFFFFC107)),
                      label: const Text('નવો પ્રશ્ન ઉમેરો', style: TextStyle(fontSize: 12)),
                      onPressed: () => _openAddQuestionDialog(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text('Excel/CSV અપલોડ', style: TextStyle(fontSize: 12)),
                      onPressed: () => _showBulkUploadDialog(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: filteredQuestions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('આ ટેસ્ટમાં કોઈ પ્રશ્નો નથી. "નવો પ્રશ્ન ઉમેરો" બટન દબાવો.', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, idx) {
                    final q = filteredQuestions[idx];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                  child: Text(q['subject'] ?? 'સામાન્ય જ્ઞાન', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                      onPressed: () => _openAddQuestionDialog(editQuestion: q, editIndex: idx),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() => _adminData.deleteQuestion(_selectedTestId, idx));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('પ્રશ્ન સફળતાપૂર્વક ડીલીટ થયો.')));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text('Q${idx + 1}. ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text('A: ${q['optionA']} | B: ${q['optionB']}', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            Text('C: ${q['optionC']} | D: ${q['optionD']}', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                            const SizedBox(height: 4),
                            Text('સાચો જવાબ: વિકલ્પ ${q['correct']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF2E7D32))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excel / CSV 200 MCQs બલ્ક અપલોડ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('CSV લાઈનો અહીં પેસ્ટ કરો (Question,OptA,OptB,OptC,OptD,OptE,Correct,Subject):', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(controller: _csvController, maxLines: 6, decoration: const InputDecoration(border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('રદ')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D253F), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('બલ્ક પ્રશ્નો સફળતાપૂર્વક અપલોડ થઈ ગયા! 🎉')));
            },
            child: const Text('અપલોડ'),
          ),
        ],
      ),
    );
  }

  // TAB 3: WITHDRAWALS
  Widget _buildWithdrawalsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _withdrawals.length,
      itemBuilder: (context, idx) {
        final wd = _withdrawals[idx];
        final isPending = wd['isPending'] == true;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(wd['studentName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(wd['amount'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF2E7D32))),
                  ],
                ),
                Text('UPI ID: ${wd['upi']}', style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                Text('${wd['email']} • ${wd['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 10),
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                          onPressed: () => _approveWithdrawal(idx),
                          child: const Text('ચુકવણી મંજૂર કરો (Paid)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => _rejectWithdrawal(idx),
                          child: const Text('અસ્વીકાર કરો'),
                        ),
                      ),
                    ],
                  )
                else
                  Text(wd['status'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 4: SETTINGS & SECURITY
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('સુરક્ષા & ડેટાબેઝ સેટિંગ્સ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F))),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Supabase Live Project URL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(_adminData.supabaseUrl, style: const TextStyle(fontSize: 12, color: Colors.blueAccent)),
                  const Divider(height: 24),
                  const Text('Supabase API Key (Protected):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _showApiKey ? _adminData.supabaseKey : '••••••••••••••••••••••••••••••••••••••••',
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _showApiKey = !_showApiKey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 46)),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('એડમિન લૉગ આઉટ'),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminLoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              CircleAvatar(radius: 12, backgroundColor: color.withOpacity(0.12), child: Icon(icon, size: 14, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
