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
            <div class="main-nav">
				<a href="attendance?action=filter">勤怠履歴管理</a>
				<a href="users?action=list">ユーザー管理</a>
				<a href="logout">ログアウト</a>
			</div>
			<c:if test="${not empty successMessage}">
                <div class="success-message">
                    <span class="material-symbols-outlined">check_circle</span>
                    <p>${successMessage}</p>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="error-message">
                    <span class="material-symbols-outlined">error</span>
                    <p>${errorMessage}</p>
                </div>
            </c:if>
            <div class="card-body">
                <div class="button-group">
                    <a href="users?action=generate_code" class="button">社員用登録コード生成</a>
                </div>
                <h2>ユーザーリスト</h2>
                <table>
                    <thead>
                        <tr>
                            <th>ユーザーID</th>
                            <th>役割</th>
                            <th>有効/無効</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="user" items="${users}">
                            <tr>
                                <td><c:out value="${user.username}" /></td>
                                <td><c:out value="${user.role}" /></td>
                                <td>
                                    <c:if test="${user.enabled}">
                                        <span class="status-enabled">有効</span>
                                    </c:if>
                                    <c:if test="${!user.enabled}">
                                        <span class="status-disabled">無効</span>
                                    </c:if>
                                </td>
                                <td>
                                    <a href="users?action=edit&username=<c:out value="${user.username}"/>" class="button">編集</a>
                                    <form action="users?action=delete" method="post" onsubmit="return confirm('本当に削除しますか？');" style="display:inline;">
                                        <input type="hidden" name="username" value="<c:out value="${user.username}"/>">
                                        <input type="submit" value="削除" class="button delete">
                                    </form>
                                    <c:if test="${user.enabled}">
                                        <form action="users?action=toggle_enabled" method="post" style="display:inline;">
                                            <input type="hidden" name="username" value="<c:out value="${user.username}"/>">
                                            <input type="hidden" name="enabled" value="false">
                                            <input type="submit" value="無効化" class="button secondary">
                                        </form>
                                    </c:if>
                                    <c:if test="${!user.enabled}">
                                        <form action="users?action=toggle_enabled" method="post" style="display:inline;">
                                            <input type="hidden" name="username" value="<c:out value="${user.username}"/>">
                                            <input type="hidden" name="enabled" value="true">
                                            <input type="submit" value="有効化" class="button success">
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${userToEdit != null}">
                    <div class="edit-form">
                        <h2>ユーザー情報編集</h2>
                        <form action="users?action=update" method="post">
                            <input type="hidden" name="originalUsername" value="${userToEdit.username}">
                            <p>
                                <label for="edit-username">ユーザーID:</label>
                                <input type="text" id="edit-username" name="username" value="${userToEdit.username}" required>
                            </p>
                            <p>
							    <label for="edit-password">新しいパスワード:</label>
							    <input type="password" id="edit-password" name="newPassword" placeholder="変更しない場合は空欄">
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
    </div>
</body>
</html>