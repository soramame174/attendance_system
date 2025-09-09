<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>ToDoリスト</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f9;
        color: #333;
    }
    .container {
        width: 80%;
        margin: auto;
        padding: 20px;
        background-color: #fff;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        border-radius: 8px;
    }
    .main-nav a {
        color: white;
        text-decoration: none;
        padding: 10px 15px;
        border-radius: 4px;
        background-color: #007bff;
        transition: background-color 0.3s;
    }
    .main-nav a:hover {
        text-decoration: underline;
    }
    h1 {
        text-align: center;
        color: #333;
    }
    .task-form, .filters {
        margin-bottom: 20px;
        padding: 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
    }
    .task-form input[type="text"] {
        width: 70%;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 4px;
    }
    .task-form button {
        padding: 10px 15px;
        background-color: #007bff;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    .task-list {
        list-style: none;
        padding: 0;
    }
    .task-item {
        padding: 10px;
        border-bottom: 1px solid #eee;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .task-item.completed span {
        text-decoration: line-through;
        color: #888;
    }
    .task-item button {
        padding: 5px 10px;
        border: none;
        cursor: pointer;
        border-radius: 4px;
    }
    .toggle-btn {
        background-color: #28a745;
        color: white;
    }
    .delete-btn {
        background-color: #dc3545;
        color: white;
    }
    .priority-badge {
        width: 24px;
        height: 24px;
        border-radius: 4px;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.8em;
        font-weight: bold;
        margin-right: 10px;
    }
    .priority-high {
        background-color: #dc3545; /* 赤 */
    }
    .priority-medium {
        background-color: #ffc107; /* 黄 */
        color: white; /* 文字を白に変更 */
    }
    .priority-low {
        background-color: #28a745; /* 緑 */
    }
    .filter-group {
        display: flex;
        gap: 10px;
        margin-bottom: 10px;
        align-items: center;
    }
    .filter-group label {
        display: flex;
        align-items: center;
        gap: 5px;
    }
</style>
</head>
<body>
<div class="container">
    <h1>ToDoリスト</h1>
    <p>ようこそ, ${user.username}さん</p>
    <div class="main-nav">
        <a href="attendance">メニューに戻る</a>
        <a href="logout">ログアウト</a>
    </div>

    <div class="task-form">
        <form action="task" method="post">
            <input type="hidden" name="action" value="add">
            <input type="text" name="task" placeholder="新しいタスクを追加..." required>
            <div>
                <label>重要度:</label>
                <input type="radio" name="priority" value="高" <c:if test="${selectedPriority == '高' || selectedPriority == null}">checked</c:if>> 高
                <input type="radio" name="priority" value="中" <c:if test="${selectedPriority == '中'}">checked</c:if>> 中
                <input type="radio" name="priority" value="低" <c:if test="${selectedPriority == '低'}">checked</c:if>> 低
            </div>
            <div>
                <label>カテゴリー:</label>
                <input type="radio" name="category" value="仕事" <c:if test="${selectedCategory == '仕事' || selectedCategory == null}">checked</c:if>> 仕事
                <input type="radio" name="category" value="プライベート" <c:if test="${selectedCategory == 'プライベート'}">checked</c:if>> プライベート
                <input type="radio" name="category" value="買い物" <c:if test="${selectedCategory == '買い物'}">checked</c:if>> 買い物
                <input type="radio" name="category" value="その他" <c:if test="${selectedCategory == 'その他'}">checked</c:if>> その他
            </div>
            <button type="submit">追加</button>
        </form>
    </div>

    <h2>タスク一覧</h2>
    <ul class="task-list">
        <c:choose>
            <c:when test="${not empty todos}">
                <c:forEach var="todo" items="${todos}">
                    <li class="task-item">
                        <div style="display: flex; align-items: center;">
                            <div class="priority-badge
                                <c:choose>
                                    <c:when test="${todo.priority == '高'}">priority-high</c:when>
                                    <c:when test="${todo.priority == '中'}">priority-medium</c:when>
                                    <c:when test="${todo.priority == '低'}">priority-low</c:when>
                                </c:choose>">
                                <c:out value="${todo.priority}"/>
                            </div>
                            <form action="task" method="post" style="display: flex; align-items: center;">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="todoId" value="${todo.id}">
                                <input type="checkbox" name="completed" onchange="this.form.submit()" <c:if test="${todo.completed}">checked</c:if>>
                                <span style="margin-left: 10px; <c:if test="${todo.completed}">text-decoration: line-through; color: #888;</c:if>">
                                    <c:out value="${todo.task}"/> (<c:out value="${todo.category}"/>)
                                </span>
                            </form>
                        </div>
                        <form action="task" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="todoId" value="${todo.id}">
                            <button type="submit" class="delete-btn">削除</button>
                        </form>
                    </li>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <li>タスクはありません。</li>
            </c:otherwise>
        </c:choose>
    </ul>

    <form action="task" method="post" style="margin-top: 20px;">
        <input type="hidden" name="action" value="delete_completed">
        <button type="submit" class="delete-btn">完了したタスクをすべて削除</button>
    </form>
</div>
</body>
</html>