import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/outfit_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';

/// ============================================
/// 코디 추가 페이지
/// ============================================

class AddCoordiPage extends StatefulWidget {
  const AddCoordiPage({super.key});

  @override
  State<AddCoordiPage> createState() => _AddCoordiPageState();
}

class _AddCoordiPageState extends State<AddCoordiPage> {
  XFile? selectedImage;
  bool isProcessing = false;
  bool isShared = false;

  List<Map<String, dynamic>> allClothes = [];
  List<String> selectedClothIds = [];
  Map<String, dynamic>? weather;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clothes = await CoordiLogic.getClothes();
      final todayWeather = await CoordiLogic.getTodayWeather();

      setState(() {
        allClothes = clothes;
        weather = todayWeather;
      });
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e, onRetry: _loadData);
      }
    }
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

  Future<void> _showClothSelector() async {
    final result = await showCupertinoModalPopup<List<String>>(
      context: context,
      builder: (context) => ClothSelectorModal(
        clothes: allClothes,
        selectedClothIds: selectedClothIds,
      ),
    );

    if (result != null) {
      setState(() {
        selectedClothIds = result;
      });
    }
  }

  void _removeCloth(String clothId) {
    setState(() {
      selectedClothIds.remove(clothId);
    });
  }

  Future<void> _save() async {
    final weatherId = weather?['weather_id'] as String?;
    final validationError = CoordiValidationLogic.validateSaveOutfit(
      clothIds: selectedClothIds,
      weatherId: weatherId,
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
      await CoordiLogic.saveOutfit(
        weatherId: weatherId!,
        clothIds: selectedClothIds,
        isShared: isShared,
        aiGenImageUrl: selectedImage?.path,
        jsonbData: {
          'description': '나만의 코디',
          'style': '데일리',
        },
      );

      if (mounted) {
        await context.read<OutfitProvider>().loadOutfits();
        DialogHelper.hideLoading(context);

        await DialogHelper.showSuccess(
          context,
          content: '코디가 저장되었습니다',
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

  @override
  Widget build(BuildContext context) {
    final selectedClothes = allClothes
        .where((cloth) => selectedClothIds.contains(cloth['cloth_id']))
        .toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('코디 추가'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImagePickerSection(
                selectedImage: selectedImage,
                onPick: _pickImage,
                isProcessing: isProcessing,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                '옷 선택',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                text: '옷 선택하기',
                icon: CupertinoIcons.square_grid_2x2,
                onPressed: _showClothSelector,
                width: double.infinity,
              ),
              const SizedBox(height: AppSpacing.md),
              SelectedClothesPreview(
                selectedClothes: selectedClothes,
                onRemove: _removeCloth,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '커뮤니티에 공유',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '다른 사람들과 코디를 공유합니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: isShared,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          isShared = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (weather != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryLight.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.cloud_sun,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '오늘의 날씨',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(weather!['weather_data'] as Map)['temperature']}°C, ${(weather!['weather_data'] as Map)['condition']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: '저장하기',
                onPressed: _save,
                width: double.infinity,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
