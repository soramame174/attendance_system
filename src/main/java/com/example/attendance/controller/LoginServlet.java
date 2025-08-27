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
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        User user = userDAO.findByUsername(username);
        
        System.out.println("DEBUG: Username received: " + username); // 追加
        System.out.println("DEBUG: User object retrieved: " + user); // 追加

        // ログイン成功チェックと処理を一つのifブロックにまとめる
        if (user != null && user.isEnabled() && userDAO.verifyPassword(username, password)) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("successMessage", "ログインしました。");

            // 管理者か従業員かの判定とリダイレクト
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
            // ログイン失敗時の処理
            req.setAttribute("errorMessage", "ユーザーIDまたはパスワードが正しくありません。");
            RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
            rd.forward(req, resp);
        }
    }
}