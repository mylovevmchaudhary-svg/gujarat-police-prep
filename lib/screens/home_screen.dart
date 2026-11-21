import 'package:flutter/material.dart';
import '../data/syllabus_data.dart';
import '../models/exam_type.dart';
import '../models/syllabus_model.dart';
import 'bookmarks_screen.dart';
import 'syllabus_screen.dart';
import 'test_series_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ExamType _selectedExam = ExamType.constable;
  late List<SyllabusSubject> _currentSyllabus;

  @override
  void initState() {
    super.initState();
    _currentSyllabus = SyllabusData.getSyllabus(_selectedExam);
  }

  void _onExamChanged(ExamType newExam) {
    setState(() {
      _selectedExam = newExam;
      _currentSyllabus = SyllabusData.getSyllabus(newExam);
    });
  }

  int get _totalTopics =>
      _currentSyllabus.fold(0, (sum, subj) => sum + subj.topics.length);

  int get _completedTopics =>
      _currentSyllabus.fold(0, (sum, subj) => sum + subj.completedTopicsCount);

  double get _overallProgress =>
      _totalTopics == 0 ? 0.0 : (_completedTopics / _totalTopics);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D253F), // Police Navy Blue
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ગુજરાત પોલીસ તૈયારી',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _selectedExam.badgeText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFFC107), // Gold
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.white),
            tooltip: 'સાચવેલા પ્રશ્નો (Bookmarks)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'પરીક્ષા માહિતી',
            onPressed: () => _showExamInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Selector Segment
            _buildExamSelector(theme),
            const SizedBox(height: 16),

            // Motivation Banner with Khaki / Gold Accent
            _buildHeroBanner(),
            const SizedBox(height: 16),

            // Syllabus Progress Card
            _buildProgressCard(theme),
            const SizedBox(height: 20),

            // Quick Action Grid (Syllabus, Mock Test, Daily Quiz, Law Section)
            const Text(
              'મુખ્ય વિભાગો (Core Features)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D253F),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionGrid(context),
            const SizedBox(height: 20),

            // Quick Exam Tip / Law Article of the Day
            _buildFactCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorTab(
              title: 'કોન્સ્ટેબલ (LRD)',
              exam: ExamType.constable,
              isSelected: _selectedExam == ExamType.constable,
            ),
          ),
          Expanded(
            child: _buildSelectorTab(
              title: 'PSI / ASI',
              exam: ExamType.psi,
              isSelected: _selectedExam == ExamType.psi,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTab({
    required String title,
    required ExamType exam,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onExamChanged(exam),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D253F) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'મિશન ખાખી 👮‍♂️',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D253F),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedExam.shortTitle} મોક ટેસ્ટ અને સિલેબસ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'દરરોજ મોક ટેસ્ટ આપો અને તમારું મેરિટ રેન્કિંગ સુધારો.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFF2A4D7E),
            child: Icon(Icons.shield, size: 36, color: Color(0xFFFFC107)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'તમારો સિલેબસ પ્રોગ્રેસ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D253F),
                ),
              ),
              Text(
                '${(_overallProgress * 100).toInt()}% પૂર્ણ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _overallProgress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_completedTopics / $_totalTopics ટોપિક પૂર્ણ થયા છે',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SyllabusScreen(
                        examType: _selectedExam,
                        subjects: _currentSyllabus,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: const Text(
                  'વિગતો જુઓ >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _buildActionCard(
          context: context,
          title: 'મોક ટેસ્ટ સીરીઝ',
          subtitle: 'Full & Subject Tests',
          icon: Icons.quiz_outlined,
          color: const Color(0xFF1976D2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestSeriesScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context: context,
          title: 'સંપૂર્ણ સિલેબસ',
          subtitle: 'વિષયવાર ટોપિક ચેકલિસ્ટ',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF2E7D32),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SyllabusScreen(
                  examType: _selectedExam,
                  subjects: _currentSyllabus,
                ),
              ),
            ).then((_) => setState(() {}));
          },
        ),
        _buildActionCard(
          context: context,
          title: 'કાયદો (Law Section)',
          subtitle: 'IPC, CrPC, પુરાવા અધિનિયમ',
          icon: Icons.gavel,
          color: const Color(0xFFE65100),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SyllabusScreen(
                  examType: _selectedExam,
                  subjects: _currentSyllabus,
                  initialSubjectFilter: 'kaydo',
                ),
              ),
            );
          },
        ),
        _buildActionCard(
          context: context,
          title: 'સાચવેલા પ્રશ્નો',
          subtitle: 'Quick Revision',
          icon: Icons.bookmarks_outlined,
          color: const Color(0xFF6A1B9A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookmarksScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D253F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Light Amber
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
                  'પરીક્ષા ટિપ: નેગેટિવ માર્કિંગ (0.25)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFF57F17),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'જો કોઈ પ્રશ્નનો જવાબ ન આવડતો હોય તો હંમેશા વિકલ્પ "E. પ્રયાસ કરેલ નથી" પસંદ કરો, જેથી 0.25 માર્ક્સ કપાય નહીં.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExamInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ગુજરાત પોલીસ ભરતી વિશે'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'પોલીસ કોન્સ્ટેબલ (LRD):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• શારીરિક કસોટી (દોડ) + લેખિત ઓબ્જેક્ટિવ કસોટી.'),
              Text('• નેગેટિવ માર્કિંગ: પ્રત્યેક ખોટા જવાબ દીઠ -0.25 ગુણ.'),
              Text('• વિકલ્પ E પસંદ કરવાથી કોઈ નેગેટિવ ગુણ નહીં થાય.'),
              SizedBox(height: 10),
              Text(
                'પોલીસ સબ ઇન્સ્પેક્ટર (PSI):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• પ્રિલિમિનરી પરીક્ષા + શારીરિક કસોટી + મુખ્ય લેખિત પરીક્ષા.'),
              Text('• મુખ્ય પરીક્ષામાં 4 પેપરો: ગુજરાતી, અંગ્રેજી, જી.એસ., કાયદો.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('સમજાયું'),
          ),
        ],
      ),
    );
  }
}
