package com.example.attendance.controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.UserDAO;
import com.example.attendance.dto.User;

@WebServlet("/status")
public class StatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    public void init() {
        userDAO = new UserDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("/login.jsp");
            return;
        }

        String newStatus = request.getParameter("status");
        if (newStatus != null && !newStatus.trim().isEmpty()) {
            currentUser.setStatus(newStatus);
            userDAO.updateUserStatus(currentUser.getCompanyCode(), currentUser.getUsername(), newStatus);
            session.setAttribute("successMessage", "状況が更新されました。");
        } else {
            session.setAttribute("errorMessage", "状況の更新に失敗しました。");
        }
        response.sendRedirect(request.getContextPath() + "/jsp/employee_menu.jsp");
    }
}