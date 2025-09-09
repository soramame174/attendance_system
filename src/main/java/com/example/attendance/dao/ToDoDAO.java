package com.example.attendance.dao;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

import com.example.attendance.dto.ToDo;

public class ToDoDAO {
    private static final Map<String, List<ToDo>> userToDos = new ConcurrentHashMap<>();

    public void addTodo(String userId, ToDo todo) {
        todo.setId(UUID.randomUUID().toString());
        userToDos.computeIfAbsent(userId, k -> new CopyOnWriteArrayList<>()).add(todo);
    }

    public List<ToDo> getTodos(String userId) {
        return userToDos.getOrDefault(userId, new CopyOnWriteArrayList<>());
    }

    public void updateTodo(String userId, ToDo updatedTodo) {
        List<ToDo> todos = userToDos.get(userId);
        if (todos != null) {
            for (int i = 0; i < todos.size(); i++) {
                if (todos.get(i).getId().equals(updatedTodo.getId())) {
                    todos.set(i, updatedTodo);
                    return;
                }
            }
        }
    }

    public void deleteTodo(String userId, String todoId) {
        List<ToDo> todos = userToDos.get(userId);
        if (todos != null) {
            todos.removeIf(todo -> todo.getId().equals(todoId));
        }
    }

    public void deleteCompletedTodos(String userId) {
        List<ToDo> todos = userToDos.get(userId);
        if (todos != null) {
            todos.removeIf(ToDo::isCompleted);
        }
    }

    public ToDo findTodoById(String userId, String todoId) {
        List<ToDo> todos = userToDos.get(userId);
        if (todos != null) {
            return todos.stream()
                        .filter(todo -> todo.getId().equals(todoId))
                        .findFirst()
                        .orElse(null);
        }
        return null;
    }

    // 新しいフィルタリングメソッド
    public List<ToDo> findFilteredTodos(String userId, String priority, String category, String status) {
        List<ToDo> todos = getTodos(userId);
        return todos.stream()
                    .filter(todo -> "all".equals(priority) || todo.getPriority().equals(priority))
                    .filter(todo -> "all".equals(category) || todo.getCategory().equals(category))
                    .filter(todo -> "all".equals(status) || 
                                     ("completed".equals(status) && todo.isCompleted()) ||
                                     ("uncompleted".equals(status) && !todo.isCompleted()))
                    .collect(Collectors.toList());
    }
}