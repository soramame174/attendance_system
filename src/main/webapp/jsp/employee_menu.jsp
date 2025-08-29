<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
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
</style>
</head>
<body>
<div class="container">
    <h1>従業員メニュー</h1>
    <p>ようこそ, ${user.username}さん</p>
    <div class="main-nav">
        <a href="logout">ログアウト</a>
        <a href="task">ToDoリスト</a>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <p class="success-message"><c:out value="${sessionScope.successMessage}"/></p>
        <c:remove var="successMessage" scope="session"/>
    </c:if>

    <h2>勤怠打刻</h2>
    <div class="attendance-controls">
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="check_in">
            <button type="submit" class="button check-in">出勤</button>
        </form>
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="check_out">
            <button type="submit" class="button check-out">退勤</button>
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