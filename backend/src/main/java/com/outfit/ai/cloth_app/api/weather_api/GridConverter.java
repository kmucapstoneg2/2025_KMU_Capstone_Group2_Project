package com.outfit.ai.cloth_app.api.weather_api;

import java.util.HashMap;
import java.util.Map;

class GridPoint {
    private final String nx;
    private final String ny;

    public GridPoint(String nx, String ny) {
        this.nx = nx;
        this.ny = ny;
    }

    public String getNx() { return nx; }
    public String getNy() { return ny; }
}

public class GridConverter {

    private static final Map<String, GridPoint> LOCATION_MAP = new HashMap<>();

    static {
        LOCATION_MAP.put("Seoul", new GridPoint("60", "127"));
        LOCATION_MAP.put("서울", new GridPoint("60", "127"));
        LOCATION_MAP.put("Busan", new GridPoint("98", "76"));
        LOCATION_MAP.put("부산", new GridPoint("98", "76"));
        LOCATION_MAP.put("Daegu", new GridPoint("89", "90"));
        LOCATION_MAP.put("대구", new GridPoint("89", "90"));
        LOCATION_MAP.put("Incheon", new GridPoint("55", "124"));
        LOCATION_MAP.put("인천", new GridPoint("55", "124"));
        LOCATION_MAP.put("Gwangju", new GridPoint("58", "74"));
        LOCATION_MAP.put("광주", new GridPoint("58", "74"));
        LOCATION_MAP.put("Daejeon", new GridPoint("67", "100"));
        LOCATION_MAP.put("대전", new GridPoint("67", "100"));
        LOCATION_MAP.put("Ulsan", new GridPoint("102", "84"));
        LOCATION_MAP.put("울산", new GridPoint("102", "84"));
    }

    private static GridPoint convertLocationToGrid(String location) {
        if (location == null || location.isEmpty()) return LOCATION_MAP.get("Seoul");
        return LOCATION_MAP.getOrDefault(location, LOCATION_MAP.get("Seoul"));
    }

    public static String getNx(String location) { return convertLocationToGrid(location).getNx(); }
    public static String getNy(String location) { return convertLocationToGrid(location).getNy(); }
}

