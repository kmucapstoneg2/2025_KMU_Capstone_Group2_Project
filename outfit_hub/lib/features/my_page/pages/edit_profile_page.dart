import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/core.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import 'package:image/image.dart' as img;

/// ============================================
/// 프로필 수정 페이지
/// ============================================

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> currentProfile;

  const EditProfilePage({super.key, required this.currentProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late String _selectedRegion;
  bool _isLoading = false;
  String? _usernameError;
  String? _profileImageBase64; // base64 인코딩된 프로필 이미지
  Uint8List? _profileImageBytes; // 표시용 이미지 바이트

  final List<String> _regions = [
    '서울', '부산', '대구', '인천', '광주',
    '대전', '울산', '세종', '경기', '강원',
    '충북', '충남', '전북', '전남', '경북',
    '경남', '제주',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.currentProfile['username'] as String? ?? '',
    );
    _selectedRegion = widget.currentProfile['region'] as String? ?? '서울';
    
    // 기존 프로필 이미지가 있으면 로드
    final existingImage = widget.currentProfile['profileImageUrl'] as String?;
    if (existingImage != null && existingImage.isNotEmpty) {
      if (existingImage.startsWith('data:image')) {
        // data:image/jpeg;base64,... 형식
        final base64String = existingImage.split(',').last;
        _profileImageBase64 = existingImage;
        _profileImageBytes = base64Decode(base64String);
      } else {
        // base64만 있는 경우
        _profileImageBase64 = 'data:image/jpeg;base64,$existingImage';
        _profileImageBytes = base64Decode(existingImage);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _usernameError = null;
    });

    if (_usernameController.text.trim().isEmpty) {
      setState(() => _usernameError = '사용자명을 입력해주세요');
      return false;
    }
    if (_usernameController.text.trim().length < 2) {
      setState(() => _usernameError = '사용자명은 2자 이상이어야 합니다');
      return false;
    }

    return true;
  }

  Future<void> _handleSave() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.accessToken;

      if (token == null) {
        throw ApiException('로그인이 필요합니다', 401);
      }

      await ProfileService.updateProfile(
        token: token,
        username: _usernameController.text.trim(),
        region: _selectedRegion,
        profileImageUrl: _profileImageBase64, // base64 이미지 전달
      );

      // AuthProvider의 username 업데이트
      await authProvider.updateUsername(_usernameController.text.trim());

      // UserProvider의 username도 함께 업데이트 (홈 인사말 동기화)
      await context.read<UserProvider>().updateUsername(_usernameController.text.trim());

      if (mounted) {
        Navigator.pop(context, true); // true를 반환하여 새로고침 필요함을 알림
      }
    } on ApiException catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '수정 실패',
          content: e.message,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      // 이미지 읽기
      final bytes = await image.readAsBytes();
      
      // 이미지 리사이즈 (300x300으로 축소)
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('이미지를 읽을 수 없습니다');
      }

      // 정사각형으로 크롭
      final size = originalImage.width < originalImage.height 
          ? originalImage.width 
          : originalImage.height;
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: (originalImage.width - size) ~/ 2,
        y: (originalImage.height - size) ~/ 2,
        width: size,
        height: size,
      );

      // 300x300으로 리사이즈
      img.Image resizedImage = img.copyResize(croppedImage, width: 300, height: 300);

      // JPEG로 인코딩 (품질 85)
      final resizedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 85));

      // base64 인코딩
      final base64String = base64Encode(resizedBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';

      setState(() {
        _profileImageBase64 = dataUrl;
        _profileImageBytes = resizedBytes;
      });

      // 안내 팝업 제거: 이미지 선택 후 바로 미리보기만 갱신
    } catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '이미지 선택 실패',
          content: '이미지를 불러오는 중 오류가 발생했습니다.',
        );
      }
    }
  }

  void _showRegionPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                border: const Border(
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
        heroTag: 'edit_profile_nav', // Hero 태그 충돌 방지
        transitionBetweenRoutes: false, // Hero 애니메이션 비활성화
        middle: const Text('프로필 수정'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.back,
            color: AppColors.primary,
          ),
        ),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _handleSave,
                child: const Text(
                  '저장',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지 섹션
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        image: _profileImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_profileImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImageBytes == null
                          ? const Icon(
                              CupertinoIcons.person,
                              size: 50,
                              color: CupertinoColors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _pickImage,
                      child: const Text(
                        '사진 변경',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 이메일 (수정 불가)
              _buildLabel('이메일'),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.5),
                  borderRadius: AppBorderRadius.medium,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.currentProfile['email'] as String? ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.lock,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                '이메일은 변경할 수 없습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 사용자명
              _buildLabel('사용자명'),
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
              if (_usernameError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _usernameError!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // 지역
              _buildLabel('지역'),
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
                      Text(_selectedRegion),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                '날씨 정보 및 맞춤 추천에 활용됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
