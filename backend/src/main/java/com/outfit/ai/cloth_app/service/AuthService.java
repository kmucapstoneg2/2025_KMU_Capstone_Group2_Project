package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.request.LoginRequestDto;
import com.outfit.ai.cloth_app.dto.request.SignUpRequestDto;
import com.outfit.ai.cloth_app.dto.response.TokenResponseDto;
import com.outfit.ai.cloth_app.repository.UserRepository;
import com.outfit.ai.cloth_app.security.JwtTokenProvider;
import com.outfit.ai.cloth_app.entity.UserTable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 인증 서비스 - JWT 토큰 기반 인증 처리
 * 
 * 주요 기능:
 * - signUp: 회원가입 (비밀번호 BCrypt 암호화)
 * - login: 로그인 (액세스/리프레시 토큰 발급)
 * - getUserIdFromAuthHeader: Authorization 헤더에서 사용자 ID 추출
 * 
 * 의존성:
 * - JwtTokenProvider: 토큰 생성/검증
 * - PasswordEncoder: 비밀번호 암호화 (BCrypt)
 * 
 * @see JwtTokenProvider
 * @see SecurityConfig
 */
@Service
public class AuthService {
    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            UserRepository userRepository,
            JwtTokenProvider jwtTokenProvider,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtTokenProvider = jwtTokenProvider;
        this.passwordEncoder = passwordEncoder;
    }

    // 회원가입
    // 유저 이름, 이메일, 비밀번호 입력 받음
    @Transactional
    public void signUp(SignUpRequestDto request) {
        if(userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("이미 사용 중인 이메일 입니다.");
        }

        String hashedPassword = passwordEncoder.encode(request.getPassword());

        UserTable newUser = new UserTable();
        newUser.setUsername(request.getUsername());
        newUser.setEmail(request.getEmail());
        newUser.setPasswordHash(hashedPassword);
        newUser.setRegion(request.getRegion() != null ? request.getRegion() : "서울");

        userRepository.save(newUser);
    }

    // 이메일로 로그인
    @Transactional(readOnly = true)
    public TokenResponseDto login(LoginRequestDto request) {
        UserTable user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("이메일 또는 비밀번호가 일치하시 않습니다."));

        if(!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("이메일 또는 비밀번호가 일치하지 않습니다.");
        }

        String accessToken = jwtTokenProvider.createAccessToken(user.getUserId());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getUserId());

        TokenResponseDto response = new TokenResponseDto();
        response.setAccessToken(accessToken);
        response.setRefreshToken(refreshToken);
        response.setUserId(user.getUserId());
        response.setUsername(user.getUsername());

        return response;
    }

    public UUID getUserIdFromAuthHeader(String authorizationHeader) {
        if(authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new IllegalArgumentException("토큰 형식이 올바르지 않습니다.");
        }

        String token = authorizationHeader.substring(7);

        if(!jwtTokenProvider.validateToken(token)) {
            throw new IllegalArgumentException("유효하지 않거나 만료된 토큰입니다.");
        }

        return jwtTokenProvider.getUserIdFromToken(token);
    }
}
