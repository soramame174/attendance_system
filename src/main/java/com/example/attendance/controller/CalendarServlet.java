package com.example.attendance.controller;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
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

        request.setAttribute("currentUser", currentUser);

        String yearMonthStr = request.getParameter("yearMonth");
        YearMonth yearMonth;
        if (yearMonthStr != null && !yearMonthStr.isEmpty()) {
            try {
                yearMonth = YearMonth.parse(yearMonthStr);
            } catch (DateTimeParseException e) {
                yearMonth = YearMonth.now();
            }
        } else {
            yearMonth = YearMonth.now();
        }

        final YearMonth finalYearMonth = yearMonth;

        LocalDate firstDayOfMonth = finalYearMonth.atDay(1);

        // 祝日の定義をヘルパーメソッドで正確に取得
        Set<LocalDate> holidays = getHolidays(finalYearMonth.getYear());
        
        // 表示対象の月（finalYearMonth）の祝日のみにフィルタリング
        Set<LocalDate> yearMonthHolidays = holidays.stream()
            .filter(d -> d.getYear() == finalYearMonth.getYear() && d.getMonth() == finalYearMonth.getMonth())
            .collect(Collectors.toSet());

        List<Reservation> allReservations = reservationDAO.findAllReservations();
        Map<LocalDate, List<Reservation>> reservationsByDate = allReservations.stream()
            .collect(Collectors.groupingBy(
                Reservation::getStartDate,
                TreeMap::new,
                Collectors.toList()
            ));

        reservationsByDate.values().forEach(list -> list.sort(Comparator.comparing(Reservation::getStartTime)));
        
        request.setAttribute("dates", createCalendarDates(firstDayOfMonth));
        request.setAttribute("yearMonth", finalYearMonth);
        request.setAttribute("prevMonth", finalYearMonth.minusMonths(1));
        request.setAttribute("nextMonth", finalYearMonth.plusMonths(1));
        request.setAttribute("today", LocalDate.now());
        request.setAttribute("holidays", yearMonthHolidays);
        request.setAttribute("reservationsByDate", reservationsByDate);

        RequestDispatcher rd = request.getRequestDispatcher("/jsp/calendar.jsp");
        rd.forward(request, response);
    }
    
    /**
     * 指定された年における日本の祝日を計算して返します。
     * ハッピーマンデー制度、振替休日、国民の休日を考慮します。
     * @param year 祝日を取得する年
     * @return その年の祝日を格納したSet
     */
    private Set<LocalDate> getHolidays(int year) {
        Set<LocalDate> holidays = new HashSet<>();

        // 固定された祝日
        holidays.add(LocalDate.of(year, 1, 1));   // 元日
        holidays.add(LocalDate.of(year, 2, 11));  // 建国記念の日
        holidays.add(LocalDate.of(year, 2, 23));  // 天皇誕生日
        holidays.add(LocalDate.of(year, 4, 29));  // 昭和の日
        holidays.add(LocalDate.of(year, 5, 3));   // 憲法記念日
        holidays.add(LocalDate.of(year, 5, 5));   // こどもの日
        holidays.add(LocalDate.of(year, 8, 11));  // 山の日
        holidays.add(LocalDate.of(year, 11, 3));  // 文化の日
        holidays.add(LocalDate.of(year, 11, 23)); // 勤労感謝の日

        // ハッピーマンデー制度の祝日
        holidays.add(LocalDate.of(year, 1, 1).with(TemporalAdjusters.dayOfWeekInMonth(2, DayOfWeek.MONDAY)));  // 成人の日 (1月の第2月曜日)
        holidays.add(LocalDate.of(year, 7, 1).with(TemporalAdjusters.dayOfWeekInMonth(3, DayOfWeek.MONDAY)));  // 海の日 (7月の第3月曜日)
        holidays.add(LocalDate.of(year, 9, 1).with(TemporalAdjusters.dayOfWeekInMonth(3, DayOfWeek.MONDAY)));  // 敬老の日 (9月の第3月曜日)
        holidays.add(LocalDate.of(year, 10, 1).with(TemporalAdjusters.dayOfWeekInMonth(2, DayOfWeek.MONDAY))); // スポーツの日 (10月の第2月曜日)

        // 春分の日と秋分の日 (簡易的な概算ロジック)
        holidays.add(getEquinoxDay(year, 3)); // 春分の日
        holidays.add(getEquinoxDay(year, 9)); // 秋分の日

        // 振替休日と国民の休日の追加
        Set<LocalDate> additionalHolidays = new HashSet<>();
        for (LocalDate date : holidays) {
            // 振替休日の判定: 祝日が日曜日に重なったら翌日を追加
            if (date.getDayOfWeek() == DayOfWeek.SUNDAY) {
                additionalHolidays.add(date.plusDays(1));
            }
        }
        
        // 5月4日が平日の場合は国民の休日
        LocalDate may4 = LocalDate.of(year, 5, 4);
        if (may4.getDayOfWeek() != DayOfWeek.SUNDAY && may4.getDayOfWeek() != DayOfWeek.SATURDAY) {
            // 5月3日(憲法記念日)と5月5日(こどもの日)に挟まれていれば国民の休日
            if (holidays.contains(LocalDate.of(year, 5, 3)) && holidays.contains(LocalDate.of(year, 5, 5))) {
                 additionalHolidays.add(may4);
            }
        }
        
        holidays.addAll(additionalHolidays);

        return holidays;
    }

    private LocalDate getEquinoxDay(int year, int month) {
        int day = 0;
        if (month == 3) { // 春分の日
            day = (int) Math.floor(20.8431 + 0.242194 * (year - 1900) - Math.floor((year - 1900) / 4.0));
        } else if (month == 9) { // 秋分の日
            day = (int) Math.floor(23.2488 + 0.242194 * (year - 1900) - Math.floor((year - 1900) / 4.0));
        }
        return LocalDate.of(year, month, day);
    }

    private List<LocalDate> createCalendarDates(LocalDate firstDayOfMonth) {
        List<LocalDate> dates = new ArrayList<>();
        int firstDayOfWeek = firstDayOfMonth.getDayOfWeek().getValue();
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