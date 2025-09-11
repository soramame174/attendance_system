<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>従業員メニュー</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
<style>
    .attendance-controls {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }
    .attendance-controls button {
        padding: 15px 30px;
        font-size: 1.2em;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        color: #fff;
        transition: background-color 0.3s;
    }
    .check-in {
        background-color: #28a745;
    }
    .check-in:hover {
        background-color: #218838;
    }
    .check-out {
        background-color: #dc3545;
    }
    .check-out:hover {
        background-color: #c82333;
    }

    /* 新しいステータス選択部分のスタイル */
    .status-controls {
        margin-bottom: 20px;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
    }
    .status-controls select {
        padding: 8px;
        font-size: 1em;
        border-radius: 4px;
        border: 1px solid #ccc;
        margin-top: 5px;
        margin-bottom: 10px;
    }
    .status-controls button {
        padding: 10px 20px;
        font-size: 1em;
        border-radius: 4px;
        border: none;
        cursor: pointer;
        background-color: #007bff;
        color: white;
    }
    .status-controls button:hover {
        background-color: #0056b3;
    }
</style>
</head>
<body>
<div class="container">
    <h1>従業員メニュー</h1>
    <p>ようこそ, ${user.username}さん</p>
    <div class="main-nav">
        <a href="<%= request.getContextPath() %>/logout">ログアウト</a>
        <a href="<%= request.getContextPath() %>/task">ToDoリスト</a>
        <a href="<%= request.getContextPath() %>/calendar">カレンダー</a>
        <a href="<%= request.getContextPath() %>/profile_edit">プロフィール編集</a>
    </div>
    <c:if test="${not empty successMessage}">
        <p class="success-message"><c:out value="${successMessage}"/></p>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <h2>勤怠打刻</h2>
    <div class="attendance-controls">
        <form action="<%= request.getContextPath() %>/attendance" method="post">
            <input type="hidden" name="action" value="check_in">
            <button type="submit" class="button check-in">出勤</button>
        </form>
        <form action="<%= request.getContextPath() %>/attendance" method="post">
            <input type="hidden" name="action" value="check_out">
            <button type="submit" class="button check-out">退勤</button>
        </form>
    </div>

   	<h2>状況共有</h2>
    <div class="status-controls">
        <form action="<%= request.getContextPath() %>/status" method="post">
            <label for="status">現在の状況を選択:</label>
            <select name="status" id="status">
                <option value="" disabled selected>なし</option>
                <option value="WORKING">仕事中 💼</option>
                <option value="ON_BUSINESS_TRIP">出張中 ✈️</option>
                <option value="ON_LEAVE">休暇中 🏖️</option>
                <option value="ON_BREAK">休憩中 ☕</option>
                <option value="SICK">体調不良 🤒</option>
                <option value="HEADING_HOME">帰宅 🏡</option>
                <option value="WORK_FROM_HOME">在宅ワーク 🏠</option>
            </select>
            <button type="submit">状況を更新</button>
        </form>
    </div>

    <h2>あなたの勤怠履歴</h2>
    <div>
        <table>
            <thead>
                <tr>
                    <th>出勤時刻</th>
                    <th>退勤時刻</th>
                </tr>
            </thead>
            <tbody class="table-scroll-container">
                <c:choose>
                    <c:when test="${not empty attendanceRecords}">
                        <c:forEach var="att" items="${attendanceRecords}">
                            <tr>
                                <td><c:out value="${att.checkInTime}"/></td>
                                <td><c:out value="${att.checkOutTime}"/></td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr><td colspan="2">データがありません。</td></tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</div>
</body>
</html>