package com.example.attendance.controller;

import java.io.IOException;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.UserDAO;
import com.example.attendance.dto.User;

@WebServlet("/profile_edit")
public class ProfileEditServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        
        // プロフィール編集ページにフォワード
        RequestDispatcher rd = req.getRequestDispatcher("/jsp/employee_edit_profile.jsp");
        rd.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User currentUser = (User) session.getAttribute("user");
        String currentCompanyCode = (String) session.getAttribute("companyCode");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String originalUsername = req.getParameter("originalUsername");
        String newUsername = req.getParameter("newUsername");
        String newPassword = req.getParameter("newPassword");

        // ユーザーIDが空の場合はエラー
        if (newUsername == null || newUsername.trim().isEmpty()) {
            // メッセージをセッションに設定
            session.setAttribute("errorMessage", "ユーザーIDは必須項目です。");
            // リダイレクトでページを再読み込み
            resp.sendRedirect(req.getContextPath() + "/profile_edit");
            return;
        }

        boolean isUsernameChanged = !originalUsername.equals(newUsername);

        // 新しいユーザーIDが既に存在するかチェック
        if (isUsernameChanged && userDAO.findByUsernameAndCompanyCode(currentCompanyCode, newUsername) != null) {
            // メッセージをセッションに設定
            session.setAttribute("errorMessage", "新しいユーザーIDは既に存在します。");
            // リダイレクトでページを再読み込み
            resp.sendRedirect(req.getContextPath() + "/profile_edit");
            return;
        }

        String passwordToUse = currentUser.getPassword();
        if (newPassword != null && !newPassword.trim().isEmpty()) {
            passwordToUse = UserDAO.hashPassword(newPassword);
        }

        User updatedUser = new User(newUsername, passwordToUse, currentUser.getRole(), currentUser.isEnabled(), currentCompanyCode, currentUser.getRegistrationCode());

        if (isUsernameChanged) {
            userDAO.deleteUser(currentCompanyCode, originalUsername);
            userDAO.addUser(updatedUser);
        } else {
            userDAO.updateUser(updatedUser);
        }

        // セッションのユーザー情報を更新
        session.setAttribute("user", updatedUser);
        // 成功メッセージをセッションに設定
        session.setAttribute("successMessage", "プロフィールを更新しました。");

        // リダイレクトでページを再読み込み
        resp.sendRedirect(req.getContextPath() + "/profile_edit");
    }
}