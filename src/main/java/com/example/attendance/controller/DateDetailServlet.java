package com.example.attendance.controller;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.example.attendance.dao.ReservationDAO;
import com.example.attendance.dto.Reservation;

@WebServlet("/date_detail")
public class DateDetailServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ReservationDAO reservationDAO = new ReservationDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dateParam = request.getParameter("date");
        if (dateParam == null || dateParam.isEmpty()) {
            response.sendRedirect("calendar");
            return;
        }

        try {
            LocalDate selectedDate = LocalDate.parse(dateParam);
            List<Reservation> reservations = reservationDAO.findReservationsByDate(selectedDate);
            
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("reservations", reservations);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/date_detail.jsp");
            dispatcher.forward(request, response);
        } catch (DateTimeParseException e) {
            response.sendRedirect("calendar");
        }
    }
}