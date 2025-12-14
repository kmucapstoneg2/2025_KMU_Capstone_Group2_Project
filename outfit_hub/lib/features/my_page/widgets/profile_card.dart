import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/theme.dart';

/// ============================================
/// 프로필 카드
/// ============================================

class ProfileCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback? onEditTap;

  const ProfileCard({super.key, required this.user, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    final username = user['username'] as String;
    final email = user['email'] as String;
    final profileImageUrl = user['profileImageUrl'] as String?;
    
    // base64 이미지를 Uint8List로 변환
    Uint8List? imageBytes;
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      try {
        if (profileImageUrl.startsWith('data:image')) {
          // data:image/jpeg;base64,... 형식
          final base64String = profileImageUrl.split(',').last;
          imageBytes = base64Decode(base64String);
        } else {
          // base64만 있는 경우
          imageBytes = base64Decode(profileImageUrl);
        }
      } catch (e) {
        // base64 디코딩 실패 시 null로 유지
        imageBytes = null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // 프로필 이미지
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  image: imageBytes != null
                      ? DecorationImage(
                          image: MemoryImage(imageBytes),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageBytes == null
                    ? const Icon(
                        CupertinoIcons.person,
                        size: 40,
                        color: CupertinoColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 수정 버튼 (오른쪽 상단)
          if (onEditTap != null)
            Positioned(
              top: 0,
              right: 0,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onEditTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.pencil,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
