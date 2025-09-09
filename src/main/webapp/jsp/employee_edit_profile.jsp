<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>プロフィール編集</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
    <style>
        /* メッセージボックスのスタイル */
        .message-box {
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        /* エラーメッセージの色と枠線 */
        .message-box.error-message {
            background-color: #fce8e8;
            color: #a42323;
        }

        /* 成功メッセージの色と枠線 */
        .message-box.success-message {
            background-color: #e8f9e8;
            color: #1e601e;
        }

        .form-container {
            width: 80%;
            margin: 20px auto;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .form-container label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-container input[type="text"],
        .form-container input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box; /* Ensures padding doesn't affect total width */
        }
        .form-container button {
            background-color: #007bff;
            color: #fff;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .form-container button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>プロフィール編集</h1>
        
        <div class="main-nav">
            <a href="logout">ログアウト</a>
            <a href="attendance">従業員メニューに戻る</a>
        </div>
        
        <div class="form-container">
            <c:if test="${not empty errorMessage}">
                <div class="message-box error-message">
                    <p>${errorMessage}</p>
                    <c:remove var="errorMessage" scope="session"/>
                </div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="message-box success-message">
                    <p>${successMessage}</p>
                    <c:remove var="successMessage" scope="session"/>
                </div>
            </c:if>
            
            <form action="profile_edit" method="post">
                <input type="hidden" name="originalUsername" value="${user.username}">
                <p>現在のユーザーID: **${user.username}**</p>
                
                <label for="newUsername">新しいユーザーID:</label>
                <input type="text" id="newUsername" name="newUsername" value="${user.username}" required>

                <label for="newPassword">新しいパスワード:</label>
                <input type="password" id="newPassword" name="newPassword" placeholder="パスワードを変更する場合のみ入力">

                <button type="submit">更新</button>
            </form>
        </div>
    </div>
</body>
</html>