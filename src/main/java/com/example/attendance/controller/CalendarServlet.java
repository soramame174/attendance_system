package com.example.attendance.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
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
            if (yearMonthStr != null) {
                yearMonth = YearMonth.parse(yearMonthStr);
            } else {
                yearMonth = YearMonth.now();
            }
        } catch (DateTimeParseException e) {
            yearMonth = YearMonth.now();
        }

        LocalDate firstDayOfMonth = yearMonth.atDay(1);
        LocalDate lastDayOfMonth = yearMonth.atEndOfMonth();
        LocalDate today = LocalDate.now();

        // データベースからすべての予約を取得
        List<Reservation> allReservations = reservationDAO.findAllReservations();
        
        // 日付ごとに予約をフィルタリングしてマップに格納
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

        // カレンダーの日付を作成
        List<LocalDate> dates = new ArrayList<>();
        int firstDayOfWeek = firstDayOfMonth.getDayOfWeek().getValue();
        if (firstDayOfWeek == 7) { // Sunday is 7, convert to 0 for padding
            firstDayOfWeek = 0;
        }
        for (int i = 0; i < firstDayOfWeek; i++) {
            dates.add(null);
        }
        for (int i = 1; i <= lastDayOfMonth.getDayOfMonth(); i++) {
            dates.add(yearMonth.atDay(i));
        }

        request.setAttribute("dates", dates);
        request.setAttribute("yearMonth", yearMonth);
        request.setAttribute("prevMonth", yearMonth.minusMonths(1));
        request.setAttribute("nextMonth", yearMonth.plusMonths(1));
        request.setAttribute("today", today);
        request.setAttribute("reservationsByDate", reservationsByDate);

        RequestDispatcher rd = request.getRequestDispatcher("/jsp/calendar.jsp");
        rd.forward(request, response);
    }
}