import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../providers/auth_provider.dart';

/// ============================================
/// 회원가입 페이지
/// ============================================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRegion = '서울';
  bool _isLoading = false;
  
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final List<String> _regions = [
    '서울', '부산', '대구', '인천', '광주', 
    '대전', '울산', '세종', '경기', '강원',
    '충북', '충남', '전북', '전남', '경북', 
    '경남', '제주',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    // 사용자명 검증
    if (_usernameController.text.trim().isEmpty) {
      setState(() => _usernameError = '사용자명을 입력해주세요');
      isValid = false;
    } else if (_usernameController.text.trim().length < 2) {
      setState(() => _usernameError = '사용자명은 2자 이상이어야 합니다');
      isValid = false;
    }

    // 이메일 검증
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = '이메일을 입력해주세요');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = '올바른 이메일 형식이 아닙니다');
      isValid = false;
    }

    // 비밀번호 검증
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = '비밀번호를 입력해주세요');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = '비밀번호는 6자 이상이어야 합니다');
      isValid = false;
    }

    // 비밀번호 확인 검증
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = '비밀번호 확인을 입력해주세요');
      isValid = false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = '비밀번호가 일치하지 않습니다');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleSignUp() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
        region: _selectedRegion,
      );

      if (mounted) {
        await DialogHelper.showSuccess(
          context,
          title: '회원가입 완료',
          content: '회원가입이 완료되었습니다.\n로그인 해주세요.',
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '회원가입 실패',
          content: e.message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRegionPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('취소'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('완료'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _regions.indexOf(_selectedRegion),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedRegion = _regions[index];
                  });
                },
                children: _regions.map((region) => Center(
                  child: Text(region),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('회원가입'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppColors.primary,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              
              // 사용자명 입력
              _buildInputLabel('사용자명'),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: _usernameController,
                placeholder: '사용자명을 입력하세요',
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(
                    color: _usernameError != null 
                        ? AppColors.error 
                        : AppColors.border,
                  ),
                ),
              ),
              _buildErrorText(_usernameError),
              const SizedBox(height: AppSpacing.lg),
              
              // 이메일 입력
              _buildInputLabel('이메일'),
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
              _buildErrorText(_emailError),
              const SizedBox(height: AppSpacing.lg),
              
              // 비밀번호 입력
              _buildInputLabel('비밀번호'),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: '6자 이상 입력',
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
              _buildErrorText(_passwordError),
              const SizedBox(height: AppSpacing.lg),
              
              // 비밀번호 확인 입력
              _buildInputLabel('비밀번호 확인'),
              const SizedBox(height: AppSpacing.sm),
              CupertinoTextField(
                controller: _confirmPasswordController,
                placeholder: '비밀번호를 다시 입력하세요',
                obscureText: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(
                    color: _confirmPasswordError != null 
                        ? AppColors.error 
                        : AppColors.border,
                  ),
                ),
              ),
              _buildErrorText(_confirmPasswordError),
              const SizedBox(height: AppSpacing.lg),
              
              // 지역 선택
              _buildInputLabel('지역'),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: _showRegionPicker,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppBorderRadius.medium,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedRegion,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl * 2),
              
              // 회원가입 버튼
              PrimaryButton(
                text: '회원가입',
                onPressed: _handleSignUp,
                isLoading: _isLoading,
                width: double.infinity,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // 로그인 페이지로 이동
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '이미 계정이 있으신가요? 로그인',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildErrorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        error,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),
    );
  }
}
