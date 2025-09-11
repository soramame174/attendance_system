package com.example.attendance.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.ReservationDAO;
import com.example.attendance.dto.Reservation;
import com.example.attendance.dto.User;

@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ReservationDAO reservationDAO = new ReservationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String yearMonthStr = request.getParameter("yearMonth");
        YearMonth yearMonth;
        try {
            if (yearMonthStr != null && !yearMonthStr.isEmpty()) {
                yearMonth = YearMonth.parse(yearMonthStr);
            } else {
                yearMonth = YearMonth.now();
            }
        } catch (DateTimeParseException e) {
            yearMonth = YearMonth.now();
        }

        LocalDate firstDayOfMonth = yearMonth.atDay(1);
        LocalDate lastDayOfMonth = yearMonth.atEndOfMonth();

        // データベースからすべての予約を取得
        List<Reservation> allReservations = reservationDAO.findAllReservations();
        Map<LocalDate, List<Reservation>> reservationsByDate = new TreeMap<>();

        LocalDate date = firstDayOfMonth;
        while (!date.isAfter(lastDayOfMonth)) {
            final LocalDate currentDate = date;
            List<Reservation> dailyReservations = allReservations.stream()
                .filter(res -> !currentDate.isBefore(res.getStartDate()) && !currentDate.isAfter(res.getEndDate()))
                .sorted(Comparator.comparing(Reservation::getStartTime))
                .collect(Collectors.toList());
            reservationsByDate.put(currentDate, dailyReservations);
            date = date.plusDays(1);
        }

        // 日本の祝日を定義 (簡略化)
        Set<LocalDate> holidays = new HashSet<>(Arrays.asList(
            LocalDate.of(yearMonth.getYear(), 1, 1),   // 元日
            LocalDate.of(yearMonth.getYear(), 2, 11),  // 建国記念の日
            LocalDate.of(yearMonth.getYear(), 4, 29),  // 昭和の日
            LocalDate.of(yearMonth.getYear(), 5, 3),   // 憲法記念日
            LocalDate.of(yearMonth.getYear(), 5, 4),   // みどりの日
            LocalDate.of(yearMonth.getYear(), 5, 5),   // こどもの日
            LocalDate.of(yearMonth.getYear(), 7, 20),  // 海の日
            LocalDate.of(yearMonth.getYear(), 9, 15),  // 敬老の日
            LocalDate.of(yearMonth.getYear(), 10, 10), // 体育の日
            LocalDate.of(yearMonth.getYear(), 11, 3),  // 文化の日
            LocalDate.of(yearMonth.getYear(), 11, 23), // 勤労感謝の日
            LocalDate.of(yearMonth.getYear(), 12, 23)  // 天皇誕生日
        ));
        
        request.setAttribute("dates", createCalendarDates(firstDayOfMonth));
        request.setAttribute("yearMonth", yearMonth);
        request.setAttribute("prevMonth", yearMonth.minusMonths(1));
        request.setAttribute("nextMonth", yearMonth.plusMonths(1));
        request.setAttribute("today", LocalDate.now());
        request.setAttribute("holidays", holidays);
        request.setAttribute("reservationsByDate", reservationsByDate);

        RequestDispatcher rd = request.getRequestDispatcher("/jsp/calendar.jsp");
        rd.forward(request, response);
    }
    
    // カレンダーの日付リストを生成するヘルパーメソッド
    private List<LocalDate> createCalendarDates(LocalDate firstDayOfMonth) {
        List<LocalDate> dates = new ArrayList<>();
        int firstDayOfWeek = firstDayOfMonth.getDayOfWeek().getValue();
        // 日曜日を週の始まり (0) とする
        if (firstDayOfWeek == 7) { 
            firstDayOfWeek = 0;
        }
        for (int i = 0; i < firstDayOfWeek; i++) {
            dates.add(null);
        }
        LocalDate date = firstDayOfMonth;
        while (date.getMonth() == firstDayOfMonth.getMonth()) {
            dates.add(date);
            date = date.plusDays(1);
        }
        return dates;
    }
}