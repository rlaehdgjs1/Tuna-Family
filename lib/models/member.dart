import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Member Tier / Grade System (등급제)
enum MemberGrade {
  admin('관리자', '👑', 0xFFD97706, 0xFFFEF3C7),
  vip('우수회원', '⭐', 0xFF7C3AED, 0xFFEDE9FE),
  regular('정회원', '🔷', 0xFF0284C7, 0xFFE0F2FE),
  general('일반', '🌱', 0xFF16A34A, 0xFFDCFCE7);

  final String label;
  final String icon;
  final int colorValue;
  final int bgValue;

  const MemberGrade(this.label, this.icon, this.colorValue, this.bgValue);

  static MemberGrade fromString(String? val) {
    if (val == null) return MemberGrade.general;
    for (final g in MemberGrade.values) {
      if (g.name == val || g.label == val) return g;
    }
    if (val == '관리자' || val == 'admin') return MemberGrade.admin;
    if (val == '우수' || val == '우수회원' || val == 'vip') return MemberGrade.vip;
    if (val == '정회원' || val == 'regular') return MemberGrade.regular;
    if (val == '일반' || val == '일반회원' || val == 'general') {
      return MemberGrade.general;
    }
    return MemberGrade.general;
  }
}

class Member {
  final String id;
  final String name;
  final String nickname;
  final String role;
  final String emoji;
  final int colorValue;
  final String? phoneNumber;
  final String? passwordHash;
  final bool isAdmin;
  final MemberGrade grade;
  final DateTime? createdAt;

  const Member({
    required this.id,
    required this.name,
    required this.nickname,
    required this.role,
    required this.emoji,
    required this.colorValue,
    this.phoneNumber,
    this.passwordHash,
    this.isAdmin = false,
    this.grade = MemberGrade.general,
    this.createdAt,
  });

  /// Hash password using SHA-256 with salt for security
  static String hashPassword(String password) {
    const salt = 'tuna_family_secure_salt_2026_';
    final bytes = utf8.encode(salt + password);
    return sha256.convert(bytes).toString();
  }

  /// Verify password
  bool verifyPassword(String password) {
    if (passwordHash == null) return false;
    return passwordHash == hashPassword(password);
  }

  /// Clean phone number to digits only (e.g. 01012345678)
  static String cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Format phone with hyphens (e.g. 010-1234-5678)
  static String formatPhone(String phone) {
    final clean = cleanPhone(phone);
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    }
    return phone;
  }

  /// Returns masked phone number to prevent sensitive personal info leak (e.g. 010-****-5678)
  String get maskedPhone {
    if (phoneNumber == null || phoneNumber!.isEmpty) return '';
    final clean = cleanPhone(phoneNumber!);
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}-****-${clean.substring(7)}';
    } else if (clean.length == 10) {
      return '${clean.substring(0, 3)}-***-${clean.substring(6)}';
    }
    return '010-****-****';
  }

  /// Returns masked name to protect user privacy (e.g. 김*치)
  String get maskedName {
    if (name.isEmpty) return '';
    if (name.length == 2) {
      return '${name[0]}*';
    } else if (name.length >= 3) {
      return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}';
    }
    return name;
  }

  Member copyWith({
    String? id,
    String? name,
    String? nickname,
    String? role,
    String? emoji,
    int? colorValue,
    String? phoneNumber,
    String? passwordHash,
    bool? isAdmin,
    MemberGrade? grade,
    DateTime? createdAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      role: role ?? this.role,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      passwordHash: passwordHash ?? this.passwordHash,
      isAdmin: isAdmin ?? this.isAdmin,
      grade: grade ?? this.grade,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nickname': nickname,
        'role': role,
        'emoji': emoji,
        'colorValue': colorValue,
        'phoneNumber': phoneNumber,
        'passwordHash': passwordHash,
        'isAdmin': isAdmin,
        'grade': grade.name,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'] as String,
        name: json['name'] as String,
        nickname: json['nickname'] as String,
        role: json['role'] as String,
        emoji: json['emoji'] as String,
        colorValue: json['colorValue'] as int? ?? 0xFF1976D2,
        phoneNumber: json['phoneNumber'] as String?,
        passwordHash: json['passwordHash'] as String?,
        isAdmin: json['isAdmin'] as bool? ?? false,
        grade: json['grade'] != null
            ? MemberGrade.fromString(json['grade'] as String)
            : ((json['isAdmin'] as bool? ?? false)
                ? MemberGrade.admin
                : MemberGrade.general),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
