<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>新規登録</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>
<body>
    <div class="container">
        <h1>新規登録</h1>
        <form action="users?action=register" method="post">
            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <span class="material-symbols-outlined">error</span>
                    <p>${errorMessage}</p>
                </div>
            </c:if>
            <p class="instruction">初めてご利用の方は会社コードを入力して管理者アカウントを作成してください。</p>
            <p class="instruction">社員として登録される方は、会社コードと管理者から共有された専用コードを入力してください。</p>
            <p>
                <label for="companyCode">会社コード:</label>
                <input type="text" id="companyCode" name="companyCode" required>
            </p>
            <p>
                <label for="registrationCode">専用コード (社員用):</label>
                <input type="text" id="registrationCode" name="registrationCode">
            </p>
            <p>
                <label for="username">ユーザーID:</label>
                <input type="text" id="username" name="username" required>
            </p>
            <p>
                <label for="password">パスワード:</label>
                <input type="password" id="password" name="password" required>
            </p>
            <div class="button-group">
                <input type="submit" value="登録">
            </div>
        </form>
        <div class="footer">
            <a href="login.jsp">ログイン画面に戻る</a>
        </div>
    </div>
</body>
</html>