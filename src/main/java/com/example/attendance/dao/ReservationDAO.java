package com.example.attendance.dao;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import com.example.attendance.dto.Reservation;

public class ReservationDAO {
    // ユーザー名と予約リストを関連付けるマップ
    private static final Map<String, List<Reservation>> userReservations = new ConcurrentHashMap<>();

    // 予約を保存するメソッド
    public void addReservation(String username, Reservation reservation) {
        userReservations.computeIfAbsent(username, k -> new ArrayList<>()).add(reservation);
    }

    // 特定のユーザーの予約をすべて取得するメソッド
    public List<Reservation> findReservationsByUsername(String username) {
        return userReservations.getOrDefault(username, Collections.emptyList());
    }

    // 特定の日付の予約を取得するメソッド (日付をまたぐ予定も含む)
    public List<Reservation> findReservationsByDate(LocalDate date) {
        List<Reservation> reservations = new ArrayList<>();
        for (List<Reservation> userResList : userReservations.values()) {
            reservations.addAll(userResList.stream()
                    .filter(res -> !date.isBefore(res.getStartDate()) && !date.isAfter(res.getEndDate()))
                    .collect(Collectors.toList()));
        }
        return reservations;
    }
    
    // 全ての予約を取得するメソッド (管理者用)
    public List<Reservation> findAllReservations() {
        List<Reservation> allReservations = new ArrayList<>();
        userReservations.values().forEach(allReservations::addAll);
        return allReservations;
    }
    
    // 予約を削除するメソッド
    public void deleteReservation(String username, LocalDate date, LocalTime startTime, String type) {
        List<Reservation> reservations = userReservations.get(username);
        if (reservations != null) {
            reservations.removeIf(res -> 
                res.getStartDate().isEqual(date) && 
                res.getStartTime().equals(startTime) &&
                res.getType().equals(type)
            );
        }
    }
}