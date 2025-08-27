package com.example.attendance.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();

        // ログインページ、新規登録ページ、CSS、JSなどの静的リソースはフィルターの対象外にする
        if (uri.endsWith("login.jsp") || uri.endsWith("register.jsp") || uri.endsWith("LoginServlet") || uri.endsWith("users") || uri.endsWith(".css") || uri.endsWith(".js")) { // usersサーブレットも登録アクションを許可するため追加
            chain.doFilter(request, response);
            return;
        }

        boolean loggedIn = (session != null && session.getAttribute("user") != null);

        if (loggedIn) {
            chain.doFilter(request, response);
        } else {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void destroy() {
    }
}