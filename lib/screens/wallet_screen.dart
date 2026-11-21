import 'package:flutter/material.dart';
import '../models/user_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _user = UserModel();
  bool _isWatchingAd = false;

  void _watchAd() {
    setState(() => _isWatchingAd = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.video_collection, color: Color(0xFF0D253F)),
            SizedBox(width: 8),
            Text('વિડિઓ એડ પ્લે થઈ રહી છે...', style: TextStyle(fontSize: 15)),
          ],
        ),
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
                    'Sponsored Ad • 3 સેકન્ડ રાહ જુઓ...',
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
        Navigator.pop(context); // Close dialog
        setState(() {
          _isWatchingAd = false;
          _user.addCoins(5, 'વિડિઓ એડ રિવોર્ડ');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF2E7D32),
            content: Row(
              children: [
                Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
                SizedBox(width: 8),
                Text('અભિનંદન! તમને +5 કોઈન્સ મળ્યા! 🎉'),
              ],
            ),
          ),
        );
      }
    });
  }

  void _claimDailyBonus() {
    if (_user.claimDailyBonus()) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('ડેઇલી બોનસ ક્લેમ થયું: +15 કોઈન્સ! 🌟'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('આજનો બોનસ તમે પહેલેથી ક્લેમ કરી લીધો છે!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'મારું વૉલેટ (My Wallet)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold Wallet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D253F).withOpacity(0.35),
                    blurRadius: 12,
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
                      const Text(
                        'કુલ ઉપલબ્ધ કોઈન્સ (Total Balance)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'સક્રિય ખાતું ✅',
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 40, color: Color(0xFFFFC107)),
                      const SizedBox(width: 12),
                      Text(
                        '${_user.coins}',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'કોઈન્સ (Coins)',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 આ કોઈન્સ વાપરીને તમે કોઈપણ પ્રીમિયમ મોક ટેસ્ટ એડ્સ જોયા વગર સીધા અનલોક કરી શકો છો.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Earn Coins Options
            const Text(
              'કોઈન્સ કમાઓ (Earn Coins)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D253F),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.event_available,
                    title: 'ડેઇલી ચેક-ઇન',
                    subtitle: _user.isDailyBonusClaimed ? 'આજે ક્લેમ કરેલ' : '+15 કોઈન્સ દરરોજ',
                    buttonText: _user.isDailyBonusClaimed ? 'ક્લેમ થયેલ' : 'ક્લેમ કરો',
                    color: const Color(0xFF2E7D32),
                    isEnabled: !_user.isDailyBonusClaimed,
                    onTap: _claimDailyBonus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.play_circle_fill,
                    title: 'વિડિઓ એડ જુઓ',
                    subtitle: '+5 કોઈન્સ પ્રતિ એડ',
                    buttonText: 'એડ જુઓ',
                    color: const Color(0xFFE65100),
                    isEnabled: !_isWatchingAd,
                    onTap: _watchAd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Coins Transaction History
            const Text(
              'કોઈન્સ હિસ્ટ્રી (Transaction History)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D253F),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _user.coinHistory.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _user.coinHistory[index];
                  final isCredit = item['isCredit'] as bool;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCredit
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      child: Icon(
                        isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      item['date'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      item['amount'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isCredit ? const Color(0xFF2E7D32) : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: isEnabled ? color : Colors.grey),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isEnabled ? onTap : null,
              child: Text(buttonText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
