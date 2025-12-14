package com.outfit.ai.cloth_app.controller;

import com.outfit.ai.cloth_app.dto.CommentDto;
import com.outfit.ai.cloth_app.dto.CommunityDto;
import com.outfit.ai.cloth_app.service.CommunityService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.nio.file.AccessDeniedException;
import java.util.List;
import java.util.UUID;

// 게시글 컨트롤러
@RestController
@RequestMapping("/posts")
public class CommunityController {
    private final CommunityService communityService;

    public CommunityController(CommunityService communityService) {
        this.communityService = communityService;
    }

    // 현재 유저 ID에서 인증 확인
    private UUID getAuthenticatedUserId() throws AccessDeniedException {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getPrincipal())) {
            throw new AccessDeniedException("로그인이 필요합니다.");
        }

        return UUID.fromString(authentication.getName());
    }

    // 모든 게시글 확인 (GET /posts)
    @GetMapping
    public ResponseEntity<List<CommunityDto>> getAllPost() {
        List<CommunityDto> posts = communityService.getAllPost();
        return ResponseEntity.ok(posts);
    }

    // 게시글 생성 (POST /posts)
    @PostMapping
    public ResponseEntity<CommunityDto> createPost(@RequestBody CommunityDto postDto) throws AccessDeniedException {
        UUID authorId = getAuthenticatedUserId();
        CommunityDto createdPost = communityService.createPost(authorId, postDto);
        return ResponseEntity.ok(createdPost);
    }

    // 게시글 수정 (PUT /posts/{id})
    @PutMapping("/{id}")
    public ResponseEntity<CommunityDto> updatePost(@PathVariable String id, @RequestBody CommunityDto postDto) throws AccessDeniedException {
        UUID postId = UUID.fromString(id);
        UUID userId = getAuthenticatedUserId();

        CommunityDto updatedPost = communityService.updatePost(postId, userId, postDto);
        return ResponseEntity.ok(updatedPost);
    }

    // 게시글 삭제 (DELETE /posts/{id})
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable String id) throws AccessDeniedException {
        UUID postId = UUID.fromString(id);
        UUID userId = getAuthenticatedUserId();

        communityService.deletePost(postId, userId);
        return ResponseEntity.noContent().build();
    }

    // 댓글 작성 (POST /posts/{postId}/comments)
    @PostMapping("/{postId}/comments")
    public ResponseEntity<CommentDto> addComment(@PathVariable String postId, @RequestBody CommentDto commentDto) throws AccessDeniedException {
        UUID outfitId = UUID.fromString(postId);
        UUID userId = getAuthenticatedUserId();

        CommentDto newComment = communityService.addComment(outfitId, userId, commentDto);
        return ResponseEntity.ok(newComment);
    }

    // 게시글, 댓글 반응 (POST /posts/{postId}/comments/{commentId}/react)
    @PostMapping("/{postId}/comments/{commentId}/react")
    public ResponseEntity<CommentDto> reactComment(
            @PathVariable String postId,
            @PathVariable String commentId,
            @RequestBody String type
    ) throws AccessDeniedException {
        UUID commentUUID = UUID.fromString(commentId);
        UUID userId = getAuthenticatedUserId();

        CommentDto updatedComment = communityService.reactComment(commentUUID, userId, type);
        return ResponseEntity.ok(updatedComment);
    }

    // 댓글 삭제 (DELETE /posts/{postId}/comments/{commentId})
    @DeleteMapping("/{postId}/comments/{commentId}")
    public ResponseEntity<Void> deleteComment(@PathVariable String postId, @PathVariable String commentId) throws AccessDeniedException {
        UUID commentUUID = UUID.fromString(commentId);
        UUID userId = getAuthenticatedUserId();

        communityService.deleteComment(commentUUID, userId);
        return ResponseEntity.noContent().build();
    }
}