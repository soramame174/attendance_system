package com.example.attendance.controller;

import java.io.IOException;
import java.util.Collection;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.UserDAO;
import com.example.attendance.dto.ProvisionalUser;
import com.example.attendance.dto.User;

@WebServlet("/users")
public class UserServlet extends HttpServlet {
	private final UserDAO userDAO = new UserDAO();
	
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String action = req.getParameter("action");
		HttpSession session = req.getSession(false);
		User currentUser = (User) session.getAttribute("user");
		String companyCode = (String) session.getAttribute("companyCode");

		if (currentUser == null || !("admin".equals(currentUser.getRole()))) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp");
			return;
		}
		
		String message = (String) session.getAttribute("successMessage");
		if (message != null) {
			req.setAttribute("successMessage", message);
			session.removeAttribute("successMessage");
		}

		if ("list".equals(action) || action == null) {
			Collection<User> users = userDAO.getAllUsers(companyCode);
			req.setAttribute("users", users);
			RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
			rd.forward(req, resp);
		} else if ("edit".equals(action)) {
			String username = req.getParameter("username");
			User userToEdit = userDAO.findByUsernameAndCompanyCode(companyCode, username);
			req.setAttribute("userToEdit", userToEdit);
			RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
			rd.forward(req, resp);
		} else if ("generate_code".equals(action)) {
		    ProvisionalUser provisionalUser = userDAO.createProvisionalUser(companyCode);
		    
		    session.setAttribute("provisionalUser", provisionalUser);

		    req.setAttribute("successMessage", "新入社員登録コードを生成しました: " + provisionalUser.getUser().getRegistrationCode());
		    Collection<User> users = userDAO.getAllUsers(companyCode);
		    req.setAttribute("users", users);
		    RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
		    rd.forward(req, resp);
		} else {
			resp.sendRedirect("users?action=list");
		}
	}
	
	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		String action = req.getParameter("action");
		HttpSession session = req.getSession(true);
		
		if ("delete_provisional_code".equals(action)) {
	        String registrationCode = req.getParameter("registrationCode");
	        userDAO.deleteProvisionalUser(registrationCode);
	        session.removeAttribute("provisionalUser");
	        session.setAttribute("successMessage", "登録コードを削除しました。");
	        resp.sendRedirect("users?action=list");
	        return;
	    }
		
		if ("register".equals(action)) {
			String companyCode = req.getParameter("companyCode");
			String registrationCode = req.getParameter("registrationCode");
			String username = req.getParameter("username");
			String password = req.getParameter("password");
			
			// パラメータの検証
			if (companyCode == null || companyCode.trim().isEmpty() || username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
				req.setAttribute("errorMessage", "必須項目が入力されていません。");
				RequestDispatcher rd = req.getRequestDispatcher("/register.jsp");
				rd.forward(req, resp);
				return;
			}
			
			// 専用コードが入力されている場合（従業員登録）
			if (registrationCode != null && !registrationCode.trim().isEmpty()) {
				if (userDAO.finalizeProvisionalUser(registrationCode, username, password)) {
					session.setAttribute("successMessage", "登録が完了しました。ログインしてください。");
					resp.sendRedirect(req.getContextPath() + "/login.jsp");
				} else {
			            req.setAttribute("errorMessage", "この専用コードは無効です。またはユーザーIDがすでに存在します。");
			            RequestDispatcher rd = req.getRequestDispatcher("/register.jsp");
			            rd.forward(req, resp);
			    }
			} 
			// 会社コードのみの場合（初回管理者登録）
			else {
				if (userDAO.companyExists(companyCode)) {
					req.setAttribute("errorMessage", "会社コードが既に存在します。社員として登録する場合は専用コードを入力してください。");
					RequestDispatcher rd = req.getRequestDispatcher("/register.jsp");
					rd.forward(req, resp);
				} else {
					if (userDAO.createFirstAdmin(companyCode, username, password)) {
						session.setAttribute("successMessage", "管理者アカウントを作成しました。ログインしてください。");
						resp.sendRedirect(req.getContextPath() + "/login.jsp");
					} else {
						req.setAttribute("errorMessage", "登録に失敗しました。再度お試しください。");
						RequestDispatcher rd = req.getRequestDispatcher("/register.jsp");
						rd.forward(req, resp);
					}
				}
			}
			return;
		}

		User currentUser = (User) session.getAttribute("user");
		String currentCompanyCode = (String) session.getAttribute("companyCode");
		if (currentUser == null || !("admin".equals(currentUser.getRole()))) {
			resp.sendRedirect(req.getContextPath() + "/login.jsp");
			return;
		}
		
		if ("add".equals(action)) {
			String username = req.getParameter("username");
			String password = req.getParameter("password");
			String role = req.getParameter("role");
			
			if (userDAO.findByUsernameAndCompanyCode(currentCompanyCode, username) == null) {
				userDAO.addUser(new User(username, UserDAO.hashPassword(password), role, currentCompanyCode));
				session.setAttribute("successMessage", "ユーザーを追加しました。");
			} else {
				req.setAttribute("errorMessage", "ユーザーIDは既に存在します。");
			}
		} else if ("update".equals(action)) {
			String originalUsername = req.getParameter("originalUsername");
			String newUsername = req.getParameter("username");
			String newPassword = req.getParameter("newPassword");
			String role = req.getParameter("role");
			boolean enabled = "true".equals(req.getParameter("enabled"));

			User existingUser = userDAO.findByUsernameAndCompanyCode(currentCompanyCode, originalUsername);

			if (existingUser != null) {
				// ユーザーIDが変更されたかどうかをチェック
				boolean isUsernameChanged = !originalUsername.equals(newUsername);
				
				// ユーザーID変更の場合、新しいIDが既存か確認
				if (isUsernameChanged && userDAO.findByUsernameAndCompanyCode(currentCompanyCode, newUsername) != null) {
					session.setAttribute("errorMessage", "ユーザーID '" + newUsername + "' は既に存在します。");
				} else {
					// 変更後のパスワードを決定
					String passwordToUse = existingUser.getPassword();
					if (newPassword != null && !newPassword.trim().isEmpty()) {
						passwordToUse = UserDAO.hashPassword(newPassword);
					}

					// 変更後のユーザー情報を含む新しいUserオブジェクトを作成
					User updatedUser = new User(newUsername, passwordToUse, role, enabled, currentCompanyCode, existingUser.getRegistrationCode());
					
					// ユーザーIDが変更された場合は、古いユーザーを削除して新しいユーザーを追加
					if (isUsernameChanged) {
						userDAO.deleteUser(currentCompanyCode, originalUsername);
						userDAO.addUser(updatedUser);
					} else {
						// ユーザーIDが変更されていない場合は、既存のユーザーを更新
						userDAO.updateUser(updatedUser);
					}
					
					// 自分のアカウントを更新した場合、セッションも更新
					if (currentUser.getUsername().equals(originalUsername)) {
						session.setAttribute("user", updatedUser);
					}
					
					session.setAttribute("successMessage", "ユーザー情報を更新しました。");
				}
			} else {
				session.setAttribute("errorMessage", "ユーザーが見つかりませんでした。");
			}
		} else if ("delete".equals(action)) {
			String username = req.getParameter("username");
			userDAO.deleteUser(currentCompanyCode, username);
			session.setAttribute("successMessage", "ユーザーを削除しました。");
		} else if ("reset_password".equals(action)) {
			String username = req.getParameter("username");
			String newPassword = req.getParameter("newPassword");
			userDAO.resetPassword(currentCompanyCode, username, newPassword);
			session.setAttribute("successMessage", username + "のパスワードをリセットしました。(デフォルトパスワード: " + newPassword + ")");
		} else if ("toggle_enabled".equals(action)) {
			String username = req.getParameter("username");
			boolean enabled = Boolean.parseBoolean(req.getParameter("enabled"));
			userDAO.toggleUserEnabled(currentCompanyCode, username, enabled);
			session.setAttribute("successMessage", username + "のアカウントを" + (enabled ? "有効" : "無効") + "にしました。");
		}
		
		if (!"add".equals(action) && userDAO.findByUsernameAndCompanyCode(currentCompanyCode, currentUser.getUsername()) != null) {
			currentUser = userDAO.findByUsernameAndCompanyCode(currentCompanyCode, currentUser.getUsername());
			session.setAttribute("user", currentUser);
		}
		
		Collection<User> users = userDAO.getAllUsers(currentCompanyCode);
		req.setAttribute("users", users);
		
		RequestDispatcher rd = req.getRequestDispatcher("/jsp/user_management.jsp");
		rd.forward(req, resp);
	}
}