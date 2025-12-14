import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../providers/auth_provider.dart';
import 'signup_page.dart';

/// ============================================
/// 로그인 페이지
/// ============================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = '이메일을 입력해주세요');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = '올바른 이메일 형식이 아닙니다');
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = '비밀번호를 입력해주세요');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // AuthWrapper가 상태 변경을 감지하여 자동으로 화면 전환
    } on ApiException catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '로그인 실패',
          content: e.message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().loginAsGuest();
      // AuthWrapper가 상태 변경을 감지하여 자동으로 화면 전환
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              // 타이틀
              const Center(
                child: Text(
                  'Outfit Hub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // 이메일 입력
              const Text(
                '이메일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(
                    color: _emailError != null 
                        ? AppColors.error 
                        : AppColors.border,
                  ),
                ),
              ),
              if (_emailError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _emailError!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              
              // 비밀번호 입력
              const Text(
                '비밀번호',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: '비밀번호 입력',
                obscureText: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(
                    color: _passwordError != null 
                        ? AppColors.error 
                        : AppColors.border,
                  ),
                ),
              ),
              if (_passwordError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _passwordError!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              
              // 로그인 버튼
              PrimaryButton(
                text: '로그인',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // 회원가입 버튼
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const SignUpPage(),
                    ),
                  );
                },
                child: const Text(
                  '계정이 없으신가요? 회원가입',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // 구분선
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      '또는',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // 게스트 로그인 버튼
              CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                color: AppColors.greyLight,
                onPressed: _handleGuestLogin,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.person,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      '게스트로 시작하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // 게스트 안내 문구
              const Center(
                child: Text(
                  '게스트 모드에서는 일부 기능이 제한될 수 있습니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
