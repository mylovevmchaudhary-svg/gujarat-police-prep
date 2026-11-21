import 'package:flutter/material.dart';
import '../models/exam_category.dart';
import '../models/wallet_model.dart';
import 'excel_csv_uploader.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0; // 0: Overview, 1: Excel Upload, 2: Tests, 3: Users, 4: Notification
  final _wallet = WalletManager();

  // Excel / CSV State
  String _selectedExamId = 'constable';
  int _targetTestNumber = 4;
  final TextEditingController _csvInputController = TextEditingController();
  int _parsedCount = 0;
  bool _isUploadSuccess = false;

  @override
  void initState() {
    super.initState();
    _csvInputController.text = CsvQuestionParser.getSampleCsvTemplate();
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

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
              'ગુજરાત પોલીસ એડમિન પોર્ટલ (Admin Portal)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Colors.greenAccent),
                SizedBox(width: 6),
                Text('સિસ્ટમ ઓનલાઇન', style: TextStyle(fontSize: 11, color: Colors.white)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'લૉગ આઉટ',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar for desktop / web
          if (isWideScreen)
            Container(
              width: 240,
              color: Colors.white,
              child: _buildSidebar(),
            ),

          // Main Content View
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildSelectedContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? BottomNavigationBar(
              currentIndex: _selectedNavIndex,
              onTap: (idx) => setState(() => _selectedNavIndex = idx),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0D253F),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'ડેશબોર્ડ'),
                BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Excel અપલોડ'),
                BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'મોક ટેસ્ટ'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'યૂઝર્સ'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'નોટિફિકેશન'),
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
        _buildSidebarItem(1, Icons.upload_file_outlined, 'Excel/CSV પ્રશ્નો અપલોડ'),
        _buildSidebarItem(2, Icons.quiz_outlined, '500 મોક ટેસ્ટ મેનેજર'),
        _buildSidebarItem(3, Icons.people_outline, 'વિદ્યાર્થીઓ & વૉલેટ'),
        _buildSidebarItem(4, Icons.notifications_active_outlined, 'પુશ નોટિફિકેશન'),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
          title: const Text('એપ પર પાછા જાઓ', style: TextStyle(color: Colors.redAccent)),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedNavIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: const Color(0xFF0D253F).withOpacity(0.08),
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF0D253F) : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF0D253F) : Colors.black87,
        ),
      ),
      onTap: () => setState(() => _selectedNavIndex = index),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return _buildExcelUploadContent();
      case 2:
        return _buildMockTestManagerContent();
      case 3:
        return _buildUsersWalletContent();
      case 4:
        return _buildNotificationContent();
      default:
        return _buildOverviewContent();
    }
  }

  // 1. Overview Content
  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'સિસ્ટમ ઓવરવ્યૂ (Live Statistics)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricBox('કુલ મોક ટેસ્ટ', '500+', '6 પરીક્ષાઓમાં', Icons.quiz, const Color(0xFF1976D2))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetricBox('પ્રશ્ન બેંક', '100,000+', '200 MCQs પ્રતિ ટેસ્ટ', Icons.menu_book, const Color(0xFF2E7D32))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetricBox('નોંધાયેલ ઉમેદવારો', '14,850', 'સક્રિય વિદ્યાર્થીઓ', Icons.people, const Color(0xFFE65100))),
            const SizedBox(width: 14),
            Expanded(child: _buildMetricBox('એડ્સ આવક (Est.)', '₹52,400', 'રિવોર્ડેડ વિડિઓ એડ્સ', Icons.monetization_on, const Color(0xFF6A1B9A))),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        const Text(
          'ઝડપી કામગીરી (Quick Actions)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D253F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('નવી 200 MCQs Excel ફાઈલ અપલોડ કરો'),
              onPressed: () => setState(() => _selectedNavIndex = 1),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.send),
              label: const Text('તમામ વિદ્યાર્થીઓને નોટિફિકેશન મોકલો'),
              onPressed: () => setState(() => _selectedNavIndex = 4),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Excel / CSV Upload Content
  Widget _buildExcelUploadContent() {
    final categories = ExamCategory.getCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Excel / CSV ફાઈલ દ્વારા 200 પ્રશ્નોનું બલ્ક અપલોડ 📂',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 6),
        const Text(
          'તમે MS Excel કે Google Sheets માંથી પ્રશ્નો સીધા અહીં પેસ્ટ અથવા અપલોડ કરી શકો છો.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 18),

        if (_isUploadSuccess) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E7D32)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'અભિનંદન! મોક ટેસ્ટ #$_targetTestNumber માં $_parsedCount પ્રશ્નો સફળતાપૂર્વક અપલોડ અને સેવ થઈ ગયા છે! 🎉',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],

        // Target Configuration Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedExamId,
                  decoration: const InputDecoration(
                    labelText: 'પરીક્ષા પસંદ કરો',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat.id, child: Text(cat.titleGujarati));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedExamId = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: '$_targetTestNumber',
                  decoration: const InputDecoration(
                    labelText: 'કયા મોક ટેસ્ટ નંબરમાં અપલોડ કરવું છે? (1 થી 500)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    _targetTestNumber = int.tryParse(val.trim()) ?? 1;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // CSV Text / File Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CSV ડેટા અથવા Excel કોલમ્સ અહીં પેસ્ટ કરો:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('સેમ્પલ ટેમ્પલેટ લોડ કરો'),
                    onPressed: () {
                      setState(() {
                        _csvInputController.text = CsvQuestionParser.getSampleCsvTemplate();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _csvInputController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Question,OptionA,OptionB,OptionC,OptionD,OptionE,CorrectOption,Subject,Explanation...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D253F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text(
                      'ચકાસો અને અપલોડ કરો (Upload 200 MCQs)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final parsed = CsvQuestionParser.parseCsv(_csvInputController.text);
                      setState(() {
                        _parsedCount = parsed.length;
                        _isUploadSuccess = true;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.clear),
                    label: const Text('ક્લિયર'),
                    onPressed: () {
                      setState(() {
                        _csvInputController.clear();
                        _isUploadSuccess = false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Mock Test Manager Content
  Widget _buildMockTestManagerContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '500 મોક ટેસ્ટ મેનેજર (Free & Locked Settings)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: List.generate(6, (idx) {
              final testNum = idx + 1;
              final isFree = testNum <= 3;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  child: Text('$testNum', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                title: Text('મોક ટેસ્ટ #$testNum (200 MCQs • 180 મિનિટ)'),
                subtitle: Text(isFree ? 'મફત ટેસ્ટ (તમામ વિદ્યાર્થીઓ માટે ખુલ્લું)' : 'પ્રીમિયમ ટેસ્ટ (એડ્સ/કોઈન્સ જરૂરી)'),
                trailing: Chip(
                  label: Text(isFree ? 'FREE' : 'LOCKED'),
                  backgroundColor: isFree ? const Color(0xFFC8E6C9) : const Color(0xFFFFE0B2),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // 4. Users & Wallet Content
  Widget _buildUsersWalletContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'વિદ્યાર્થીઓ અને વૉલેટ કોઈન્સ મેનેજમેન્ટ 🪙',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              ListTile(
                title: const Text('રેફરલ રિવોર્ડ બોનસ'),
                subtitle: const Text('મિત્રને જોડવા પર મળતા કોઈન્સ'),
                trailing: Text('+50 Coins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
              ),
              const Divider(),
              ListTile(
                title: const Text('વિડિઓ એડ રિવોર્ડ બોનસ'),
                subtitle: const Text('પ્રત્યેક સ્પોન્સર્ડ એડ જોવા પર'),
                trailing: Text('+5 Coins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE65100))),
              ),
              const Divider(),
              ListTile(
                title: const Text('ડેઇલી ચેક-ઇન બોનસ'),
                subtitle: const Text('દરરોજ એપ ઓપન કરવા પર'),
                trailing: Text('+15 Coins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1976D2))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Notification Sender Content
  Widget _buildNotificationContent() {
    final titleCtrl = TextEditingController(text: '🚨 નવી મોક ટેસ્ટ લાઈવ થઈ!');
    final msgCtrl = TextEditingController(text: 'કોન્સ્ટેબલ અને PSI ના 200 મહત્વપૂર્ણ પ્રશ્નોની નવી ટેસ્ટ લાઈવ થઈ ગઈ છે. હમણાં જ આપો!');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'પુશ નોટિફિકેશન બ્રોડકાસ્ટર 📢',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
        ),
        const SizedBox(height: 6),
        const Text(
          'તમામ વિદ્યાર્થીઓના મોબાઇલમાં સીધું નોટિફિકેશન મોકલો.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'નોટિફિકેશન ટાઇટલ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'મેસેજ વિગત', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D253F),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.send),
                label: const Text('તમામ વિદ્યાર્થીઓને બ્રોડકાસ્ટ કરો', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF2E7D32),
                      content: Text('પુશ નોટિફિકેશન તમામ વિદ્યાર્થીઓને સફળતાપૂર્વક મોકલાઈ ગયું! 🚀'),
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

  Widget _buildMetricBox(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
