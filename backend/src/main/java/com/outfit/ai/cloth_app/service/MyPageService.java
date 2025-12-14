package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.response.MyPageProfileResponseDto;
import com.outfit.ai.cloth_app.exception.ResourceNotFoundException;
import com.outfit.ai.cloth_app.repository.UserRepository;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.stereotype.Service;

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
}
