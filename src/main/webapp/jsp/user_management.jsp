<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ユーザー管理</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
</head>
<body>
    <div class="container">
        <h1>ユーザー管理</h1>
        <div class="card">
            <c:if test="${not empty successMessage}">
                <div class="success-message">
                    <span class="material-symbols-outlined">check_circle</span>
                    <p>${successMessage}</p>
                </div>
            </c:if>
            <div class="main-nav">
				<a href="attendance?action=filter">勤怠履歴管理</a>
				<a href="users?action=list">ユーザー管理</a>
				<a href="logout">ログアウト</a>
			</div>
            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <span class="material-symbols-outlined">error</span>
                    <p>${errorMessage}</p>
                </div>
            </c:if>
            <div class="section-container">
                <div class="section-add">
                    <h2>ユーザー追加</h2>
                    <form action="users?action=add" method="post" class="user-form">
                        <input type="hidden" name="companyCode" value="${sessionScope.companyCode}">
                        <p>
                            <label for="add-username">ユーザーID:</label>
                            <input type="text" id="add-username" name="username" required>
                        </p>
                        <p>
                            <label for="add-password">パスワード:</label>
                            <input type="password" id="add-password" name="password" required>
                        </p>
                        <p>
                            <label for="add-role">役割:</label>
                            <select id="add-role" name="role">
                                <option value="employee">従業員</option>
                                <option value="admin">管理者</option>
                            </select>
                        </p>
                        <div class="button-group">
                            <input type="submit" value="追加">
                        </div>
                    </form>
                </div>
                <div class="section-list">
                    <h2>ユーザーリスト</h2>
                    <table>
                        <thead>
                            <tr>
                                <th>ユーザーID</th>
                                <th>役割</th>
                                <th>有効</th>
                                <th>操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="user" items="${users}">
                                <tr>
                                    <td>${user.username}</td>
                                    <td>${user.role}</td>
                                    <td>${user.enabled ? 'はい' : 'いいえ'}</td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="users?action=edit&username=${user.username}" class="button">編集</a>
                                            <form action="users?action=delete" method="post" style="display:inline-block;">
                                                <input type="hidden" name="username" value="${user.username}">
                                                <input type="hidden" name="companyCode" value="${sessionScope.companyCode}">
                                                <input type="submit" value="削除" class="button-delete" onclick="return confirm('本当に削除しますか？');">
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <c:if test="${not empty userToEdit}">
                    <div class="section-edit">
                        <h2>ユーザー編集</h2>
                        <form action="users?action=update" method="post" class="user-form">
                            <input type="hidden" name="username" value="${userToEdit.username}">
                            <input type="hidden" name="companyCode" value="${sessionScope.companyCode}">
                            <p>
                                <label for="edit-newUsername">新しいユーザーID:</label>
                                <input type="text" id="edit-newUsername" name="newUsername" value="${userToEdit.username}" required>
                            </p>
                            <p>
                                <label for="edit-password">新しいパスワード:</label>
                                <input type="password" id="edit-password" name="password" placeholder="変更しない場合は空欄">
                            </p>
                            <p>
                                <label for="edit-role">役割:</label>
                                <select id="edit-role" name="role">
                                    <option value="employee" <c:if test="${userToEdit.role eq 'employee'}">selected</c:if>>従業員</option>
                                    <option value="admin" <c:if test="${userToEdit.role eq 'admin'}">selected</c:if>>管理者</option>
                                </select>
                            </p>
                            <p>
                                <label for="edit-enabled">有効:</label>
                                <select id="edit-enabled" name="enabled">
                                    <option value="true" <c:if test="${userToEdit.enabled}">selected</c:if>>はい</option>
                                    <option value="false" <c:if test="${!userToEdit.enabled}">selected</c:if>>いいえ</option>
                                </select>
                            </p>
                            <div class="button-group">
                                <input type="submit" value="更新">
                                <a href="users?action=list" class="button secondary">キャンセル</a>
                            </div>
                        </form>
                    </div>
                </c:if>
            </div>
        </div>
        <!-- <div class="footer">
            <a href="attendance">勤怠管理に戻る</a>
        </div> -->
    </div>
</body>
</html>