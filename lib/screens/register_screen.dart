import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notice_provider.dart';
import '../utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedEmoji = '🐟';
  int _selectedColor = 0xFF0F4C81;

  final List<String> _emojis = [
    '🐟',
    '👑',
    '🌸',
    '🏄‍♂️',
    '🎨',
    '🐣',
    '👵',
    '👴',
    '🦈',
    '🐋',
    '🎣',
    '🌊',
    '☕',
    '🏃',
    '💻',
    '🍙',
  ];

  final List<int> _colors = [
    0xFF0F4C81, // Ocean Navy
    0xFFE11D48, // Rose Pink
    0xFF0284C7, // Sky Blue
    0xFF9333EA, // Purple
    0xFFF59E0B, // Amber Gold
    0xFF0D9488, // Teal
    0xFF16A34A, // Green
    0xFF475569, // Slate Grey
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _formatPhoneNumber(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    String formatted = clean;

    if (clean.length > 3 && clean.length <= 7) {
      formatted = '${clean.substring(0, 3)}-${clean.substring(3)}';
    } else if (clean.length > 7) {
      formatted =
          '${clean.substring(0, 3)}-${clean.substring(3, 7)}-${clean.substring(7, clean.length > 11 ? 11 : clean.length)}';
    }

    if (formatted != value) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다. 다시 확인해 주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final noticeProvider = context.read<NoticeProvider>();

    final error = await authProvider.register(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      emoji: _selectedEmoji,
      colorValue: _selectedColor,
    );

    if (error != null) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      }
    } else {
      if (!mounted) return;
      if (authProvider.currentUser != null) {
        // Add member to family member list if not present
        if (!noticeProvider.members
            .any((m) => m.id == authProvider.currentUser!.id)) {
          await noticeProvider.addMember(authProvider.currentUser!);
        }
        noticeProvider.setCurrentMember(authProvider.currentUser!);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${authProvider.currentUser!.nickname}님, 참치패밀리 가입을 환영합니다! 🎉'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context); // Return to auth wrapper which opens home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1544A8);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        title: const Text(
          '새 계정 만들기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header title
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            '참치패밀리 회원가입 🐟',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '가족 소통방을 이용하기 위해 정보를 입력해 주세요.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Privacy Assurance Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.verified_user_rounded,
                              color: brandBlue, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🔒 개인정보 유출 방지 및 암호화 보호',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: brandBlue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '입력하신 이름과 전화번호는 암호화되어 안전하게 보관되며, 외부에 절대 노출되지 않습니다. (피드에는 이름 마스킹 처리 지원)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF1E3A8A),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Message Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 1. Name Field
                    const Text(
                      '이름 (실명)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '예: 김참치',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.badge_rounded,
                            color: Colors.black45, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return '이름을 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 2. Phone Field
                    const Text(
                      '휴대폰 번호 (로그인 ID)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: _formatPhoneNumber,
                      decoration: InputDecoration(
                        hintText: '010-0000-0000',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.phone_android_rounded,
                            color: Colors.black45, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return '휴대폰 번호를 입력해 주세요.';
                        }
                        final clean = val.replaceAll(RegExp(r'\D'), '');
                        if (clean.length < 10) {
                          return '올바른 휴대폰 번호를 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Password Field
                    const Text(
                      '비밀번호',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호 (4자리 이상)',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: Colors.black45, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      validator: (val) {
                        if (val == null || val.length < 4) {
                          return '비밀번호는 최소 4자리 이상 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4. Confirm Password Field
                    const Text(
                      '비밀번호 확인',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: '비밀번호를 한 번 더 입력하세요',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_reset_rounded,
                            color: Colors.black45, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return '비밀번호 확인을 입력해 주세요.';
                        }
                        if (val != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // 5. Emoji Avatar Picker
                    const Text(
                      '프로필 캐릭터 선택',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _emojis.map((emoji) {
                        final isSelected = emoji == _selectedEmoji;
                        return InkWell(
                          onTap: () => setState(() => _selectedEmoji = emoji),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? brandBlue.withValues(alpha: 0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? brandBlue
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(emoji,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 6. Theme Color Picker
                    const Text(
                      '대표 색상 선택',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: _colors.map<Widget>((colorVal) {
                        final isSelected = colorVal == _selectedColor;
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedColor = colorVal),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black87
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 18, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Submit Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '가입 완료하고 시작하기 🚀',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
