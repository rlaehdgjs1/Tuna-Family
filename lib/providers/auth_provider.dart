import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';

class AuthProvider with ChangeNotifier {
  static const String _accountsKey = 'tuna_family_auth_accounts_v1';
  static const String _sessionKey = 'tuna_family_auth_session_v1';

  List<Member> _accounts = [];
  Member? _currentUser;
  bool _isLoading = true;

  AuthProvider() {
    _initAuth();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isCurrentUserAdmin => _currentUser?.isAdmin ?? false;
  Member? get currentUser => _currentUser;
  List<Member> get accounts => List.unmodifiable(_accounts);

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load registered accounts
      final accountsJson = prefs.getString(_accountsKey);
      if (accountsJson != null) {
        final List<dynamic> decoded = jsonDecode(accountsJson);
        _accounts = decoded.map((e) => Member.fromJson(e)).toList();
      }

      // 2. Load active session
      final sessionMemberId = prefs.getString(_sessionKey);
      if (sessionMemberId != null &&
          _accounts.any((a) => a.id == sessionMemberId)) {
        _currentUser = _accounts.firstWhere((a) => a.id == sessionMemberId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('AuthProvider init error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountsKey,
          jsonEncode(_accounts.map((a) => a.toJson()).toList()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving accounts: $e');
      }
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_sessionKey, _currentUser!.id);
      } else {
        await prefs.remove(_sessionKey);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session: $e');
      }
    }
  }

  /// Login with phone number and password
  Future<String?> login(String rawPhone, String rawPassword) async {
    final cleanPhone = Member.cleanPhone(rawPhone);
    if (cleanPhone.isEmpty) {
      return '휴대폰 번호를 입력해 주세요.';
    }
    if (rawPassword.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }

    final account = _accounts.cast<Member?>().firstWhere(
          (a) =>
              a != null &&
              a.phoneNumber != null &&
              Member.cleanPhone(a.phoneNumber!) == cleanPhone,
          orElse: () => null,
        );

    if (account == null) {
      return '등록되지 않은 휴대폰 번호입니다.\n회원가입을 먼저 진행해 주세요.';
    }

    if (!account.verifyPassword(rawPassword)) {
      return '비밀번호가 일치하지 않습니다. 다시 확인해 주세요.';
    }

    _currentUser = account;
    await _saveSession();
    notifyListeners();
    return null; // Success
  }

  /// Register new user account (New members default to MemberGrade.general '일반', first user becomes admin)
  Future<String?> register({
    required String name,
    required String phoneNumber,
    required String password,
    String? nickname,
    String? role,
    required String emoji,
    required int colorValue,
  }) async {
    final cleanPhone = Member.cleanPhone(phoneNumber);
    if (name.trim().isEmpty) {
      return '이름(실명)을 입력해 주세요.';
    }
    if (cleanPhone.length < 10) {
      return '올바른 휴대폰 번호(10~11자리)를 입력해 주세요.';
    }
    if (password.length < 4) {
      return '비밀번호는 최소 4자리 이상 입력해 주세요.';
    }

    // Check if phone number is already registered
    final isAlreadyRegistered = _accounts.any((a) =>
        a.phoneNumber != null &&
        Member.cleanPhone(a.phoneNumber!) == cleanPhone);

    if (isAlreadyRegistered) {
      return '이미 가입된 휴대폰 번호입니다.\n해당 번호로 로그인해 주세요.';
    }

    final isFirstUser = _accounts.isEmpty;
    final displayNickname = (nickname != null && nickname.trim().isNotEmpty)
        ? nickname.trim()
        : name.trim();
    final memberRole = (role != null && role.trim().isNotEmpty)
        ? role.trim()
        : (isFirstUser ? '총괄 관리자' : '일반 회원');

    final newMember = Member(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phoneNumber: cleanPhone,
      passwordHash: Member.hashPassword(password),
      nickname: displayNickname,
      role: memberRole,
      emoji: emoji,
      colorValue: colorValue,
      isAdmin: isFirstUser, // First registered user is Admin!
      grade: isFirstUser ? MemberGrade.admin : MemberGrade.general, // Default grade: '일반'
      createdAt: DateTime.now(),
    );

    _accounts.add(newMember);
    _currentUser = newMember;

    await _saveAccounts();
    await _saveSession();
    notifyListeners();

    return null; // Success
  }

  /// Admin deletes a member/user account
  Future<String?> deleteAccountByAdmin(String targetMemberId) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return '관리자 권한이 있는 사용자만 회원을 삭제할 수 있습니다.';
    }

    if (_currentUser!.id == targetMemberId) {
      return '현재 로그인 중인 본인 관리자 계정은 삭제할 수 없습니다.';
    }

    final index = _accounts.indexWhere((a) => a.id == targetMemberId);
    if (index != -1) {
      _accounts.removeAt(index);
      await _saveAccounts();
      notifyListeners();
      return null; // Success
    }

    return '삭제할 회원을 찾을 수 없습니다.';
  }

  /// Admin updates a member's Grade (등급 조절: 관리자 / 우수회원 / 정회원 / 일반)
  Future<String?> updateMemberGrade(
      String targetMemberId, MemberGrade newGrade) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return '관리자 권한이 필요합니다.';
    }

    final index = _accounts.indexWhere((a) => a.id == targetMemberId);
    if (index != -1) {
      final member = _accounts[index];
      final isAdminRole = (newGrade == MemberGrade.admin);
      final updated = member.copyWith(
        grade: newGrade,
        isAdmin: isAdminRole,
      );
      _accounts[index] = updated;

      if (_currentUser?.id == targetMemberId) {
        _currentUser = updated;
        await _saveSession();
      }

      await _saveAccounts();
      notifyListeners();
      return null; // Success
    }

    return '해당 회원을 찾을 수 없습니다.';
  }

  /// Admin toggles another member's admin role
  Future<String?> toggleAdminRole(String targetMemberId) async {
    if (_currentUser == null || !_currentUser!.isAdmin) {
      return '관리자 권한이 필요합니다.';
    }

    final index = _accounts.indexWhere((a) => a.id == targetMemberId);
    if (index != -1) {
      final member = _accounts[index];
      final newIsAdmin = !member.isAdmin;
      final updated = member.copyWith(
        isAdmin: newIsAdmin,
        grade: newIsAdmin ? MemberGrade.admin : MemberGrade.general,
      );
      _accounts[index] = updated;

      if (_currentUser?.id == targetMemberId) {
        _currentUser = updated;
        await _saveSession();
      }

      await _saveAccounts();
      notifyListeners();
      return null;
    }

    return '해당 회원을 찾을 수 없습니다.';
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    await _saveSession();
    notifyListeners();
  }

  /// Update Profile
  Future<void> updateProfile(Member updated) async {
    final index = _accounts.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _accounts[index] = updated;
      if (_currentUser?.id == updated.id) {
        _currentUser = updated;
      }
      await _saveAccounts();
      notifyListeners();
    }
  }
}
