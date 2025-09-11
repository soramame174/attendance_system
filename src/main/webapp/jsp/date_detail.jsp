<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${selectedDate}" />の詳細</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <style>
        .detail-header {
            text-align: center;
            margin-bottom: 20px;
        }
        .reservation-list-container {
            margin-top: 20px;
        }
        .reservation-item {
            background-color: #f9f9f9;
            border: 1px solid #ddd;
            border-left: 5px solid;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .reservation-item .details {
            flex-grow: 1;
        }
        .reservation-item .username {
            font-weight: bold;
            color: #333;
        }
        .reservation-item .time-range {
            font-size: 0.9em;
            color: #777;
        }
        .reservation-item .type {
            display: inline-block;
            background-color: #e9e9e9;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8em;
            margin-left: 10px;
        }
        .reservation-item .delete-button {
            border: none;
            background: none;
            cursor: pointer;
            color: #dc3545;
            font-size: 1.5em;
            padding: 0;
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
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .form-group .color-picker-container {
            display: flex;
            align-items: center;
        }
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
    </style>
</head>
<body>
    <div class="container">
        <div class="detail-header">
            <h1><c:out value="${selectedDate}" />の予約一覧</h1>
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

        <div class="reservation-list-container">
            <h3>予約アイテム</h3>
            <c:choose>
                <c:when test="${not empty reservations}">
                    <c:forEach var="res" items="${reservations}">
                        <div class="reservation-item" style="border-left-color: ${res.color};">
                            <div class="details">
                                <div class="username"><c:out value="${res.username}"/></div>
                                <div class="time-range">
                                    <c:out value="${res.startTime}"/> ~ <c:out value="${res.endTime}"/>
                                </div>
                                <div><c:out value="${res.details}"/></div>
                                <c:if test="${not empty res.url}">
                                    <div><a href="${res.url}" target="_blank">関連URL</a></div>
                                </c:if>
                            </div>
                            <span class="type"><c:out value="${res.type}"/></span>
                            <form action="reserve" method="post" style="margin:0; padding:0;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="date" value="${res.startDate}">
                                <input type="hidden" name="startTime" value="${res.startTime}">
                                <input type="hidden" name="type" value="${res.type}">
                                <button type="submit" class="delete-button material-symbols-outlined">delete</button>
                            </form>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p>この日に予約はありません。</p>
                </c:otherwise>
            </c:choose>
        </div>

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
                <div class="form-group">
                    <label for="url">URL:</label>
                    <input type="url" id="url" name="url" placeholder="https://example.com">
                </div>
                
                <button type="submit" class="button primary">予約する</button>
            </form>
        </div>

        <div class="main-nav" style="margin-top: 20px;">
            <a href="calendar">カレンダーに戻る</a>
        </div>
    </div>

    <script>
        document.getElementById('color').addEventListener('input', function() {
            document.getElementById('colorPreview').style.backgroundColor = this.value;
        });
    </script>
</body>
</html>