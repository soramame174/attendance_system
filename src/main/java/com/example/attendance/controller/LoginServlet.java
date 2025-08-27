package com.example.attendance.controller;

import java.io.IOException;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.AttendanceDAO;
import com.example.attendance.dao.UserDAO;
import com.example.attendance.dto.User;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final AttendanceDAO attendanceDAO = new AttendanceDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String companyCode = req.getParameter("companyCode");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        System.out.println("DEBUG: CompanyCode received: " + companyCode);
        System.out.println("DEBUG: Username received: " + username);

        // findByUsernameAndCompanyCodeを呼び出す前に、companyCodeとusernameがnullでないことを確認
        if (companyCode == null || companyCode.trim().isEmpty() || username == null || username.trim().isEmpty()) {
            req.setAttribute("errorMessage", "会社コードとユーザーIDは必須項目です。");
            RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
            rd.forward(req, resp);
            return;
        }

        User user = userDAO.findByUsernameAndCompanyCode(companyCode, username);
        
        System.out.println("DEBUG: User object retrieved: " + user);

        if (user != null && user.isEnabled() && userDAO.verifyPassword(companyCode, username, password)) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("companyCode", user.getCompanyCode());
            session.setAttribute("successMessage", "ログインしました。");

            if ("admin".equals(user.getRole())) {
                req.setAttribute("allAttendanceRecords", attendanceDAO.findAll());
                Map<String, Long> totalHoursByUser = attendanceDAO.findAll().stream()
                    .collect(Collectors.groupingBy(com.example.attendance.dto.Attendance::getUserId, Collectors.summingLong(att -> {
                    if (att.getCheckInTime() != null && att.getCheckOutTime() != null) {
                        return java.time.temporal.ChronoUnit.HOURS.between(att.getCheckInTime(), att.getCheckOutTime());
                    }
                    return 0L;
                })));
                req.setAttribute("totalHoursByUser", totalHoursByUser);
                RequestDispatcher rd = req.getRequestDispatcher("/jsp/admin_menu.jsp");
                rd.forward(req, resp);
            } else {
                req.setAttribute("attendanceRecords", attendanceDAO.findByUserId(user.getUsername()));
                RequestDispatcher rd = req.getRequestDispatcher("/jsp/employee_menu.jsp");
                rd.forward(req, resp);
            }
        } else {
            req.setAttribute("errorMessage", "会社コード、ユーザーID、またはパスワードが正しくありません。");
            RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
            rd.forward(req, resp);
        }
    }
}