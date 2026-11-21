import 'package:flutter/material.dart';

class ExamCategory {
  final String id;
  final String titleGujarati;
  final String titleEnglish;
  final String totalTestsCount;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String badgeText;

  const ExamCategory({
    required this.id,
    required this.titleGujarati,
    required this.titleEnglish,
    required this.totalTestsCount,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeText,
  });

  static List<ExamCategory> getCategories() {
    return const [
      ExamCategory(
        id: 'constable',
        titleGujarati: 'પોલીસ કોન્સ્ટેબલ (LRD)',
        titleEnglish: 'Gujarat Police Constable',
        totalTestsCount: '500+ મોક ટેસ્ટ',
        description: 'કાયદો, બંધારણ, જીકે, રીઝનિંગ અને વિજ્ઞાનના 200 પ્રશ્નોની સીરીઝ',
        icon: Icons.local_police,
        primaryColor: Color(0xFF0D253F),
        secondaryColor: Color(0xFF1E3C72),
        badgeText: 'સૌથી લોકપ્રિય 🌟',
      ),
      ExamCategory(
        id: 'psi',
        titleGujarati: 'પોલીસ સબ ઇન્સ્પેક્ટર (PSI)',
        titleEnglish: 'Police Sub Inspector & ASI',
        totalTestsCount: '500+ મોક ટેસ્ટ',
        description: 'કાયદો, ગુજરાતી, અંગ્રેજી અને જનરલ સ્ટડીઝ પ્રિલિમ્સ & મેઈન્સ',
        icon: Icons.shield,
        primaryColor: Color(0xFF1B5E20),
        secondaryColor: Color(0xFF2E7D32),
        badgeText: 'નવો સિલેબસ 🎯',
      ),
      ExamCategory(
        id: 'jail_sipahi',
        titleGujarati: 'જેલ સિપાહી (Jail Guard)',
        titleEnglish: 'Gujarat Prison Department',
        totalTestsCount: '250+ મોક ટેસ્ટ',
        description: 'ગુજરાત જેલ સિપાહી માટે સ્પેશિયલ મોક ટેસ્ટ અને પ્રશ્નોત્તરી',
        icon: Icons.security,
        primaryColor: Color(0xFFB71C1C),
        secondaryColor: Color(0xFFD32F2F),
        badgeText: 'હાઈ સ્કોરિંગ 🚀',
      ),
      ExamCategory(
        id: 'srpf',
        titleGujarati: 'SRPF આર્મ્ડ કોન્સ્ટેબલ',
        titleEnglish: 'State Reserve Police Force',
        totalTestsCount: '200+ મોક ટેસ્ટ',
        description: 'આર્મ્ડ પોલીસ દળની વિશેષ ભરતી પરીક્ષા તૈયારી',
        icon: Icons.military_tech,
        primaryColor: Color(0xFFE65100),
        secondaryColor: Color(0xFFF57C00),
        badgeText: 'ફિઝિકલ + લેખિત 💪',
      ),
      ExamCategory(
        id: 'forest',
        titleGujarati: 'ફોરેસ્ટ ગાર્ડ (વનરક્ષક)',
        titleEnglish: 'Gujarat Forest Guard',
        totalTestsCount: '300+ મોક ટેસ્ટ',
        description: 'પર્યાવરણ, વન્યજીવ અને સામાન્ય જ્ઞાન વિશેષ ટેસ્ટ',
        icon: Icons.forest,
        primaryColor: Color(0xFF004D40),
        secondaryColor: Color(0xFF00796B),
        badgeText: 'વન વિભાગ 🌿',
      ),
      ExamCategory(
        id: 'cce',
        titleGujarati: 'CCE ક્લાર્ક (Class-3)',
        titleEnglish: 'Gujarat CCE Combined Exam',
        totalTestsCount: '400+ મોક ટેસ્ટ',
        description: 'GSSSB દ્વારા આયોજિત નવી ગ્રુપ A & B કમ્બાઈન્ડ એક્ઝામ',
        icon: Icons.assignment,
        primaryColor: Color(0xFF4A148C),
        secondaryColor: Color(0xFF6A1B9A),
        badgeText: 'GSSSB સ્પેશિયલ 📝',
      ),
    ];
  }
}
