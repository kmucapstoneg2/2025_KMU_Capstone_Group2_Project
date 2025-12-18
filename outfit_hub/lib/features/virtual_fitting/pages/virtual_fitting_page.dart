import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/closet_provider.dart';
import '../logic/virtual_fitting_logic.dart';

/// ============================================
/// 가상 피팅 페이지
/// ============================================

class VirtualFittingPage extends StatefulWidget {
  const VirtualFittingPage({super.key});

  @override
  State<VirtualFittingPage> createState() => _VirtualFittingPageState();
}

class _VirtualFittingPageState extends State<VirtualFittingPage> {
  List<Map<String, dynamic>> selectedClothes = [];
  bool isLoading = false;
  File? _userImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('가상 피팅'),
      ),
      child: SafeArea(
        child: Consumer<ClosetProvider>(
          builder: (context, closetProvider, child) {
            final clothes = closetProvider.clothes;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 선택된 의류 표시
                        if (selectedClothes.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '선택된 의류',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedClothes.length,
                                  itemBuilder: (context, index) {
                                    final cloth = selectedClothes[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: AppSpacing.md),
                                      child: GestureDetector(
                                        onLongPress: () {
                                          setState(() {
                                            selectedClothes.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: AppColors.greyLight,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppColors.primary,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                    top: Radius.circular(10),
                                                  ),
                                                  child: Image.network(
                                                    cloth['imageUrl'] ?? '',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                        CupertinoIcons
                                                            .photo,
                                                        color: AppColors
                                                            .textSecondary,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Text(
                                                  cloth['name'] ?? '의류',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoButton(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      color: AppColors.greyLight,
                                      onPressed: isLoading ? null : _pickUserImage,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(CupertinoIcons.photo_on_rectangle),
                                          SizedBox(width: 8),
                                          Text('내 사진 선택'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  if (_userImageFile != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _userImageFile!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (selectedClothes.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: PrimaryButton(
                                        text: '가상 피팅 시작',
                                        onPressed: isLoading
                                            ? null
                                            : () => _showVirtualFittingDialog(),
                                        isLoading: isLoading,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        setState(() {
                                          selectedClothes.clear();
                                        });
                                      },
                                      child: const Icon(
                                        CupertinoIcons.trash,
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  CupertinoIcons.person_crop_square,
                                  size: 80,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(height: AppSpacing.lg),
                                Text(
                                  '의류를 선택하세요',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm),
                                Text(
                                  'AI 기술로 가상 피팅을 해볼 수 있습니다',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          '내 의류 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= clothes.length) {
                        return const SizedBox.shrink();
                      }

                      final cloth = clothes[index];
                      final isSelected = selectedClothes.any(
                        (item) => item['clothID'] == cloth['clothID'],
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedClothes.removeWhere(
                                (item) =>
                                    item['clothID'] == cloth['clothID'],
                              );
                            } else {
                              selectedClothes.add(cloth);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.background,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11),
                                  ),
                                  child: Image.network(
                                    cloth['imageUrl'] ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                        stackTrace) {
                                      return Container(
                                        color: AppColors.greyLight,
                                        child: const Icon(
                                          CupertinoIcons.photo,
                                          color: AppColors.textSecondary,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cloth['name'] ?? '의류',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cloth['categoryName'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: clothes.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickUserImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1080);
      if (picked != null) {
        setState(() {
          _userImageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _showVirtualFittingDialog() async {
    if (_userImageFile == null) {
      if (mounted) {
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('알림'),
            content: const Text('사용자 사진을 선택해야 가상 피팅을 진행할 수 있습니다'),
            actions: [
              CupertinoDialogAction(
                child: const Text('확인'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
      return;
    }

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('가상 피팅'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // 사용자 사진 미리보기
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _userImageFile!,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '선택된 의류',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...selectedClothes.map((cloth) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${cloth['name']} (${cloth['categoryName']})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이 사진에 선택된 의류를 입혀볼까요?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('생성하기'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _generateVirtualFitting(_userImageFile!);
    }
  }

  Future<void> _generateVirtualFitting(File userImageFile) async {
    setState(() => isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.checkAndHandleToken();
      final token = authProvider.accessToken;

      if (token == null) {
        throw Exception('로그인이 필요합니다. 다시 로그인 후 시도해주세요.');
      }

      final imageUrl = await VirtualFittingLogic.generateFitting(
        selectedClothes,
        userImageFile: userImageFile,
        token: token,
      );

      if (mounted) {
        // 생성된 이미지를 표시하고 공유 옵션 제공
        await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('가상 피팅 완료'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 300,
                      width: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: 300,
                          color: AppColors.greyLight,
                          child: const Icon(
                            CupertinoIcons.photo,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '생성된 가상 피팅 이미지입니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('닫기'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('커뮤니티에 공유'),
                onPressed: () async {
                  Navigator.pop(context);
                  await _shareToCoordinator(imageUrl, token);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _shareToCoordinator(String imageUrl, String token) async {
    final descriptionController = TextEditingController();

    final shouldShare = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('커뮤니티에 공유'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                '설명을 입력해주세요:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: descriptionController,
                placeholder: '이 코디에 대한 설명을 입력해주세요',
                maxLines: 3,
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 12),
              const Text(
                '(태그는 자동으로 추가됩니다)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('공유하기'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldShare == true) {
      try {
        setState(() => isLoading = true);

        // 선택된 의류의 카테고리로 태그 생성
        final tags = selectedClothes
            .map((cloth) => cloth['categoryName'] as String? ?? '')
            .where((tag) => tag.isNotEmpty)
            .toList();

        await VirtualFittingLogic.shareFitting(
          imageUrl: imageUrl,
          description: descriptionController.text,
          tags: tags,
          token: token,
        );

        if (mounted) {
          await DialogHelper.showAlert(
            context,
            title: '공유 완료',
            content: '가상 피팅이 커뮤니티에 공유되었습니다!',
          );

          // 선택된 의류 초기화
          setState(() {
            selectedClothes.clear();
            _userImageFile = null;
          });
        }
      } catch (e) {
        if (mounted) {
          await ErrorHandler.showError(context, e);
        }
      } finally {
        setState(() => isLoading = false);
        descriptionController.dispose();
      }
    } else {
      descriptionController.dispose();
    }
  }
}
