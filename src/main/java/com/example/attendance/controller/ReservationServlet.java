package com.example.attendance.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.ReservationDAO;
import com.example.attendance.dto.Reservation;
import com.example.attendance.dto.User;

@WebServlet("/reserve")
public class ReservationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ReservationDAO reservationDAO = new ReservationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("add".equals(action)) {
            try {
                String startDateStr = request.getParameter("startDate");
                String endDateStr = request.getParameter("endDate");
                String startTimeStr = request.getParameter("startTime");
                String endTimeStr = request.getParameter("endTime");
                String type = request.getParameter("type");
                String details = request.getParameter("details");
                String color = request.getParameter("color");

                LocalDate startDate = LocalDate.parse(startDateStr);
                LocalDate endDate = LocalDate.parse(endDateStr);
                LocalTime startTime = LocalTime.parse(startTimeStr);
                LocalTime endTime = LocalTime.parse(endTimeStr);

                if (endDate.isBefore(startDate)) {
                    session.setAttribute("errorMessage", "終了日は開始日より前の日付に設定できません。");
                } else if (startDate.isEqual(endDate) && endTime.isBefore(startTime)) {
                    session.setAttribute("errorMessage", "開始時間より前の時間に終了時間を設定することはできません。");
                } else {
                    // 新しいコンストラクタでcolorを渡す
                    Reservation reservation = new Reservation(currentUser.getUsername(), startDate, endDate, startTime, endTime, type, details, color);
                    reservationDAO.addReservation(currentUser.getUsername(), reservation);
                    
                    session.setAttribute("successMessage", "予約が完了しました！");
                }
            } catch (DateTimeParseException e) {
                session.setAttribute("errorMessage", "日付または時間の形式が正しくありません。");
            }
        } else if ("delete".equals(action)) {
            try {
                String dateStr = request.getParameter("date");
                String startTimeStr = request.getParameter("startTime");
                String type = request.getParameter("type");
                
                LocalDate date = LocalDate.parse(dateStr);
                LocalTime startTime = LocalTime.parse(startTimeStr);
                
                reservationDAO.deleteReservation(currentUser.getUsername(), date, startTime, type);
                
                session.setAttribute("successMessage", "予約を削除しました。");
            } catch (DateTimeParseException e) {
                session.setAttribute("errorMessage", "予約の削除に失敗しました。");
            }
        }

        response.sendRedirect(request.getContextPath() + "/date_detail?date=" + request.getParameter("startDate"));
    }
}