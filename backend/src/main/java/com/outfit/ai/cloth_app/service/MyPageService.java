package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.request.ProfileUpdateRequestDto;
import com.outfit.ai.cloth_app.dto.response.MyPageProfileResponseDto;
import com.outfit.ai.cloth_app.exception.ResourceNotFoundException;
import com.outfit.ai.cloth_app.repository.UserRepository;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

// 마이페이지 서비스
@Service
public class MyPageService {
    private final UserRepository userRepository;

    public MyPageService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    // 프로필 불러오기
    public MyPageProfileResponseDto getMyProfile(UUID userId) {
        UserTable user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("유저를 찾을 수 없습니다."));

        return new MyPageProfileResponseDto(
                user.getUsername(),
                user.getEmail(),
                user.getRegion(),
                user.getProfileImageUrl(),
                user.getCreatedAt()
        );
    }

    // 프로필 수정
    @Transactional
    public MyPageProfileResponseDto updateProfile(UUID userId, ProfileUpdateRequestDto request) {
        UserTable user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("유저를 찾을 수 없습니다."));

        if (request.getUsername() != null && !request.getUsername().isEmpty()) {
            user.setUsername(request.getUsername());
        }
        if (request.getRegion() != null) {
            user.setRegion(request.getRegion());
        }
        if (request.getProfileImageUrl() != null) {
            user.setProfileImageUrl(request.getProfileImageUrl());
        }

        userRepository.save(user);

        return new MyPageProfileResponseDto(
                user.getUsername(),
                user.getEmail(),
                user.getRegion(),
                user.getProfileImageUrl(),
                user.getCreatedAt()
        );
    }
}
