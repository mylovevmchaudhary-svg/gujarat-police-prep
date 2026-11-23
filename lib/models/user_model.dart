import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class UserModel {
  static final UserModel _instance = UserModel._internal();
  factory UserModel() => _instance;
  UserModel._internal() {
    _loadFromDisk();
  }

  bool isLoggedIn = false;
  String name = 'વિદ્યાર્થી (Khakhi Aspirant)';
  String email = 'student@khakhi.in';
  String myReferralCode = 'KHAKHI2026';
  String appliedReferralCode = '';
  int coins = 150;
  int totalReferralsCount = 3;
  int referralCoinsEarned = 150;
  bool isDailyBonusClaimed = false;

  /// Reactive notifier for instant, real-time UI updates across all tabs & screens
  late final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(coins);

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

  File get _storageFile {
    final tempDir = Directory.systemTemp.path;
    return File('$tempDir/khakhi_user_session.json');
  }

  void _loadFromDisk() {
    try {
      final file = _storageFile;
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        final data = jsonDecode(content);
        if (data is Map) {
          name = data['name']?.toString() ?? name;
          email = data['email']?.toString() ?? email;
          coins = (data['coins'] as num?)?.toInt() ?? coins;
          isLoggedIn = (data['isLoggedIn'] as bool?) ?? isLoggedIn;
          myReferralCode = data['myReferralCode']?.toString() ?? myReferralCode;
          appliedReferralCode = data['appliedReferralCode']?.toString() ?? appliedReferralCode;
          isDailyBonusClaimed = (data['isDailyBonusClaimed'] as bool?) ?? false;

          if (data['unlockedTests'] is List) {
            _unlockedTests.addAll((data['unlockedTests'] as List).map((e) => e.toString()));
          }
          coinsNotifier.value = coins;
        }
      }
    } catch (_) {}
  }

  void _saveToDisk() {
    try {
      final data = {
        'name': name,
        'email': email,
        'coins': coins,
        'isLoggedIn': isLoggedIn,
        'myReferralCode': myReferralCode,
        'appliedReferralCode': appliedReferralCode,
        'isDailyBonusClaimed': isDailyBonusClaimed,
        'unlockedTests': _unlockedTests.toList(),
      };
      _storageFile.writeAsStringSync(jsonEncode(data));
    } catch (_) {}
  }

  bool isTestUnlocked(String testId, int testIndex) {
    if (testIndex <= 3) return true; // First 3 tests are Free
    return _unlockedTests.contains(testId);
  }

  void setCoins(int newCoins) {
    coins = newCoins;
    coinsNotifier.value = coins;
    _saveToDisk();
  }

  bool unlockWithCoins(String testId, int requiredCoins) {
    if (coins >= requiredCoins) {
      coins -= requiredCoins;
      coinsNotifier.value = coins;
      _unlockedTests.add(testId);
      coinHistory.insert(0, {
        'title': 'મોક ટેસ્ટ અનલોક ($testId)',
        'amount': '-$requiredCoins',
        'isCredit': false,
        'date': 'હમણાં',
      });
      _saveToDisk();
      SupabaseService().syncCoinsToDatabase(email, coins);
      return true;
    }
    return false;
  }

  void unlockWithAd(String testId) {
    _unlockedTests.add(testId);
    coins += 10;
    coinsNotifier.value = coins;
    coinHistory.insert(0, {
      'title': 'AdMob રિવોર્ડ બોનસ',
      'amount': '+10',
      'isCredit': true,
      'date': 'હમણાં',
    });
    _saveToDisk();
    SupabaseService().syncCoinsToDatabase(email, coins);
  }

  void addCoins(int amount, String reason) {
    coins += amount;
    coinsNotifier.value = coins;
    coinHistory.insert(0, {
      'title': reason,
      'amount': '+$amount',
      'isCredit': true,
      'date': 'હમણાં',
    });
    _saveToDisk();
    SupabaseService().syncCoinsToDatabase(email, coins);
  }

  bool claimDailyBonus() {
    if (!isDailyBonusClaimed) {
      coins += 15;
      isDailyBonusClaimed = true;
      coinsNotifier.value = coins;
      coinHistory.insert(0, {
        'title': 'ડેઇલી ચેક-ઇન બોનસ',
        'amount': '+15',
        'isCredit': true,
        'date': 'આજે',
      });
      _saveToDisk();
      SupabaseService().syncCoinsToDatabase(email, coins);
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
      coinsNotifier.value = coins;
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

      _saveToDisk();
      SupabaseService().syncCoinsToDatabase(email, coins);
      SupabaseService().submitWithdrawal(
        studentName: name,
        studentEmail: email,
        coins: coinsToDeduct,
        amountInr: inrAmount,
        upiId: upiId,
      );
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
    coinsNotifier.value = coins;
    _saveToDisk();
  }

  void login({required String userEmail}) {
    email = userEmail;
    name = userEmail.split('@').first;
    isLoggedIn = true;
    _saveToDisk();
  }

  void logout() {
    isLoggedIn = false;
    _saveToDisk();
  }
}
