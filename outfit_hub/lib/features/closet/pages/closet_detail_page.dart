import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/closet_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 옷장 상세 페이지
/// ============================================

class ClosetDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ClosetDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<ClosetDetailPage> createState() => _ClosetDetailPageState();
}

class _ClosetDetailPageState extends State<ClosetDetailPage> {
  late TextEditingController nameController;
  late TextEditingController linkController;

  XFile? newImage;
  bool isLiked = false;
  bool isLoadingLike = true;

  String? selectedSeason;
  String? selectedStyle;
  String? selectedType;
  String? selectedColor;
  String? selectedMaterial;

  @override
  void initState() {
    super.initState();
    // ClothesItem.toMap()에서 사용하는 필드명에 맞춰 수정
    nameController = TextEditingController(text: widget.item["name"] ?? "");
    linkController = TextEditingController(
      text: widget.item["purchase_link"] ?? "",
    );

    // 기존 값을 제대로 가져오기
    selectedSeason = widget.item["season_name"];
    selectedStyle = widget.item["style_name"];
    selectedType = widget.item["item_type_name"]; // type_name -> item_type_name
    selectedColor = widget.item["color_name"];
    selectedMaterial = widget.item["material_name"];

    print('[ClosetDetailPage] initState - selectedSeason: $selectedSeason');
    print('[ClosetDetailPage] initState - selectedStyle: $selectedStyle');
    print('[ClosetDetailPage] initState - selectedType: $selectedType');
    print('[ClosetDetailPage] initState - selectedColor: $selectedColor');
    print('[ClosetDetailPage] initState - selectedMaterial: $selectedMaterial');

    _loadLikeStatus();
  }

  @override
  void dispose() {
    nameController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> _loadLikeStatus() async {
    try {
      final liked = await ClosetLogic.isLiked(widget.item['cloth_id']);
      setState(() {
        isLiked = liked;
        isLoadingLike = false;
      });
    } catch (e) {
      setState(() => isLoadingLike = false);
    }
  }

  Future<void> _toggleLike() async {
    try {
      final newStatus = await ClosetLogic.toggleWishlist(widget.item['cloth_id']);
      setState(() => isLiked = newStatus);
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        final compressed = await ImageHelper.compressImage(File(image.path));
        setState(() => newImage = XFile(compressed.path));
      } catch (e) {
        if (mounted) {
          await ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _save() async {
    final provider = context.read<ClosetProvider>();

    final validationError = ClosetValidationLogic.validateUpdateCloth(
      name: nameController.text,
      price: null,
    );

    if (validationError != null) {
      await DialogHelper.showAlert(
        context,
        title: '알림',
        content: validationError,
      );
      return;
    }

    DialogHelper.showLoading(context);

    try {
      final updates = <String, dynamic>{
        'name': nameController.text.trim(),
      };

      if (linkController.text.trim().isNotEmpty) {
        updates['purchase_link'] = linkController.text.trim();
      }

      if (selectedSeason != null) {
        updates['seasonName'] = selectedSeason;
      }
      if (selectedStyle != null) {
        updates['styleName'] = selectedStyle;
      }
      if (selectedType != null) {
        updates['itemTypeName'] = selectedType;
      }
      if (selectedColor != null) {
        updates['colorName'] = selectedColor;
      }
      if (selectedMaterial != null) {
        updates['materialName'] = selectedMaterial;
      }

      final token = context.read<AuthProvider>().accessToken;
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 이미지가 변경된 경우 새 옷으로 등록하고 기존 옷 삭제
      if (newImage != null) {
        print('[ClosetDetailPage] 이미지 변경됨 - 새 옷 등록 및 기존 옷 삭제');
        await ClosetLogic.addCloth(
          token: token,
          categoryName: widget.item['category_name'],
          colorName: selectedColor ?? widget.item['color_name'],
          materialName: selectedMaterial ?? widget.item['material_name'],
          name: nameController.text.trim(),
          seasonName: selectedSeason,
          styleName: selectedStyle,
          itemTypeName: selectedType,
          imageFile: File(newImage!.path),
        );
        await ClosetLogic.deleteCloth(token: token, clothId: widget.item['cloth_id']);
      } else {
        // 이미지 변경 없이 데이터만 수정
        await ClosetLogic.updateCloth(
          token: token,
          clothId: widget.item['cloth_id'],
          updates: updates,
        );
      }
      await provider.loadClothes(token);

      if (mounted) {
        DialogHelper.hideLoading(context);
        await DialogHelper.showSuccess(
          context,
          content: '옷 정보가 저장되었습니다',
          onConfirm: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.hideLoading(context);
        await ErrorHandler.showError(context, e, onRetry: _save);
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await DialogHelper.showDeleteConfirm(
      context,
      title: '옷을 삭제하시겠습니까?',
      content: '이 작업은 되돌릴 수 없습니다.',
    );

    if (!confirmed) return;

    DialogHelper.showLoading(context);

    try {
      final token = context.read<AuthProvider>().accessToken;
      if (token == null) {
        throw Exception('로그인이 필요합니다');
      }

      await ClosetLogic.deleteCloth(
        token: token,
        clothId: widget.item['cloth_id'],
      );
      
      // 옷장 목록 새로고침
      await context.read<ClosetProvider>().loadClothes(token);

      if (mounted) {
        DialogHelper.hideLoading(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.hideLoading(context);
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _openLink() async {
    final link = linkController.text.trim();

    if (link.isEmpty) {
      await DialogHelper.showAlert(
        context,
        title: '알림',
        content: '구매 링크가 없습니다',
      );
      return;
    }

    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('링크를 열 수 없습니다');
      }
    } catch (e) {
      if (mounted) {
        await DialogHelper.showAlert(
          context,
          title: '오류',
          content: '링크를 열 수 없습니다',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClosetProvider>(
      builder: (context, provider, child) {
        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            middle: Container(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoadingLike)
                  const CupertinoActivityIndicator()
                else
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _toggleLike,
                    child: Icon(
                      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: isLiked ? CupertinoColors.systemRed : null,
                    ),
                  ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _delete,
                  child: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildImage(),
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppShadows.card,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.camera,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '사진 변경',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const Text("옷 이름", style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: nameController,
                    placeholder: "옷 이름 입력",
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  ChipSection(
                    title: "계절",
                    items: provider.seasons.isEmpty
                        ? ['봄', '여름', '가을', '겨울', '사계절']
                        : provider.seasons
                            .map((s) => s['season_name'] as String)
                            .toList(),
                    selectedValue: selectedSeason,
                    onSelect: (v) => setState(() => selectedSeason = v),
                  ),

                  ChipSection(
                    title: "스타일",
                    items: provider.styles.isEmpty
                        ? ['캐쥬얼', '포멀', '스트릿', '모던', '클래식', '스포츠']
                        : provider.styles
                            .map((s) => s['style_name'] as String)
                            .toList(),
                    selectedValue: selectedStyle,
                    onSelect: (v) => setState(() => selectedStyle = v),
                  ),

                  ChipSection(
                    title: "옷 종류",
                    items: provider.types.isEmpty
                        ? ['셔츠', '티셔츠', '맨투맨', '후드티', '니트', '드레스', '원피스', '치마', '반바지', '청바지', '자켓', '코트', '운동화']
                        : provider.types
                            .map((t) => t['type_name'] as String)
                            .toList(),
                    selectedValue: selectedType,
                    onSelect: (v) => setState(() => selectedType = v),
                  ),

                  ChipSection(
                    title: "색상",
                    items: provider.colors.isEmpty
                        ? ['화이트', '블랙', '블루', '네이비', '그레이', '브라운', '레드', '핑크']
                        : provider.colors
                            .map((c) => c['color_name'] as String)
                            .toList(),
                    selectedValue: selectedColor,
                    onSelect: (v) => setState(() => selectedColor = v),
                  ),

                  ChipSection(
                    title: "재질",
                    items: provider.materials.isEmpty
                        ? ['면', '니트', '데님', '가죽', '비스코스', '울', '나일론', '폴리에스터르']
                        : provider.materials
                            .map((m) => m['material_name'] as String)
                            .toList(),
                    selectedValue: selectedMaterial,
                    onSelect: (v) => setState(() => selectedMaterial = v),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  const Text("구매 링크 (선택)", style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: linkController,
                          placeholder: "URL 입력",
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      CupertinoButton(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        color: AppColors.primary,
                        onPressed: _openLink,
                        child: const Icon(
                          CupertinoIcons.link,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    text: "저장하기",
                    onPressed: _save,
                    width: double.infinity,
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    if (newImage != null) {
      return Image.file(
        File(newImage!.path),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final imageUrl = widget.item['image_url'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // HTTP/HTTPS URL이면 네트워크 이미지, 아니면 로컬 파일
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                CupertinoIcons.photo,
                size: 60,
                color: AppColors.textSecondary,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
        );
      } else {
        return Image.file(
          File(imageUrl),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                CupertinoIcons.photo,
                size: 60,
                color: AppColors.textSecondary,
              ),
            );
          },
        );
      }
    }

    return const Center(
      child: Icon(
        CupertinoIcons.photo,
        size: 60,
        color: AppColors.textSecondary,
      ),
    );
  }
}
