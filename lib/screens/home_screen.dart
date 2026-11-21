import 'package:flutter/material.dart';
import '../models/exam_category.dart';
import '../models/wallet_model.dart';
import 'bookmarks_screen.dart';
import 'test_series_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _wallet = WalletManager();
  final List<ExamCategory> _categories = ExamCategory.getCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D253F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ગુજરાત પોલીસ તૈયારી',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'મિશન ખાખી 2026 👮‍♂️',
              style: TextStyle(fontSize: 11, color: Color(0xFFFFC107)),
            ),
          ],
        ),
        actions: [
          // Coins indicator button (navigates to wallet tab)
          InkWell(
            onTap: () => widget.onTabChange(3), // Index 3 is Wallet
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            tooltip: 'સાચવેલા પ્રશ્નો',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational Khakhi Banner
            _buildHeroBanner(),
            const SizedBox(height: 20),

            // Section Header: Exam Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'પરીક્ષાઓ પસંદ કરો (Select Exam)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
                Text(
                  '${_categories.length} પરીક્ષાઓ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exam Cards Grid (Constable, PSI, ASI, Forest, Jail Sipahi, CCE)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildExamCard(category);
              },
            ),
            const SizedBox(height: 20),

            // Quick Study Tips Card
            _buildDailyTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D253F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🔥 500+ મોક ટેસ્ટ ઉપલબ્ધ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.lock_open, size: 14, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    'પ્રથમ 3 ટેસ્ટ મફત!',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ગુજરાત પોલીસ ભરતી 2026',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'દરેક મોક ટેસ્ટમાં 200 પ્રશ્નો • 180 મિનિટ • નેગેટિવ માર્કિંગ 0.25',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: const Color(0xFF0D253F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text(
                  'મોક ટેસ્ટ આપો',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => widget.onTabChange(1), // Go to Mock Tests Tab
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.menu_book, size: 16),
                label: const Text('સિલેબસ જુઓ'),
                onPressed: () => widget.onTabChange(2), // Go to Syllabus Tab
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(ExamCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Open 500 Mock Tests for this specific exam
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestSeriesScreen(category: category),
            ),
          ).then((_) => setState(() {}));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.primaryColor, category.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: category.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(category.icon, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),

              // Title & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category.titleGujarati,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0D253F),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: category.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            category.badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: category.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.quiz_outlined, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          category.totalTestsCount,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('• 3 ફ્રી મોક ટેસ્ટ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD54F)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFFF57F17)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'પરીક્ષા પદ્ધતિ (Exam Pattern): 200 ગુણ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFF57F17)),
                ),
                SizedBox(height: 4),
                Text(
                  'કુલ સમય: 180 મિનિટ (3 કલાક). જો જવાબ ન આવડતો હોય તો વિકલ્પ "E" ટીક કરો જેથી -0.25 માર્ક્સ કપાય નહીં.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
