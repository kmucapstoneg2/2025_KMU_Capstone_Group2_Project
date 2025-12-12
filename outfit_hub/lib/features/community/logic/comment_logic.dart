import '../../../data/storage.dart';
import '../../../core/error/exceptions.dart';

/// ============================================
/// 댓글 비즈니스 로직
/// ============================================

class CommentLogic {
  /// 댓글 추가
  static Future<void> addComment({
    required String outfitId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      await Storage.addComment(
        outfitId: outfitId,
        content: content,
        parentCommentId: parentCommentId,
      );
    } catch (e) {
      throw StorageException('댓글 추가에 실패했습니다');
    }
  }

  /// 댓글 목록 조회
  static Future<List<Map<String, dynamic>>> getComments(
    String outfitId,
  ) async {
    try {
      return await Storage.getComments(outfitId);
    } catch (e) {
      throw StorageException('댓글을 불러오는데 실패했습니다');
    }
  }

  /// 댓글 삭제
  static Future<void> deleteComment(String interactionId) async {
    try {
      await Storage.deleteComment(interactionId);
    } catch (e) {
      throw StorageException('댓글 삭제에 실패했습니다');
    }
  }
}
