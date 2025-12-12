import 'package:flutter/foundation.dart';
import '../data/storage.dart';
import '../core/error/exceptions.dart';

/// ============================================
/// 커뮤니티 Provider
/// ============================================

class CommunityProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 초기화
  Future<void> init() async {
    await loadPosts();
  }

  /// 게시물 로드
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
            _posts = await Storage.getSharedOutfits();
    } catch (e) {
      _error = e.toString();
      throw StorageException('게시물을 불러오는데 실패했습니다');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike(String outfitId) async {
    try {
      final isLiked = await Storage.isLiked(outfitId);

      if (isLiked) {
        await Storage.removeLike(outfitId);
      } else {
        await Storage.addLike(outfitId);
      }

      await loadPosts();
    } catch (e) {
      throw StorageException('좋아요 처리에 실패했습니다');
    }
  }

  /// 좋아요 여부 확인
  Future<bool> isLiked(String outfitId) async {
    try {
      return await Storage.isLiked(outfitId);
    } catch (e) {
      return false;
    }
  }

  /// 댓글 추가
  Future<void> addComment({
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
      notifyListeners();
    } catch (e) {
      throw StorageException('댓글 추가에 실패했습니다');
    }
  }

  /// 댓글 목록 조회
  Future<List<Map<String, dynamic>>> getComments(String outfitId) async {
    try {
      return await Storage.getComments(outfitId);
    } catch (e) {
      throw StorageException('댓글을 불러오는데 실패했습니다');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String interactionId) async {
    try {
      await Storage.deleteComment(interactionId);
      notifyListeners();
    } catch (e) {
      throw StorageException('댓글 삭제에 실패했습니다');
    }
  }
}
