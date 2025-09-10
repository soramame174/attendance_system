package com.example.attendance.controller;

import java.io.IOException;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.List;
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
import com.example.attendance.dto.Attendance;
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
                // 既存のコードを以下に置き換える
                List<Attendance> allRecords = attendanceDAO.findAll();
                
                // 月ごとの合計労働時間を計算（分単位）
                Map<String, Long> monthlyWorkingHours = allRecords.stream()
                    .filter(att -> att.getCheckInTime() != null && att.getCheckOutTime() != null)
                    .collect(Collectors.groupingBy(
                        att -> YearMonth.from(att.getCheckInTime()).toString(),
                        Collectors.summingLong(att -> ChronoUnit.MINUTES.between(att.getCheckInTime(), att.getCheckOutTime()))
                    ));

                // 月ごとの出勤日数を計算
                Map<String, Long> monthlyCheckInCounts = allRecords.stream()
                    .filter(att -> att.getCheckInTime() != null)
                    .collect(Collectors.groupingBy(
                        att -> YearMonth.from(att.getCheckInTime()).toString(),
                        Collectors.counting()
                    ));

                // データをリクエスト属性に設定
                req.setAttribute("monthlyWorkingHours", monthlyWorkingHours);
                req.setAttribute("monthlyCheckInCounts", monthlyCheckInCounts);

                RequestDispatcher rd = req.getRequestDispatcher("/jsp/admin_menu.jsp");
                rd.forward(req, resp);
            } else {
                // 従業員用の処理は変更しない
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