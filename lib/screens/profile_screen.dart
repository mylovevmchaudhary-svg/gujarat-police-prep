import 'package:flutter/material.dart';
import '../admin/admin_login_screen.dart';
import '../models/wallet_model.dart';
import 'bookmarks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _wallet = WalletManager();
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'મારી પ્રોફાઇલ (Student Profile)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Student Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0D253F),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF2A4D7E),
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFFFC107),
                        child: Icon(Icons.verified, size: 18, color: Color(0xFF0D253F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ખાખી ઉમેદવાર (Police Aspirant)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'લક્ષ્ય: ગુજરાત પોલીસ કોન્સ્ટેબલ & PSI 2026',
                    style: TextStyle(fontSize: 12, color: Color(0xFFFFC107)),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('ટેસ્ટ આપેલ', '12'),
                        _buildDivider(),
                        _buildStatColumn('સરેરાશ સ્કોર', '142/200'),
                        _buildDivider(),
                        _buildStatColumn('સ્ટ્રીક 🔥', '7 દિવસ'),
                        _buildDivider(),
                        _buildStatColumn('કોઈન્સ 🪙', '${_wallet.coins}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings & Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuCard(
                    icon: Icons.bookmark_outline,
                    color: const Color(0xFF1976D2),
                    title: 'સાચવેલા પ્રશ્નો (Bookmarked MCQs)',
                    subtitle: 'તમારા મનપસંદ પ્રશ્નોનું પુનરાવર્તન કરો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    icon: Icons.card_giftcard,
                    color: const Color(0xFFE65100),
                    title: 'વૉલેટ અને કોઈન્સ',
                    subtitle: 'હાલનું બેલેન્સ: ${_wallet.coins} કોઈન્સ',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('વૉલેટ ટેબ નીચેથી પણ જોઈ શકાય છે.')),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSwitchCard(
                    icon: Icons.notifications_active_outlined,
                    color: const Color(0xFF2E7D32),
                    title: 'પરીક્ષા નોટિફિકેશન',
                    subtitle: 'ડેઇલી ક્વિઝ અને એક્ઝામ અપડેટ્સ',
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF6A1B9A),
                    title: 'મિત્રો સાથે એપ શેર કરો',
                    subtitle: 'રેફરલ કોડ: ${_wallet.referralCode}',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('એપ શેરિંગ લિંક તૈયાર થઈ!')),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  // Master Admin Portal Entry Card
                  _buildMenuCard(
                    icon: Icons.admin_panel_settings,
                    color: const Color(0xFF0D253F),
                    title: '🔐 એડમિન પોર્ટલ (Admin Portal)',
                    subtitle: '200 પ્રશ્નો Excel અપલોડ, ટેસ્ટ & યૂઝર્સ મેનેજ કરો',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMenuCard(
                    icon: Icons.info_outline,
                    color: Colors.grey[700]!,
                    title: 'એપ વિશે અને વર્ઝન',
                    subtitle: 'Gujarat Police Prep v2.0 (Admin Enabled)',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'ગુજરાત પોલીસ તૈયારી',
                        applicationVersion: '2.0.0 (Admin Enabled Edition)',
                        applicationLegalese: '© 2026 વિદ્યાર્થી કલ્યાણ મંડળ',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 20, width: 1, color: Colors.white24);
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        activeColor: const Color(0xFF0D253F),
        secondary: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
