import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/error/error_handler.dart';
import '../../../providers/community_provider.dart';
import '../logic/logic.dart';
import '../widgets/widgets.dart';
import 'post_detail_page.dart';

/// ============================================
/// 커뮤니티 페이지
/// ============================================

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final Map<String, bool> _likedPosts = {};
  final Map<String, bool> _dislikedPosts = {};

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  Future<void> _loadLikeStatus() async {
    final provider = context.read<CommunityProvider>();
    for (final post in provider.posts) {
      final outfitId = post['outfit_id'] as String;
      final isLiked = await PostLogic.isLiked(outfitId);
      setState(() {
        _likedPosts[outfitId] = isLiked;
        _dislikedPosts[outfitId] = false; // 싫어요는 별도 로직 필요
      });
    }
  }

  Future<void> _toggleLike(String outfitId) async {
    try {
      final newStatus = await PostLogic.toggleLike(outfitId);
      setState(() {
        _likedPosts[outfitId] = newStatus;
        if (newStatus) {
          _dislikedPosts[outfitId] = false; // 좋아요 누르면 싫어요 해제
        }
      });
      if (mounted) {
        await context.read<CommunityProvider>().loadPosts();
      }
    } catch (e) {
      if (mounted) {
        await ErrorHandler.showError(context, e);
      }
    }
  }

  Future<void> _toggleDislike(String outfitId) async {
    setState(() {
      final currentStatus = _dislikedPosts[outfitId] ?? false;
      _dislikedPosts[outfitId] = !currentStatus;
      if (!currentStatus) {
        _likedPosts[outfitId] = false; // 싫어요 누르면 좋아요 해제
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('커뮤니티'),
            ),
            child: const AppLoadingIndicator(),
          );
        }

                if (provider.error != null) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('커뮤니티'),
            ),
            child: ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadPosts(),
            ),
          );
        }

        if (provider.posts.isEmpty) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('커뮤니티'),
            ),
            child: const EmptyState(
              icon: CupertinoIcons.person_2,
              message: '공유된 코디가 없습니다',
            ),
          );
        }

        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('커뮤니티'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => provider.loadPosts(),
              child: const Icon(CupertinoIcons.refresh),
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await provider.loadPosts();
                    await _loadLikeStatus();
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = provider.posts[index];
                        final outfitId = post['outfit_id'] as String;
                        final isLiked = _likedPosts[outfitId] ?? false;
                        final isDisliked = _dislikedPosts[outfitId] ?? false;

                        return PostCard(
                          post: post,
                          isLiked: isLiked,
                          isDisliked: isDisliked,
                          onLike: () => _toggleLike(outfitId),
                          onDislike: () => _toggleDislike(outfitId),
                          onComment: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => PostDetailPage(post: post),
                              ),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => PostDetailPage(post: post),
                              ),
                            );
                          },
                        );
                      },
                      childCount: provider.posts.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
