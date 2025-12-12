import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// ============================================
/// 이미지 헬퍼
/// ============================================

class ImageHelper {
  /// 이미지 압축 (고품질)
  static Future<File> compressImage(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = path.join(
        dir.path,
        'images',
        '${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // images 폴더 생성
      await Directory(path.dirname(targetPath)).create(recursive: true);

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: AppConstants.imageQuality,
        minWidth: AppConstants.maxImageWidth,
        minHeight: AppConstants.maxImageHeight,
      );

      if (result == null) {
        throw ImageProcessingException('이미지 압축에 실패했습니다');
      }

      return File(result.path);
    } catch (e) {
      throw ImageProcessingException('이미지 압축 중 오류가 발생했습니다: $e');
    }
  }

  /// 썸네일 생성 (저품질)
  static Future<File> createThumbnail(File file) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final targetPath = path.join(
        dir.path,
        'thumbnails',
        '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg',
      );

      await Directory(path.dirname(targetPath)).create(recursive: true);

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: AppConstants.thumbnailQuality,
        minWidth: AppConstants.thumbnailSize,
        minHeight: AppConstants.thumbnailSize,
      );

      if (result == null) {
        throw ImageProcessingException('썸네일 생성에 실패했습니다');
      }

      return File(result.path);
    } catch (e) {
      throw ImageProcessingException('썸네일 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 이미지 삭제
  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('이미지 삭제 실패: $e');
    }
  }

  /// 이미지 폴더 정리 (오래된 파일 삭제)
  static Future<void> cleanupOldImages({
    int daysToKeep = AppConstants.oldImageCleanupDays,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(dir.path, 'images'));
      final thumbnailsDir = Directory(path.join(dir.path, 'thumbnails'));

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      for (final dir in [imagesDir, thumbnailsDir]) {
        if (await dir.exists()) {
          await for (final entity in dir.list()) {
            if (entity is File) {
              final stat = await entity.stat();
              if (stat.modified.isBefore(cutoffDate)) {
                await entity.delete();
              }
            }
          }
        }
      }
    } catch (e) {
      print('이미지 정리 실패: $e');
    }
  }

  /// 이미지 파일 크기 확인
  static Future<bool> isValidSize(File file) async {
    try {
      final bytes = await file.length();
      final mb = bytes / (1024 * 1024);
      return mb <= AppConstants.maxImageSizeInMB;
    } catch (e) {
      return false;
    }
  }
}
