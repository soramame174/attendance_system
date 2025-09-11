package com.example.attendance.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class Reservation {
    private String username;
    private LocalDate startDate; // 開始日
    private LocalDate endDate;   // 終了日
    private LocalTime startTime; // 開始時間
    private LocalTime endTime;   // 終了時間
    private String type;         // 例: 年休, 出張, 産休など
    private String details;      // 予約の詳細
    private String color;        // 予約の色 (例: #FF0000)
    private String url;          // URL 予約に関連するURL

    // コンストラクタ
    public Reservation(String username, LocalDate startDate, LocalDate endDate, LocalTime startTime, LocalTime endTime, String type, String details, String color, String url) {
        this.username = username;
        this.startDate = startDate;
        this.endDate = endDate;
        this.startTime = startTime;
        this.endTime = endTime;
        this.type = type;
        this.details = details;
        this.color = color;
        this.url = url;
    }

    // ゲッターメソッド
    public String getUsername() {
        return username;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public LocalTime getStartTime() {
        return startTime;
    }

    public LocalTime getEndTime() {
        return endTime;
    }

    public String getType() {
        return type;
    }

    public String getDetails() {
        return details;
    }

    public String getColor() {
        return color;
    }
    
    public String getUrl() {
        return url;
    }
}