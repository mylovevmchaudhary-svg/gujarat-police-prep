import 'package:flutter/material.dart';
import '../data/question_bank_generator.dart';
import '../models/exam_category.dart';
import '../models/wallet_model.dart';
import 'quiz_screen.dart';

class TestSeriesScreen extends StatefulWidget {
  final ExamCategory? category;

  const TestSeriesScreen({super.key, this.category});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  final _wallet = WalletManager();
  late ExamCategory _selectedCategory;
  String _activeFilter = 'All'; // 'All', 'Free', 'Unlocked'
  final TextEditingController _searchController = TextEditingController();
  int _searchTestNumber = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category ?? ExamCategory.getCategories().first;
  }

  void _showUnlockDialog(int testNumber) {
    final testId = '${_selectedCategory.id}_$testNumber';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFFE65100)),
            const SizedBox(width: 8),
            Text(
              'મોક ટેસ્ટ #$testNumber અનલોક કરો',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'આ પ્રીમિયમ ટેસ્ટમાં 200 સિલેબસ આધારિત પ્રશ્નો અને 180 મિનિટનો સમય છે.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('તમારું બેલેન્સ:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${_wallet.coins} કોઈન્સ 🪙',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D253F)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Option 1: Watch Ad to unlock
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D253F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.play_circle_fill, color: Color(0xFFFFC107)),
            label: const Text('વિડિઓ એડ જોઈને ફ્રી અનલોક કરો'),
            onPressed: () {
              Navigator.pop(ctx);
              _simulateWatchAd(testNumber);
            },
          ),
          const SizedBox(height: 8),

          // Option 2: Unlock with Coins
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
            label: const Text('10 કોઈન્સ વાપરીને અનલોક કરો'),
            onPressed: () {
              if (_wallet.unlockWithCoins(testId, 10)) {
                Navigator.pop(ctx);
                setState(() {});
                _startTest(testNumber);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('તમારી પાસે પૂરતા કોઈન્સ નથી! એડ જોઈને કમાઓ.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _simulateWatchAd(int testNumber) {
    final testId = '${_selectedCategory.id}_$testNumber';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFFC107)),
                  SizedBox(height: 12),
                  Text(
                    'Sponsored Ad • ટેસ્ટ અનલોક થઈ રહ્યો છે...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // close ad
        _wallet.unlockWithAd(testId);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('મોક ટેસ્ટ #$testNumber સફળતાપૂર્વક અનલોક થઈ ગઈ! 🎉 (+5 બોનસ કોઈન્સ)'),
          ),
        );
        _startTest(testNumber);
      }
    });
  }

  void _startTest(int testNumber) {
    final test = QuestionBankGenerator.generateMockTest(
      examCategoryId: _selectedCategory.id,
      examTitle: _selectedCategory.titleGujarati,
      testNumber: testNumber,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(test: test)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 500 Mock Tests
    const totalTests = 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedCategory.titleGujarati,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            const Text(
              '500 મોક ટેસ્ટ સીરીઝ (200 MCQs • 180 મિનિટ)',
              style: TextStyle(fontSize: 11, color: Color(0xFFFFC107)),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Color(0xFFFFC107)),
                const SizedBox(width: 4),
                Text(
                  '${_wallet.coins}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs & Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'ટેસ્ટ નંબર શોધો (દા.ત. 1 થી 500)...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchTestNumber = 0;
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF0F4F8),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchTestNumber = int.tryParse(val.trim()) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('બધા (500)', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('ફ્રી ટેસ્ટ (3)', 'Free'),
                    const SizedBox(width: 8),
                    _buildFilterChip('અનલોક થયેલ', 'Unlocked'),
                  ],
                ),
              ],
            ),
          ),

          // 500 Mock Tests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchTestNumber > 0 && _searchTestNumber <= totalTests ? 1 : totalTests,
              itemBuilder: (context, index) {
                final testNum = _searchTestNumber > 0 ? _searchTestNumber : (index + 1);
                final testId = '${_selectedCategory.id}_$testNum';
                final isUnlocked = _wallet.isTestUnlocked(testId, testNum);
                final isFree = testNum <= 3;

                if (_activeFilter == 'Free' && !isFree) return const SizedBox.shrink();
                if (_activeFilter == 'Unlocked' && !isUnlocked) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Test Badge / Number Circle
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isFree
                                ? const Color(0xFF2E7D32).withOpacity(0.12)
                                : (isUnlocked
                                    ? const Color(0xFF1976D2).withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12)),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isFree
                                  ? Icons.card_giftcard
                                  : (isUnlocked ? Icons.lock_open : Icons.lock),
                              color: isFree
                                  ? const Color(0xFF2E7D32)
                                  : (isUnlocked ? const Color(0xFF1976D2) : const Color(0xFFE65100)),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'મોક ટેસ્ટ #$testNum',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF0D253F),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isFree ? 'મફત (Free)' : (isUnlocked ? 'અનલોક' : 'પ્રીમિયમ'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isFree ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '200 પ્રશ્નો • 180 મિનિટ • 200 ગુણ',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        // CTA Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUnlocked ? const Color(0xFF0D253F) : const Color(0xFFE65100),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: () {
                            if (isUnlocked) {
                              _startTest(testNum);
                            } else {
                              _showUnlockDialog(testNum);
                            }
                          },
                          child: Text(
                            isUnlocked ? 'શરૂ કરો' : 'અનલોક',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _activeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D253F) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D253F) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
