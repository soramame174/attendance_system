<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${selectedDate}" />の詳細</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
    <style>
        .detail-header {
            text-align: center;
            margin-bottom: 20px;
        }
        .reservation-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .reservation-item {
            background-color: #f0f0f0;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 10px;
            margin-bottom: 10px;
            position: relative;
        }
        .reservation-item .date-range {
            font-size: 0.9em;
            color: #555;
            margin-bottom: 5px;
        }
        .reservation-item .details {
            font-size: 1em;
            color: #333;
        }
        .reservation-form-container {
            margin-top: 30px;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 8px;
            background-color: #fff;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
            color: #fff;
            transition: background-color 0.3s ease;
        }
        .button.primary {
            background-color: #007bff;
        }
        .button.primary:hover {
            background-color: #0056b3;
        }
        .button.delete {
            background-color: #dc3545;
            position: absolute;
            top: 10px;
            right: 10px;
        }
        .button.delete:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="detail-header">
            <h1><c:out value="${selectedDate}" /></h1>
        </div>

        <c:if test="${not empty successMessage}">
            <p class="success-message"><c:out value="${successMessage}"/></p>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <p class="error-message"><c:out value="${errorMessage}"/></p>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>

        <h2>本日の予約</h2>
        <ul class="reservation-list">
            <c:forEach var="res" items="${reservations}">
                <li class="reservation-item">
                    <div class="date-range">
                        <c:if test="${res.startDate.isEqual(res.endDate)}">
                            <c:out value="${res.startDate}" />
                        </c:if>
                        <c:if test="${!res.startDate.isEqual(res.endDate)}">
                            <c:out value="${res.startDate}" /> 〜 <c:out value="${res.endDate}" />
                        </c:if>
                    </div>
                    <strong><c:out value="${res.startTime}" /> - <c:out value="${res.endTime}" /></strong>
                    <br>
                    <span class="type-badge"><c:out value="${res.type}" /></span>
                    <p class="details"><c:out value="${res.details}" /></p>
                    <form action="<%= request.getContextPath() %>/reserve" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="date" value="<c:out value="${res.startDate}"/>">
                        <input type="hidden" name="startTime" value="<c:out value="${res.startTime}"/>">
                        <input type="hidden" name="type" value="<c:out value="${res.type}"/>">
                        <button type="submit" class="button delete">削除</button>
                    </form>
                </li>
            </c:forEach>
        </ul>

        <div class="reservation-form-container">
            <h2>予約追加</h2>
            <form action="<%= request.getContextPath() %>/reserve" method="post">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label for="startDate">開始日:</label>
                    <input type="date" id="startDate" name="startDate" value="<c:out value="${selectedDate}"/>" required>
                </div>
                <div class="form-group">
                    <label for="endDate">終了日:</label>
                    <input type="date" id="endDate" name="endDate" value="<c:out value="${selectedDate}"/>" required>
                </div>
                <div class="form-group">
                    <label for="startTime">開始時間:</label>
                    <input type="time" id="startTime" name="startTime" required>
                </div>
                <div class="form-group">
                    <label for="endTime">終了時間:</label>
                    <input type="time" id="endTime" name="endTime" required>
                </div>
                <div class="form-group">
                    <label for="type">種類:</label>
                    <select id="type" name="type">
                        <option value="年休">年休</option>
                        <option value="出張">出張</option>
                        <option value="その他">その他</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="details">詳細:</label>
                    <input type="text" id="details" name="details" placeholder="詳細を入力">
                </div>
                
                <button type="submit" class="button primary">予約する</button>
            </form>
        </div>

        <div class="main-nav" style="margin-top: 20px;">
            <a href="calendar">カレンダーに戻る</a>
        </div>
    </div>
</body>
</html>