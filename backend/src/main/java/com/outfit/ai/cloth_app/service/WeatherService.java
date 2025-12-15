package com.outfit.ai.cloth_app.service;

import com.outfit.ai.cloth_app.dto.WeatherDto;
import com.outfit.ai.cloth_app.api.weather_api.WeatherApiClient;
import org.springframework.stereotype.Service;

@Service
public class WeatherService {

    private final WeatherApiClient weatherApiClient;

    public WeatherService(WeatherApiClient weatherApiClient) {
        this.weatherApiClient = weatherApiClient;
    }

    /**
     * 날씨 조회 메서드 (Redis 캐시 임시 비활성화)
     */
    public WeatherDto getWeather(String location) {
        System.out.println("[WeatherService] 캐시 미스 → API 호출 시작: " + location);

        try {
            WeatherDto dto = weatherApiClient.getWeather(location);

            // 🔹 응답 검증 및 예외 상황 처리
            if (dto == null) {
                System.err.println("[WeatherService] API 응답이 null입니다. 기본값 반환.");
                return new WeatherDto(location, "응답 없음", 0.0, 0.0, 0.0);
            }

            if (dto.getDescription() != null && dto.getDescription().contains("실패")) {
                System.err.println("[WeatherService] API 응답 실패 메시지 감지: " + dto.getDescription());
            }

            System.out.println("[WeatherService] API 호출 완료 → 결과: " + dto);
            return dto;

        } catch (Exception e) {
            System.err.println("[WeatherService] 예외 발생: " + e.getMessage());
            e.printStackTrace();
            return new WeatherDto(location, "서비스 오류 발생: " + e.getMessage(), 0.0, 0.0, 0.0);
        }
    }
}
