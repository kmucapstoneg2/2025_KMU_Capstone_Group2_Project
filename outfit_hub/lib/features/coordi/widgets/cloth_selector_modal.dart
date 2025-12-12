import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/theme.dart';

/// ============================================
/// 옷 선택 모달
/// ============================================

class ClothSelectorModal extends StatefulWidget {
  final List<Map<String, dynamic>> clothes;
  final List<String> selectedClothIds;

  const ClothSelectorModal({
    super.key,
    required this.clothes,
    required this.selectedClothIds,
  });

  @override
  State<ClothSelectorModal> createState() => _ClothSelectorModalState();
}

class _ClothSelectorModalState extends State<ClothSelectorModal> {
  late List<String> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = List.from(widget.selectedClothIds);
  }

  void _toggleSelection(String clothId) {
    setState(() {
      if (selectedIds.contains(clothId)) {
        selectedIds.remove(clothId);
      } else {
        selectedIds.add(clothId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                Text(
                  '옷 선택 (${selectedIds.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context, selectedIds),
                  child: const Text('완료'),
                ),
              ],
            ),
          ),

          // 옷 그리드
          Expanded(
            child: widget.clothes.isEmpty
                ? const Center(
                    child: Text(
                      '옷이 없습니다',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 140,
                    ),
                    itemCount: widget.clothes.length,
                    itemBuilder: (context, index) {
                      final cloth = widget.clothes[index];
                      final clothId = cloth['cloth_id'] as String;
                      final name = cloth['name'] as String;
                      final imageUrl = cloth['image_url'] as String?;
                      final isSelected = selectedIds.contains(clothId);

                      return GestureDetector(
                        onTap: () => _toggleSelection(clothId),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 이미지
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      if (imageUrl != null)
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.file(
                                            File(imageUrl),
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                CupertinoIcons.photo,
                                                color: AppColors.textSecondary,
                                              );
                                            },
                                          ),
                                        )
                                      else
                                        const Center(
                                          child: Icon(
                                            CupertinoIcons.photo,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      // 선택 체크
                                      if (isSelected)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.check_mark,
                                              size: 16,
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // 이름
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
