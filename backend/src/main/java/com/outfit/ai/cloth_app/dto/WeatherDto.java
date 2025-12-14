package com.outfit.ai.cloth_app.dto;

import java.io.Serializable;

// 날씨 DTO
public class WeatherDto implements Serializable {

    private static final long serialVersionUID = 1L;

    private String location;
    private String description;
    private double temperature;
    private double tempMin;
    private double tempMax;

    // [추가] 현재 온도 존재 여부
    private boolean hasRealTemperature = false;

    public WeatherDto() {}

    public WeatherDto(String location, String description, double temperature, double tempMin, double tempMax) {
        this.location = location;
        this.description = description;
        this.temperature = temperature;
        this.tempMin = tempMin;
        this.tempMax = tempMax;
    }

    // [추가] 생성자 오버로드 - 현재 온도 존재 여부 포함
    public WeatherDto(String location, String description, double temperature, double tempMin, double tempMax, boolean hasRealTemperature) {
        this.location = location;
        this.description = description;
        this.temperature = temperature;
        this.tempMin = tempMin;
        this.tempMax = tempMax;
        this.hasRealTemperature = hasRealTemperature;
    }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getTemperature() { return temperature; }
    public void setTemperature(double temperature) { this.temperature = temperature; }

    public double getTempMin() { return tempMin; }
    public void setTempMin(double tempMin) { this.tempMin = tempMin; }

    public double getTempMax() { return tempMax; }
    public void setTempMax(double tempMax) { this.tempMax = tempMax; }

    // [추가] 실제 온도 존재 여부 getter/setter
    public boolean hasRealTemperature() { return hasRealTemperature; }
    public void setHasRealTemperature(boolean hasRealTemperature) { this.hasRealTemperature = hasRealTemperature; }
}
