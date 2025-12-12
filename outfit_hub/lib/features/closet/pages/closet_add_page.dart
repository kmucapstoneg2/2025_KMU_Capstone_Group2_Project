import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/closet_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 옷 추가 페이지
/// ============================================

class ClosetAddPage extends StatefulWidget {
  const ClosetAddPage({super.key});

  @override
  State<ClosetAddPage> createState() => _ClosetAddPageState();
}

class _ClosetAddPageState extends State<ClosetAddPage> {
  final nameController = TextEditingController();
  final linkController = TextEditingController();

  XFile? selectedImage;
  bool isProcessing = false;

  String? selectedCategory;
  String? selectedSeason;
  String? selectedStyle;
  String? selectedType;
  String? selectedColor;
  String? selectedMaterial;

  @override
  void dispose() {
    nameController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => isProcessing = true);

      try {
        final compressed = await ImageHelper.compressImage(File(image.path));
        setState(() {
          selectedImage = XFile(compressed.path);
          isProcessing = false;
        });
      } catch (e) {
        setState(() => isProcessing = false);
        if (mounted) {
          await ErrorHandler.showError(context, e);
        }
      }
    }
  }

  Future<void> _submit() async {
    final provider = context.read<ClosetProvider>();

    final categoryId = selectedCategory != null
        ? ClosetLogic.findCodeId(provider.categories, selectedCategory!, 'category')
        : null;
    final colorId = selectedColor != null
        ? ClosetLogic.findCodeId(provider.colors, selectedColor!, 'color')
        : null;
    final materialId = selectedMaterial != null
        ? ClosetLogic.findCodeId(provider.materials, selectedMaterial!, 'material')
        : null;

    final validationError = ClosetValidationLogic.validateAddCloth(
      name: nameController.text,
      categoryId: categoryId,
      colorId: colorId,
      materialId: materialId,
      price: null, // 가격 제거
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
      final seasonId = selectedSeason != null
          ? ClosetLogic.findCodeId(provider.seasons, selectedSeason!, 'season')
          : null;
      final styleId = selectedStyle != null
          ? ClosetLogic.findCodeId(provider.styles, selectedStyle!, 'style')
          : null;
      final typeId = selectedType != null
          ? ClosetLogic.findCodeId(provider.types, selectedType!, 'type')
          : null;

      await ClosetLogic.addCloth(
        categoryId: categoryId!,
        colorId: colorId!,
        materialId: materialId!,
        name: nameController.text.trim(),
        seasonId: seasonId,
        styleId: styleId,
        typeId: typeId,
        price: null, // 가격 제거
        imageUrl: selectedImage?.path,
        purchaseLink: linkController.text.trim().isNotEmpty
            ? linkController.text.trim()
            : null,
      );

      if (mounted) {
        await provider.loadClothes();
        DialogHelper.hideLoading(context);
        
        await DialogHelper.showSuccess(
          context,
          content: '옷이 등록되었습니다',
          onConfirm: () => Navigator.pop(context, true),
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.hideLoading(context);
        await ErrorHandler.showError(context, e, onRetry: _submit);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClosetProvider>(
      builder: (context, provider, child) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(
            middle: Text('옷 추가'),
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
                      height: 260,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: isProcessing
                          ? const AppLoadingIndicator()
                          : selectedImage == null
                              ? const Center(
                                  child: Text(
                                    "사진을 선택해주세요",
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    File(selectedImage!.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  PrimaryButton(
                    text: "사진 선택하기",
                    icon: CupertinoIcons.photo,
                    onPressed: _pickImage,
                    width: double.infinity,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const Text(
                    "옷 이름 (별명)",
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: nameController,
                    placeholder: "예: 데일리 셔츠 / 검정 후드 / 하객룩 원피스",
                  ),

                  const SizedBox(height: AppSpacing.xl),

                                    ChipSection(
                    title: "카테고리",
                    items: provider.categories
                        .map((c) => c['category_name'] as String)
                        .toList(),
                    selectedValue: selectedCategory,
                    onSelect: (v) => setState(() => selectedCategory = v),
                  ),

                  ChipSection(
                    title: "계절",
                    items: provider.seasons
                        .map((s) => s['season_name'] as String)
                        .toList(),
                    selectedValue: selectedSeason,
                    onSelect: (v) => setState(() => selectedSeason = v),
                  ),

                  ChipSection(
                    title: "스타일",
                    items: provider.styles
                        .map((s) => s['style_name'] as String)
                        .toList(),
                    selectedValue: selectedStyle,
                    onSelect: (v) => setState(() => selectedStyle = v),
                  ),

                  ChipSection(
                    title: "옷 종류",
                    items: provider.types
                        .map((t) => t['type_name'] as String)
                        .toList(),
                    selectedValue: selectedType,
                    onSelect: (v) => setState(() => selectedType = v),
                  ),

                  ChipSection(
                    title: "색상",
                    items: provider.colors
                        .map((c) => c['color_name'] as String)
                        .toList(),
                    selectedValue: selectedColor,
                    onSelect: (v) => setState(() => selectedColor = v),
                  ),

                  ChipSection(
                    title: "재질",
                    items: provider.materials
                        .map((m) => m['material_name'] as String)
                        .toList(),
                    selectedValue: selectedMaterial,
                    onSelect: (v) => setState(() => selectedMaterial = v),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  const Text("구매 링크 (선택)", style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    controller: linkController,
                    placeholder: "URL 입력",
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  PrimaryButton(
                    text: "등록 하기",
                    onPressed: _submit,
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
}
