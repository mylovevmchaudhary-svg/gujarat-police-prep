import 'package:flutter/material.dart';
import 'admin_data_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final _adminData = AdminDataManager();

  // Excel Uploader Controllers
  final _csvController = TextEditingController();
  String _selectedExam = 'કોન્સ્ટેબલ (LRD)';
  int _targetTestNum = 4;
  int _uploadedCount = 0;
  bool _uploadSuccess = false;

  // Supabase Config Controllers
  late TextEditingController _urlController;
  late TextEditingController _keyController;

  // Withdrawal Requests list managed by Admin
  final List<Map<String, dynamic>> _withdrawals = [
    {
      'id': 'wd_101',
      'studentName': 'રમેશ ચૌધરી',
      'email': 'ramesh@gmail.com',
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
      'email': 'bhavik@gmail.com',
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
      'email': 'pooja@gmail.com',
      'amount': '₹100.00',
      'coins': 1000,
      'upi': 'poojathakor@ybl',
      'status': 'પેન્ડિંગ (Pending)',
      'isPending': true,
      'date': 'આજે 02:15 PM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _adminData.supabaseUrl);
    _keyController = TextEditingController(text: _adminData.supabaseKey);
    _csvController.text = '''Question,OptionA,OptionB,OptionC,OptionD,OptionE,CorrectOption,Subject,Explanation
"IPC ની કલમ 378 મુજબ ચોરીની વ્યાખ્યા શું છે?","જંગમ મિલકતની ચોરી","સ્થાવર મિલકત","માત્ર નાણાં","માત્ર દાગીના","પ્રયાસ કરેલ નથી",A,"કાયદો","કલમ 378 માં વ્યાખ્યા અને 379 માં સજા છે."
"બંધારણના કયા અનુચ્છેદ મુજબ કાયદા સમક્ષ સમાનતા છે?","અનુચ્છેદ 14","અનુચ્છેદ 19","અનુચ્છેદ 21","અનુચ્છેદ 32","પ્રયાસ કરેલ નથી",A,"બંધારણ","અનુચ્છેદ 14 કાયદા સમક્ષ સમાનતા સુનિશ્ચિત કરે છે."''';
  }

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        elevation: 1,
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, color: Color(0xFFFFC107)),
            SizedBox(width: 8),
            Text(
              'ગુજરાત પોલીસ માસ્ટર એડમિન (Admin Panel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 4,
                  backgroundColor: _adminData.isConnectedToSupabase ? Colors.greenAccent : Colors.amberAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  _adminData.isConnectedToSupabase ? 'Supabase Live' : 'ઓફલાઇન / લોકલ',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'પાછા જાઓ',
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            Container(
              width: 250,
              color: Colors.white,
              child: _buildSidebar(),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildBody(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0D253F),
              selectedFontSize: 11,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'ડેશબોર્ડ'),
                BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'પેમેન્ટ ઉપાડ'),
                BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'MCQs'),
                BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'ટેસ્ટ'),
                BottomNavigationBarItem(icon: Icon(Icons.cloud_sync), label: 'Supabase'),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebar() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildSidebarItem(0, Icons.dashboard_outlined, 'ઓવરવ્યૂ ડેશબોર્ડ'),
        _buildSidebarItem(1, Icons.payments_outlined, 'પેમેન્ટ ઉપાડ વિનંતીઓ (UPI)'),
        _buildSidebarItem(2, Icons.upload_file_outlined, 'Excel/CSV 200 MCQs અપલોડ'),
        _buildSidebarItem(3, Icons.quiz_outlined, 'મોક ટેસ્ટ મેનેજર (Free/Lock)'),
        _buildSidebarItem(4, Icons.cloud_sync_outlined, 'Supabase ડેટાબેઝ સેટિંગ્સ'),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _currentIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFF0D253F).withOpacity(0.08),
      leading: Icon(icon, color: isSelected ? const Color(0xFF0D253F) : Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF0D253F) : Colors.black87,
        ),
      ),
      onTap: () => setState(() => _currentIndex = index),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return _buildWithdrawalsManager();
      case 2:
        return _buildExcelUpload();
      case 3:
        return _buildTestsManager();
      case 4:
        return _buildSupabaseConfig();
      default:
        return _buildOverview();
    }
  }

  // 1. Overview
  Widget _buildOverview() {
    final pendingCount = _withdrawals.where((w) => w['isPending'] == true).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'સિસ્ટમ ઓવરવ્યૂ & લાઇવ આંકડા',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetric('નોંધાયેલ ઉમેદવારો', '${_adminData.totalStudents}', Icons.people, const Color(0xFF1976D2))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetric('પેન્ડિંગ ઉપાડ', '$pendingCount વિનંતીઓ', Icons.payments, const Color(0xFFE65100))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetric('કુલ પ્રશ્ન બેંક', '${_adminData.totalQuestionsInBank}+ MCQs', Icons.menu_book, const Color(0xFF2E7D32))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetric('સક્રિય મોક ટેસ્ટ', '${_adminData.tests.length}', Icons.quiz, const Color(0xFF6A1B9A))),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Notice Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('એડમિન કંટ્રોલ ફીચર્સ (Live Synchronization):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 8),
              Text('• કોઈપણ ટેસ્ટને Free અથવા Locked કરવાથી યુઝર એપમાં તાત્કાલિક બદલાવ જોવા મળશે.'),
              Text('• Excel/CSV દ્વારા પ્રશ્નો ઉમેરવાથી Supabase માં સીધા જમા થશે.'),
              Text('• વિદ્યાર્થીઓ રેફરલ કમાણીમાંથી પૈસા ઉપાડવાની વિનંતી કરશે તે "પેમેન્ટ ઉપાડ" ટેબમાં દેખાશે, જ્યાંથી તમે UPI દ્વારા ચુકવણી મંજૂર કરી શકો છો.'),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Withdrawals Manager Tab
  Widget _buildWithdrawalsManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'વિદ્યાર્થી પેમેન્ટ ઉપાડ વિનંતીઓ (UPI Withdrawals)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 6),
        const Text('વિદ્યાર્થીઓ દ્વારા રેફરલ કોઈન્સમાંથી રોકડ ઉપાડની અરજીઓ:', style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _withdrawals.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final wd = _withdrawals[idx];
              final isPending = wd['isPending'] == true;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isPending ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                      child: Icon(
                        isPending ? Icons.hourglass_top : Icons.check_circle,
                        color: isPending ? Colors.orange : Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(wd['studentName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              Text('(${wd['coins']} કોઈન્સ)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('UPI ID: ${wd['upi']} • ${wd['email']}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          const SizedBox(height: 2),
                          Text('તારીખ: ${wd['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          wd['amount'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 6),
                        if (isPending)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: () => _approveWithdrawal(idx),
                                child: const Text('મંજૂર કરો', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 6),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: () => _rejectWithdrawal(idx),
                                child: const Text('રદ કરો', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          )
                        else
                          Text(
                            wd['status'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Excel / CSV Upload
  Widget _buildExcelUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Excel / CSV ફાઈલથી 200 MCQs અપલોડ કરો 📂',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 14),
        if (_uploadSuccess) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              'સફળતા! $_selectedExam ની મોક ટેસ્ટ #$_targetTestNum માં $_uploadedCount પ્રશ્નો અપલોડ થઈ ગયા! 🎉',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedExam,
                      decoration: const InputDecoration(labelText: 'પરીક્ષા પસંદ કરો', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'કોન્સ્ટેબલ (LRD)', child: Text('ગુજરાત પોલીસ કોન્સ્ટેબલ (LRD)')),
                        DropdownMenuItem(value: 'PSI / ASI', child: Text('પોલીસ સબ ઇન્સ્પેક્ટર (PSI & ASI)')),
                      ],
                      onChanged: (val) => setState(() => _selectedExam = val!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      initialValue: '$_targetTestNum',
                      decoration: const InputDecoration(labelText: 'ટેસ્ટ નંબર', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _targetTestNum = int.tryParse(val) ?? 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Excel / CSV ફોર્મેટ ડેટા પેસ્ટ કરો:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _csvController,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D253F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('200 પ્રશ્નો સેવ & અપલોડ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  final lines = _csvController.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
                  setState(() {
                    _uploadedCount = lines.length > 1 ? lines.length - 1 : 1;
                    _uploadSuccess = true;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Tests Manager
  Widget _buildTestsManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'મોક ટેસ્ટ મેનેજર (Free / Lock કંટ્રોલ)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _adminData.tests.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final test = _adminData.tests[idx];
              final isFree = test['isFree'] as bool;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  child: Icon(isFree ? Icons.lock_open : Icons.lock, color: isFree ? Colors.green : Colors.orange),
                ),
                title: Text('${test['exam']} - ${test['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('200 MCQs • ${isFree ? "મફત ટેસ્ટ" : "પ્રીમિયમ (એડ્સ/કોઈન્સ જરૂરી)"}'),
                trailing: Switch(
                  value: isFree,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      _adminData.toggleTestFree(idx);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 5. Supabase Config
  Widget _buildSupabaseConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supabase Cloud Database કનેક્શન ⚡',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 6),
        const Text('Supabase.com પરથી તમારા ફ્રી પ્રોજેક્ટના URL અને API Key અહીં નાખો:', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Supabase Project URL',
                  hintText: 'https://xyzcompany.supabase.co',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _keyController,
                decoration: const InputDecoration(
                  labelText: 'Supabase Anon Public API Key',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('કનેક્શન સેવ કરો અને સિંક કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() {
                    _adminData.saveSupabaseConfig(_urlController.text.trim(), _keyController.text.trim());
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF2E7D32),
                      content: Text('Supabase સેટિંગ્સ સેવ થઈ ગઈ! 🎉'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              CircleAvatar(radius: 12, backgroundColor: color.withOpacity(0.12), child: Icon(icon, size: 14, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
