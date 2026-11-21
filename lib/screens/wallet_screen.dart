import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletManager();
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
            Text('વિડિઓ એડ પ્લે થઈ રહી છે...', style: TextStyle(fontSize: 16)),
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
                    'Sponsored Ad • 5 સેકન્ડ રાહ જુઓ...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate 3 second ad duration
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        setState(() {
          _isWatchingAd = false;
          _wallet.addCoins(5);
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
    if (_wallet.claimDailyBonus()) {
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
          'વૉલેટ અને રેફરલ (Coins & Refer)',
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D253F), Color(0xFF1E3C72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        'તમારું બેલેન્સ (Wallet Balance)',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_open, size: 14, color: Color(0xFFFFC107)),
                            SizedBox(width: 4),
                            Text(
                              '3 ફ્રી ટેસ્ટ અનલોક છે',
                              style: TextStyle(fontSize: 11, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 36, color: Color(0xFFFFC107)),
                      const SizedBox(width: 10),
                      Text(
                        '${_wallet.coins}',
                        style: const TextStyle(
                          fontSize: 36,
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
                  const SizedBox(height: 14),
                  const Text(
                    '💡 10 કોઈન્સ વાપરીને કોઈપણ પ્રીમિયમ મોક ટેસ્ટ એડ જોયા વગર અનલોક કરી શકો છો.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Earn Coins Actions (Daily Bonus & Watch Ad)
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.calendar_today,
                    title: 'ડેઇલી બોનસ',
                    subtitle: _wallet.isDailyBonusClaimed ? 'આજે ક્લેમ થયેલ' : '+15 કોઈન્સ',
                    buttonText: _wallet.isDailyBonusClaimed ? 'ક્લેમ કરેલ' : 'ક્લેમ કરો',
                    color: const Color(0xFF2E7D32),
                    isEnabled: !_wallet.isDailyBonusClaimed,
                    onTap: _claimDailyBonus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.play_circle_fill,
                    title: 'વિડિઓ એડ જુઓ',
                    subtitle: '+5 કોઈન્સ મેળવો',
                    buttonText: 'એડ જુઓ',
                    color: const Color(0xFFE65100),
                    isEnabled: !_isWatchingAd,
                    onTap: _watchAd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Refer & Earn Banner
            const Text(
              'મિત્રોને રેફર કરો અને કોઈન્સ કમાઓ 👥',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D253F),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'તમારો રેફરલ કોડ (Referral Code):',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0D253F).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _wallet.referralCode,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('કોપી'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('રેફરલ કોડ કોપી થયો!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text(
                      'WhatsApp પર મિત્રો સાથે શેર કરો',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('WhatsApp શેરિંગ લિંક તૈયાર થઈ!')),
                      );
                    },
                  ),
                  const Divider(height: 28),
                  const Text(
                    'રેફરલ નિયમો:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  const Text('• તમારો મિત્ર એપ ડાઉનલોડ કરીને કોડ વાપરે એટલે તમને +50 કોઈન્સ મળશે.'),
                  const Text('• તમારા મિત્રને પણ તરત જ +20 કોઈન્સનું બોનસ મળશે.'),
                  const Text('• કુલ સફળ રેફરલ્સ: 3 મિત્રો જોડાયા (+150 કોઈન્સ કમાયા).'),
                ],
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
