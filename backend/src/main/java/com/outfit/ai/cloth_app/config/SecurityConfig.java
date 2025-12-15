package com.outfit.ai.cloth_app.config;

import com.outfit.ai.cloth_app.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.FormLoginConfigurer;
import org.springframework.security.config.annotation.web.configurers.HttpBasicConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.InMemoryOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security 보안 설정
 * 
 * 주요 설정:
 * - JWT 인증 필터 등록
 * - OAuth2 로그인 (구글) 설정
 * - CSRF 비활성화 (REST API 용)
 * - 공개/비공개 API 경로 관리
 * 
 * 공개 API 경로:
 * - /api/v1/auth/** : 회원가입/로그인
 * - /weather : 날씨 조회
 * - /oauth2/**, /login/** : OAuth2 로그인
 * 
 * @see JwtAuthenticationFilter
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Autowired(required = false)
    private ClientRegistrationRepository clientRegistrationRepository;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    
    @Bean
    public OAuth2AuthorizedClientService authorizedClientService() {
        if (clientRegistrationRepository == null) {
            throw new IllegalStateException("ClientRegistrationRepository is not available. Check OAuth2 configuration in application.properties");
        }
        return new InMemoryOAuth2AuthorizedClientService(clientRegistrationRepository);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin(FormLoginConfigurer::disable)
                .httpBasic(HttpBasicConfigurer::disable)
                .sessionManagement(session -> session
                        // OAuth2는 세션이 필요하므로 IF_REQUIRED로 변경
                        .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                )
                .authorizeHttpRequests(auth -> auth
                        // API와 OAuth 경로 모두 허용
                        .requestMatchers("/api/v1/auth/**").permitAll()
                        .requestMatchers("/api/v1/codes/**").permitAll()  // 코드 테이블 API 공개
                        .requestMatchers("/", "/auth/**", "/oauth2/**", "/login/**").permitAll()
                        .requestMatchers("/error").permitAll()
                        .requestMatchers("/weather").permitAll()  // 날씨 API 허용
                        .anyRequest().authenticated()
                )
                // OAuth2 Login 설정 - 반드시 필터 추가 전에
                .oauth2Login(oauth2 -> oauth2
                        .loginPage("/oauth2/authorization/google")
                        .defaultSuccessUrl("/auth/google/success", true)
                        .failureUrl("/auth/google/failure")
                );
        
        // JWT 필터는 UsernamePasswordAuthenticationFilter 위치에 추가
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
