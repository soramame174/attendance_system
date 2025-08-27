<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ログイン</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>
<body>
    <div class="container">
	<h1>勤怠管理システム</h1>
	<form action="login" method="post">
		<p>
			<label for="username">ユーザーID:</label>
			<input type="text" id="username"
			name="username"required>
		</p>
		<p>
			<label for="password">パスワード:</label>
			<input type="password" id="password" name="password" required>
		</p>
		<div class="button-group">
			<input type="submit" value="ログイン">
		</div>
	</form>
	<c:if test="${not empty sessionScope.successMessage}">
		<p class="success-message"><c:out value="${sessionScope.successMessage}"/></p>
		<c:remove var="successMessage" scope="session"/>
	</c:if>
<!-- 	<p style="text-align:center; margin-top:20px;">
		<a href="register">新規登録はこちら</a>
   	</p> -->
</div>
            
</body>
</html>