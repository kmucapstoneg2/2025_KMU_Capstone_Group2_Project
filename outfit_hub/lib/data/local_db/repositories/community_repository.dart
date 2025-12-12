import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../database_helper.dart';

/// ============================================
/// 커뮤니티 Repository
/// ============================================

class CommunityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// 좋아요 추가
  Future<String> addLike({
    required String outfitId,
    required String userId,
  }) async {
    final db = await _dbHelper.database;
    final interactionId = _uuid.v4();

    await db.insert('community_interactions', {
      'interaction_id': interactionId,
      'outfit_id': outfitId,
      'user_id': userId,
      'parent_comment_id': null,
      'interaction_type': 'like',
      'content': null,
      'created_at': DateTime.now().toIso8601String(),
    });

    return interactionId;
  }

  /// 좋아요 삭제
  Future<void> removeLike({
    required String outfitId,
    required String userId,
  }) async {
    final db = await _dbHelper.database;

    await db.delete(
      'community_interactions',
      where: 'outfit_id = ? AND user_id = ? AND interaction_type = ?',
      whereArgs: [outfitId, userId, 'like'],
    );
  }

  /// 좋아요 여부 확인
  Future<bool> isLiked({
    required String outfitId,
    required String userId,
  }) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'community_interactions',
      where: 'outfit_id = ? AND user_id = ? AND interaction_type = ?',
      whereArgs: [outfitId, userId, 'like'],
    );

    return result.isNotEmpty;
  }

  /// 댓글 추가
  Future<String> addComment({
    required String outfitId,
    required String userId,
    required String content,
    String? parentCommentId,
  }) async {
    final db = await _dbHelper.database;
    final interactionId = _uuid.v4();

    await db.insert('community_interactions', {
      'interaction_id': interactionId,
      'outfit_id': outfitId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'interaction_type': 'comment',
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });

    return interactionId;
  }

  /// 댓글 목록 조회
  Future<List<Map<String, dynamic>>> getComments({
    required String outfitId,
  }) async {
    final db = await _dbHelper.database;

    return await db.query(
      'community_interactions',
      where: 'outfit_id = ? AND interaction_type = ?',
      whereArgs: [outfitId, 'comment'],
      orderBy: 'created_at ASC',
    );
  }

  /// 댓글 삭제
  Future<void> deleteComment(String interactionId) async {
    final db = await _dbHelper.database;

    await db.delete(
      'community_interactions',
      where: 'interaction_id = ?',
      whereArgs: [interactionId],
    );
  }

  /// 특정 코디의 좋아요 수 조회
  Future<int> getLikeCount(String outfitId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM community_interactions 
      WHERE outfit_id = ? AND interaction_type = ?
    ''', [outfitId, 'like']);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 특정 코디의 댓글 수 조회
  Future<int> getCommentCount(String outfitId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM community_interactions 
      WHERE outfit_id = ? AND interaction_type = ?
    ''', [outfitId, 'comment']);

    return Sqflite.firstIntValue(result) ?? 0;
  }
}
