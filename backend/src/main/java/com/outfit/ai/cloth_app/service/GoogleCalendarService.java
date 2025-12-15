package com.outfit.ai.cloth_app.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.DateTime;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.api.services.calendar.model.Events;
import com.outfit.ai.cloth_app.dto.response.DailyScheduleDto;
import com.outfit.ai.cloth_app.dto.response.EventDetailDto;
import com.outfit.ai.cloth_app.repository.UserCalendarRepository;
import com.outfit.ai.cloth_app.repository.UserRepository;
import com.outfit.ai.cloth_app.entity.UserCalendar;
import com.outfit.ai.cloth_app.entity.UserTable;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

// 구글 캘린더 서비스
@Service
public class GoogleCalendarService {
    private static final String APPLICATION_NAME = "ClothApp AI Outfit Recommender";
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final String REGISTRATION_ID = "google";

    private final UserCalendarRepository userCalendarRepository;
    private final UserRepository userRepository;
    private final OAuth2AuthorizedClientService clientService;

    public GoogleCalendarService(
            UserCalendarRepository userCalendarRepository,
            UserRepository userRepository,
            OAuth2AuthorizedClientService clientService) {
        this.userCalendarRepository = userCalendarRepository;
        this.userRepository = userRepository;
        this.clientService = clientService;
    }

    private Calendar buildCalendarService(Credential credential) throws GeneralSecurityException, IOException {
        final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
        return new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, credential)
                .setApplicationName(APPLICATION_NAME)
                .build();
    }

    // 현재 유저의 구글 캘린더 불러오기
    private Calendar getCalendarClientForCurrentUser() throws GeneralSecurityException, IOException {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();

        String principalId = principal.toString();

        OAuth2AuthorizedClient client = clientService.loadAuthorizedClient(
                REGISTRATION_ID,
                principalId
        );

        if (client == null || client.getAccessToken() == null) {
            throw new RuntimeException("OAuth2 Client를 찾을 수 없거나 Access Token이 없습니다.");
        }

        String accessToken = client.getAccessToken().getTokenValue();
        Credential credential = new GoogleCredential().setAccessToken(accessToken);

        return buildCalendarService(credential);
    }

    // 이메일로 스케쥴 불러오고 저장
    @Transactional
    public List<UserCalendar> fetchAndSaveSchedulesByEmail(String email)
        throws IOException, GeneralSecurityException {
        Optional<UserTable> userOptional = userRepository.findByEmail(email);

        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("앱에 로그인한 이메일 (" + email + ")을 찾을 수 없습니다. 먼저 회원가입해주세요.");
        }
        UserTable currentUser = userOptional.get();

        Calendar service = getCalendarClientForCurrentUser();
        String calenderId = "primary";

        DateTime now = new DateTime(System.currentTimeMillis());
        DateTime monthLater = new DateTime(System.currentTimeMillis() + 30L * 24 * 60 * 60 * 1000);

        Events events = service.events().list(calenderId)
                .setMaxResults(50)
                .setTimeMin(now)
                .setTimeMax(monthLater)
                .setOrderBy("startTime")
                .setSingleEvents(true)
                .execute();

        List<Event> items = events.getItems();
        if (items == null || items.isEmpty()) {
            return List.of();
        }

        List<UserCalendar> newSchedules = items.stream()
                .filter(event -> event.getStart() != null && event.getEnd() != null)
                .map(event -> {
                    if (userCalendarRepository.existsByGoogleEventId(event.getId())) {
                        return null;
                    }

                    UserCalendar userCalendar = new UserCalendar();

                    userCalendar.setGoogleEventId(event.getId());
                    userCalendar.setUserTable(currentUser);
                    userCalendar.setEventSummary(event.getSummary());
                    userCalendar.setLocation(event.getLocation());

                    userCalendar.setStartTime(toOffsetDateTime(event.getStart()));
                    userCalendar.setEndTime(toOffsetDateTime(event.getEnd()));

                    userCalendar.setJsonData(event.toString());

                    boolean isAllDay = event.getStart().getDate() != null && event.getStart().getDateTime() == null;
                    userCalendar.setIsAllDay(isAllDay);

                    userCalendar.setDressCodeTag(null);

                    return userCalendar;
                })
                .filter(Objects::nonNull)
                .toList();

        if (!newSchedules.isEmpty()) {
            userCalendarRepository.saveAll(newSchedules);
        }

        return newSchedules;
    }

    // UUID로 스케쥴 불러오고 저장 (기존 메서드 유지)
    @Transactional
    public List<UserCalendar> fetchAndSaveSchedules(String userIdentifier)
        throws IOException, GeneralSecurityException {
        UUID userId = UUID.fromString(userIdentifier);
        Optional<UserTable> userOptional = userRepository.findById(userId);

        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found identifier: " + userIdentifier);
        }
        UserTable currentUser = userOptional.get();

        Calendar service = getCalendarClientForCurrentUser();
        String calenderId = "primary";

        DateTime now = new DateTime(System.currentTimeMillis());
        DateTime monthLater = new DateTime(System.currentTimeMillis() + 30L * 24 * 60 * 60 * 1000);

        Events events = service.events().list(calenderId)
                .setMaxResults(50)
                .setTimeMin(now)
                .setTimeMax(monthLater)
                .setOrderBy("startTime")
                .setSingleEvents(true)
                .execute();

        List<Event> items = events.getItems();
        if (items == null || items.isEmpty()) {
            return List.of();
        }

        List<UserCalendar> newSchedules = items.stream()
                .filter(event -> event.getStart() != null && event.getEnd() != null)
                .map(event -> {
                    if (userCalendarRepository.existsByGoogleEventId(event.getId())) {
                        return null;
                    }

                    UserCalendar userCalendar = new UserCalendar();

                    userCalendar.setGoogleEventId(event.getId());
                    userCalendar.setUserTable(currentUser);
                    userCalendar.setEventSummary(event.getSummary());
                    userCalendar.setLocation(event.getLocation());

                    userCalendar.setStartTime(toOffsetDateTime(event.getStart()));
                    userCalendar.setEndTime(toOffsetDateTime(event.getEnd()));

                    userCalendar.setJsonData(event.toString());

                    boolean isAllDay = event.getStart().getDate() != null && event.getStart().getDateTime() == null;
                    userCalendar.setIsAllDay(isAllDay);

                    userCalendar.setDressCodeTag(null);

                    return userCalendar;
                })
                .filter(Objects::nonNull)
                .toList();

        return userCalendarRepository.saveAll(newSchedules);
    }

    // 이번주 일정 DB에서 불러오기
    public List<DailyScheduleDto> getEventFromDbForThisWeek(String userIdentifier) {
        UUID userId = UUID.fromString(userIdentifier);
        Optional<UserTable> userOptional = userRepository.findById(userId);

        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found identifier: " + userIdentifier);
        }
        UserTable currentUser = userOptional.get();

        ZoneId systemZone = ZoneId.systemDefault();
        LocalDate today = LocalDate.now();
        OffsetDateTime startOfWeek = today.with(DayOfWeek.MONDAY).atStartOfDay(systemZone).toOffsetDateTime();
        OffsetDateTime endOfWeek = today.with(DayOfWeek.SUNDAY).plusDays(1).atStartOfDay(systemZone).toOffsetDateTime();

        List<UserCalendar> allSchedules = userCalendarRepository.findByUserTable(currentUser);

        List<UserCalendar> weeklySchedules = allSchedules.stream()
                .filter(s -> s.getStartTime() != null &&
                        s.getStartTime().isAfter(startOfWeek) &&
                        s.getStartTime().isBefore(endOfWeek))
                .sorted(Comparator.comparing(UserCalendar::getStartTime))
                .toList();

        return mapEntitiesToScheduleDto(weeklySchedules, today.with(DayOfWeek.MONDAY), today.with(DayOfWeek.SUNDAY));
    }

    // map 엔티티를 스케쥴로 바꾸는 DTO
    private List<DailyScheduleDto> mapEntitiesToScheduleDto(List<UserCalendar> schedules, LocalDate startOfWeek, LocalDate endOfWeek) {
        Map<LocalDate, List<EventDetailDto>> dateMap = new HashMap<>();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("M월 d일 (E)", Locale.KOREA);

        for (UserCalendar schedule : schedules) {
            LocalDateTime startDateTime = schedule.getStartTime().atZoneSameInstant(ZoneId.systemDefault()).toLocalDateTime();
            LocalDate eventDate = startDateTime.toLocalDate();
            String eventTime = startDateTime.toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm"));

            EventDetailDto dto = new EventDetailDto(
                    schedule.getEventSummary() != null ? schedule.getEventSummary() : "제목 없음",
                    eventTime,
                    schedule.getLocation(),
                    schedule.getDressCodeTag() != null ? List.of(schedule.getDressCodeTag()) : Collections.emptyList()
            );

            dateMap.computeIfAbsent(eventDate, k -> new ArrayList<>()).add(dto);
        }

        List<DailyScheduleDto> weeklySchedule = new ArrayList<>();
        LocalDate current = startOfWeek;

        while (!current.isAfter(endOfWeek)) {
            List<EventDetailDto> dayEvents = dateMap.getOrDefault(current, Collections.emptyList());
            String formattedDate = current.format(dateFormatter);

            weeklySchedule.add(new DailyScheduleDto(current, formattedDate, dayEvents));
            current = current.plusDays(1);
        }

        return weeklySchedule;
    }

    // OffsetDateTime으로 바꾸는 함수
    private OffsetDateTime toOffsetDateTime(EventDateTime eventDateTime) {
        DateTime dateTime = eventDateTime.getDateTime();
        DateTime dateOnly = eventDateTime.getDate();

        if (dateTime != null) {
            return OffsetDateTime.parse(dateTime.toStringRfc3339());
        } else if (dateOnly != null) {
            return Instant.ofEpochMilli(dateOnly.getValue())
                    .atZone(ZoneId.systemDefault())
                    .toOffsetDateTime();
        }

        throw new IllegalArgumentException("EventDateTime must contain either dateTime or date.");
    }

    // 일정 생성
    public Event createCalendarEvent(Credential credential, String summary, String description, String startTime, String endTime)
        throws IOException, GeneralSecurityException {
        Calendar service = buildCalendarService(credential);

        Event event = new Event()
                .setSummary(summary)
                .setDescription(description);

        EventDateTime start = new EventDateTime()
                .setDateTime(new com.google.api.client.util.DateTime(startTime))
                .setTimeZone("Asia/Seoul");
        event.setStart(start);

        EventDateTime end = new EventDateTime()
                .setDateTime(new com.google.api.client.util.DateTime(endTime))
                .setTimeZone("Asia/Seoul");
        event.setEnd(end);

        String calendarId = "primary";

        event = service.events().insert(calendarId, event).execute();

        return event;
    }
}
