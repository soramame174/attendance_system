package com.example.attendance.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.example.attendance.dao.ToDoDAO;
import com.example.attendance.dto.ToDo;
import com.example.attendance.dto.User;

@WebServlet("/task")
public class ToDoServlet extends HttpServlet {
    private ToDoDAO todoDAO;

    public void init() {
        todoDAO = new ToDoDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("/login.jsp");
            return;
        }

        List<ToDo> todos = todoDAO.getTodos(user.getUsername());
        request.setAttribute("todos", todos);

        String selectedPriority = request.getParameter("selectedPriority");
        if (selectedPriority == null || selectedPriority.isEmpty()) {
             selectedPriority = "高";
        }
        String selectedCategory = request.getParameter("selectedCategory");
        if (selectedCategory == null || selectedCategory.isEmpty()) {
            selectedCategory = "仕事";
        }
        request.setAttribute("selectedPriority", selectedPriority);
        request.setAttribute("selectedCategory", selectedCategory);

        request.getRequestDispatcher("/jsp/todo_list.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String userId = user.getUsername();

        if ("add".equals(action)) {
            String task = request.getParameter("task");
            String priority = request.getParameter("priority");
            String category = request.getParameter("category");
            if (task != null && !task.trim().isEmpty()) {
                ToDo newTodo = new ToDo(userId, task, priority, category);
                todoDAO.addTodo(userId, newTodo);
            }
        } else if ("toggle".equals(action)) {
            String todoId = request.getParameter("todoId");
            ToDo todo = todoDAO.findTodoById(userId, todoId);
            if (todo != null) {
                todo.setCompleted(!todo.isCompleted());
                todoDAO.updateTodo(userId, todo);
            }
        } else if ("delete".equals(action)) {
            String todoId = request.getParameter("todoId");
            if (todoId != null) {
                 todoDAO.deleteTodo(userId, todoId);
            }
        } else if ("delete_completed".equals(action)) {
            todoDAO.deleteCompletedTodos(userId);
        }

        // リダイレクトURLにToDo作成フォームの選択状態を付加
        String redirectUrl = "task";
        String separator = "?";
        String selectedPriority = request.getParameter("priority");
        if ("add".equals(action) && selectedPriority != null && !selectedPriority.isEmpty()) {
             redirectUrl += separator + "selectedPriority=" + URLEncoder.encode(selectedPriority, StandardCharsets.UTF_8.toString());
             separator = "&";
        }
        String selectedCategory = request.getParameter("category");
        if ("add".equals(action) && selectedCategory != null && !selectedCategory.isEmpty()) {
            redirectUrl += separator + "selectedCategory=" + URLEncoder.encode(selectedCategory, StandardCharsets.UTF_8.toString());
        }
        response.sendRedirect(redirectUrl);
    }
}