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
            border-left: 5px solid; /* 予約色を表示する場所 */
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
            border-radius: 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input[type="date"],
        .form-group input[type="time"],
        .form-group input[type="text"],
        .form-group select {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
        }
        .form-group .color-picker-container {
            display: flex;
            align-items: center;
        }
        /* ボタン風のラベルスタイル */
        .form-group .color-label {
            padding: 8px 12px;
            border: 1px solid #ccc;
            background-color: #f0f0f0;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .form-group .color-picker-container input[type="color"] {
            width: 50px;
            height: 30px;
            padding: 0;
            border: none;
            cursor: pointer;
        }
        .color-preview {
            width: 30px;
            height: 30px;
            border: 1px solid #ccc;
            margin-left: 10px;
            border-radius: 4px;
        }
        .button.primary {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .button.primary:hover {
            background-color: #0056b3;
        }
        .delete-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background: none;
            border: none;
            color: #dc3545;
            cursor: pointer;
            font-size: 1.2em;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            justify-content: center;
            align-items: center;
            transition: background-color 0.3s, color 0.3s;
        }
        .delete-btn:hover {
            background-color: #dc3545;
            color: #fff; /* ホバー時の文字色を白に変更 */
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="detail-header">
            <h1><c:out value="${selectedDate}" /></h1>
            <h2>予約詳細</h2>
        </div>
        
        <c:if test="${not empty successMessage}">
            <div class="success-message">
                <p><c:out value="${successMessage}"/></p>
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="error-message">
                <p><c:out value="${errorMessage}"/></p>
            </div>
        </c:if>

        <c:if test="${not empty reservations}">
            <ul class="reservation-list">
                <c:forEach var="res" items="${reservations}">
                    <li class="reservation-item" style="border-left-color: <c:out value="${res.color}"/>;">
                        <span class="date-range">
                            <c:out value="${res.startDate}" /> <c:out value="${res.startTime}" /> - 
                            <c:out value="${res.endDate}" /> <c:out value="${res.endTime}" />
                        </span>
                        <div class="details">
                            <strong><c:out value="${res.username}"/> (<c:out value="${res.type}"/>)</strong>: <c:out value="${res.details}"/>
                        </div>
                        <form action="reserve" method="post" style="display:inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="date" value="<c:out value="${res.startDate}"/>">
                            <input type="hidden" name="startTime" value="<c:out value="${res.startTime}"/>">
                            <input type="hidden" name="type" value="<c:out value="${res.type}"/>">
                            <button type="submit" class="delete-btn" title="削除">✖</button>
                        </form>
                    </li>
                </c:forEach>
            </ul>
        </c:if>

        <div class="reservation-form-container">
            <h3>新規予約</h3>
            <form action="reserve" method="post">
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
                    <label for="color">色:</label>
                    <div class="color-picker-container">
                        <label for="color" class="color-label">色を変える</label>
                        <input type="color" id="color" name="color" value="#007bff">
                    </div>
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

    <script>
        const colorInput = document.getElementById('color');
        const colorPreview = document.getElementById('colorPreview');

        colorInput.addEventListener('input', (event) => {
            colorPreview.style.backgroundColor = event.target.value;
        });
    </script>
</body>
</html>