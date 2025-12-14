package com.outfit.ai.cloth_app.api.weather_api;

import com.outfit.ai.cloth_app.dto.WeatherDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.util.UriComponentsBuilder;

import java.nio.charset.StandardCharsets;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

// 날씨 API 클라이언트
@Component
public class WeatherApiClient {

    private final RestTemplate restTemplate;

    @Value("${weather.api.key}")
    private String SERVICE_KEY;

    private final String FORECAST_API_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst";
    private final String CURRENT_API_URL  = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst";

    public WeatherApiClient() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(5000);
        factory.setReadTimeout(60000);
        this.restTemplate = new RestTemplate(factory);
        this.restTemplate.getMessageConverters()
                .add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));
    }

    /**
     * ✅ [수정된 부분]
     * 초단기실황용 baseDate / baseTime 계산 로직
     * - 기상청 초단기실황은 매시간 정각 기준으로 관측, 40분 이후 제공됨
     * - 40분 이전에는 이전 시각의 데이터를 조회해야 함
     */
    private Map<String, String> getCurrentBaseTimeAndDate() {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Seoul"));
        LocalDate baseDate = now.toLocalDate();
        int hour = now.getHour();
        int minute = now.getMinute();

        // 40분 이전이면 이전 시간 데이터로 요청
        if (minute < 40) {
            hour -= 1;
            if (hour < 0) {
                hour = 23;
                baseDate = baseDate.minusDays(1);
            }
        }

        String baseDateStr = baseDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String baseTimeStr = String.format("%02d00", hour); // ← 정각 기준 (30 아님!!)

        Map<String, String> result = new HashMap<>();
        result.put("baseDate", baseDateStr);
        result.put("baseTime", baseTimeStr);
        return result;
    }

    private String interpretKmaWeather(String skyCode, String ptyCode) {
        if (ptyCode != null && !"0".equals(ptyCode)) {
            return switch (ptyCode) {
                case "1" -> "비 🌧️";
                case "2" -> "비/눈 🌨️";
                case "3" -> "눈 ❄️";
                case "4" -> "소나기 ☔";
                case "5" -> "빗방울 💧";
                case "6" -> "빗방울눈날림 🌨️";
                case "7" -> "눈날림 🌨️";
                default -> "날씨 정보 오류 ❓";
            };
        }
        if (skyCode != null) {
            return switch (skyCode) {
                case "1" -> "맑음 ☀️";
                case "3" -> "구름많음 ☁️";
                case "4" -> "흐림 🌫️";
                default -> "날씨 정보 오류 ❓";
            };
        }
        return "정보 없음";
    }

    /** 단기예보 조회 */
    private WeatherDto getForecastWeather(String location) {
        String nx = GridConverter.getNx(location);
        String ny = GridConverter.getNy(location);

        LocalDateTime now = LocalDateTime.now();
        int hour = now.getHour();

        int[] forecastHours = {2,5,8,11,14,17,20,23};
        int baseHour = 23;
        for(int h : forecastHours) {
            if(hour >= h) baseHour = h;
        }

        LocalDate baseDate = now.toLocalDate();
        if(hour < 2) baseDate = baseDate.minusDays(1);

        String baseDateStr = baseDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String baseTimeStr = String.format("%02d00", baseHour);

        String url = UriComponentsBuilder
                .fromUriString(FORECAST_API_URL)
                .queryParam("serviceKey", SERVICE_KEY)
                .queryParam("numOfRows", "300")
                .queryParam("pageNo", "1")
                .queryParam("dataType", "JSON")
                .queryParam("base_date", baseDateStr)
                .queryParam("base_time", baseTimeStr)
                .queryParam("nx", nx)
                .queryParam("ny", ny)
                .toUriString();

        try {
            String response = restTemplate.getForObject(url, String.class);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode items = mapper.readTree(response)
                    .path("response").path("body").path("items").path("item");

            Map<String, String> timeWeatherMap = new HashMap<>();
            Map<String, String> dayWeatherMap = new HashMap<>();

            LocalTime nowTime = LocalTime.of(hour, now.getMinute());
            JsonNode nearest = null;
            long minDiff = Long.MAX_VALUE;

            for (JsonNode item : items) {
                if (!item.path("fcstDate").asText().equals(baseDateStr)) continue;
                LocalTime fcstTime = LocalTime.parse(item.path("fcstTime").asText(), DateTimeFormatter.ofPattern("HHmm"));
                long diff = Math.abs(Duration.between(nowTime, fcstTime).toMinutes());
                if (diff < minDiff) {
                    minDiff = diff;
                    nearest = item;
                }
            }

            String targetTime = nearest != null ? nearest.path("fcstTime").asText() : baseTimeStr;

            for (JsonNode item : items) {
                String category = item.path("category").asText();
                String fcstValue = item.path("fcstValue").asText();
                String fcstTime = item.path("fcstTime").asText();

                if("TMN".equals(category)) dayWeatherMap.put("TMN", fcstValue);
                else if("TMX".equals(category)) dayWeatherMap.put("TMX", fcstValue);
                else if(fcstTime.equals(targetTime)) timeWeatherMap.put(category, fcstValue);
            }

            double temp = Optional.ofNullable(timeWeatherMap.get("TMP")).map(Double::parseDouble)
                    .orElseGet(() -> {
                        double min = Optional.ofNullable(dayWeatherMap.get("TMN")).map(Double::parseDouble).orElse(0.0);
                        double max = Optional.ofNullable(dayWeatherMap.get("TMX")).map(Double::parseDouble).orElse(min);
                        return (min + max) / 2;
                    });

            double tempMin = Optional.ofNullable(dayWeatherMap.get("TMN")).map(Double::parseDouble).orElse(temp);
            double tempMax = Optional.ofNullable(dayWeatherMap.get("TMX")).map(Double::parseDouble).orElse(temp);

            String sky = timeWeatherMap.getOrDefault("SKY", "1");
            String pty = timeWeatherMap.getOrDefault("PTY", "0");
            String description = interpretKmaWeather(sky, pty);

            return new WeatherDto(location, description, temp, tempMin, tempMax);

        } catch(Exception e) {
            e.printStackTrace();
            return new WeatherDto(location, "단기예보 조회 실패", 0.0, 0.0, 0.0);
        }
    }

    /**
     * ✅ [수정된 부분]
     * 초단기실황(현재 기온) 조회
     * - base_time을 정각으로 맞춤 (이전에는 30분으로 되어 있어서 잘못된 데이터 가능성 높음)
     * - 실황은 'T1H' 값 사용 (현재기온)
     */
    private WeatherDto getCurrentWeather(String location) {
        String nx = GridConverter.getNx(location);
        String ny = GridConverter.getNy(location);

        Map<String, String> baseTimes = getCurrentBaseTimeAndDate();
        String baseDate = baseTimes.get("baseDate");
        String baseTime = baseTimes.get("baseTime");

        String url = UriComponentsBuilder
                .fromUriString(CURRENT_API_URL)
                .queryParam("serviceKey", SERVICE_KEY)
                .queryParam("numOfRows", "1000")
                .queryParam("pageNo", "1")
                .queryParam("dataType", "JSON")
                .queryParam("base_date", baseDate)
                .queryParam("base_time", baseTime)
                .queryParam("nx", nx)
                .queryParam("ny", ny)
                .toUriString();

        try {
            String response = restTemplate.getForObject(url, String.class);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode items = mapper.readTree(response)
                    .path("response").path("body").path("items").path("item");

            for (JsonNode item : items) {
                if ("T1H".equals(item.path("category").asText())) {
                    double temp = item.path("obsrValue").asDouble();
                    return new WeatherDto(location, "현재 기온", temp, 0.0, 0.0, true);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new WeatherDto(location, "실시간 온도 조회 실패", 0.0, 0.0, 0.0, false);
    }

    /** 최종 통합 호출 */
    public WeatherDto getWeather(String location) {
        WeatherDto forecastDto = getForecastWeather(location);
        WeatherDto currentDto = getCurrentWeather(location);

        // ✅ 현재 온도(T1H)가 존재하면 예보 대신 반영
        if (currentDto != null && currentDto.hasRealTemperature()) {
            forecastDto.setTemperature(currentDto.getTemperature());
        }

        return forecastDto;
    }
}
