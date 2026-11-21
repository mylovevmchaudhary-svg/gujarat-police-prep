class UserModel {
  static final UserModel _instance = UserModel._internal();
  factory UserModel() => _instance;
  UserModel._internal();

  bool isLoggedIn = true;
  String name = 'વિદ્યાર્થી (Khakhi Aspirant)';
  String email = 'student@khakhi.in';
  String myReferralCode = 'KHAKHI2026';
  String appliedReferralCode = '';
  int coins = 150; // Welcome + Referral balance
  int totalReferralsCount = 3;
  int referralCoinsEarned = 150;
  bool isDailyBonusClaimed = false;

  final List<Map<String, dynamic>> coinHistory = [
    {'title': 'વેલકમ બોનસ', 'amount': '+30', 'isCredit': true, 'date': 'આજે'},
    {'title': 'રેફરલ બોનસ (મિત્ર જોડાયા)', 'amount': '+50', 'isCredit': true, 'date': 'ગઈકાલે'},
    {'title': 'ડેઇલી ચેક-ઇન બોનસ', 'amount': '+15', 'isCredit': true, 'date': 'આજે'},
  ];

  // Withdrawal Requests list
  final List<Map<String, dynamic>> withdrawalRequests = [
    {
      'id': 'wd_101',
      'amount': '₹20.00',
      'coins': 200,
      'upi': 'student@upi',
      'status': 'મંજૂર (Paid) ✅',
      'date': 'ગઈકાલે',
      'isSuccess': true,
    },
  ];

  // Set of unlocked test IDs
  final Set<String> _unlockedTests = {
    'constable_1',
    'constable_2',
    'constable_3',
    'psi_1',
    'psi_2',
    'psi_3',
  };

  bool isTestUnlocked(String testId, int testIndex) {
    if (testIndex <= 3) return true; // First 3 tests are Free
    return _unlockedTests.contains(testId);
  }

  bool unlockWithCoins(String testId, int requiredCoins) {
    if (coins >= requiredCoins) {
      coins -= requiredCoins;
      _unlockedTests.add(testId);
      coinHistory.insert(0, {
        'title': 'મોક ટેસ્ટ અનલોક',
        'amount': '-$requiredCoins',
        'isCredit': false,
        'date': 'હમણાં',
      });
      return true;
    }
    return false;
  }

  void unlockWithAd(String testId) {
    _unlockedTests.add(testId);
    coins += 5;
    coinHistory.insert(0, {
      'title': 'વિડિઓ એડ બોનસ',
      'amount': '+5',
      'isCredit': true,
      'date': 'હમણાં',
    });
  }

  void addCoins(int amount, String reason) {
    coins += amount;
    coinHistory.insert(0, {
      'title': reason,
      'amount': '+$amount',
      'isCredit': true,
      'date': 'હમણાં',
    });
  }

  bool claimDailyBonus() {
    if (!isDailyBonusClaimed) {
      coins += 15;
      isDailyBonusClaimed = true;
      coinHistory.insert(0, {
        'title': 'ડેઇલી ચેક-ઇન બોનસ',
        'amount': '+15',
        'isCredit': true,
        'date': 'આજે',
      });
      return true;
    }
    return false;
  }

  bool requestWithdrawal({
    required int coinsToDeduct,
    required double inrAmount,
    required String upiId,
  }) {
    if (coins >= coinsToDeduct) {
      coins -= coinsToDeduct;
      coinHistory.insert(0, {
        'title': 'પૈસા ઉપાડ વિનંતી ($upiId)',
        'amount': '-$coinsToDeduct',
        'isCredit': false,
        'date': 'હમણાં',
      });

      withdrawalRequests.insert(0, {
        'id': 'wd_${DateTime.now().millisecondsSinceEpoch}',
        'amount': '₹${inrAmount.toStringAsFixed(2)}',
        'coins': coinsToDeduct,
        'upi': upiId,
        'status': 'પેન્ડિંગ (Processing) ⏳',
        'date': 'હમણાં',
        'isSuccess': false,
      });
      return true;
    }
    return false;
  }

  void register({
    required String userName,
    required String userEmail,
    String? referralCode,
  }) {
    name = userName;
    email = userEmail;
    isLoggedIn = true;
    coins = 30; // base welcome
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      appliedReferralCode = referralCode.trim();
      coins += 20; // referral bonus
      coinHistory.insert(0, {
        'title': 'રેફરલ કોડ બોનસ ($appliedReferralCode)',
        'amount': '+20',
        'isCredit': true,
        'date': 'આજે',
      });
    }
  }

  void login({required String userEmail}) {
    email = userEmail;
    name = userEmail.split('@').first;
    isLoggedIn = true;
  }

  void logout() {
    isLoggedIn = false;
  }
}
