package com.example.attendance.dto;

import java.time.Duration;
import java.time.LocalDateTime;

public class ProvisionalUser {
    private final User user;
    private final LocalDateTime expireAt;

    public ProvisionalUser(User user, LocalDateTime expireAt) {
        this.user = user;
        this.expireAt = expireAt;
    }

    public User getUser() {
        return user;
    }

    public LocalDateTime getExpireAt() {
        return expireAt;
    }

    public long getRemainingSeconds() {
        Duration duration = Duration.between(LocalDateTime.now(), expireAt);
        return Math.max(duration.toSeconds(), 0);
    }
}