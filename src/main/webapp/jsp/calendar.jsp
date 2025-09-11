<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.DayOfWeek" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.example.attendance.dto.Reservation" %>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>カレンダー</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
    <style>
        .calendar-nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .calendar-nav h2 {
            margin: 0;
        }
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 5px;
            text-decoration: none !important;
        }
        .calendar-day {
            text-align: center;
            padding: 15px 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
            text-decoration: none;
            color: #333;
        }
        .calendar-day:hover {
        	transform: translateY(-2px);
	        box-shadow: 0 6px 15px rgba(52, 152, 219, 0.5);
        }
        .calendar-day.empty {
            background-color: transparent;
            border: none;
        }
        .calendar-day.today {
            background-color: rgb(137, 170, 242) !important;
            color: #fff !important;
            border: 2px solid #0056b3 !important;
            font-weight: bold;
        }
        .calendar-day.sunday, .calendar-day.holiday {
            color: #d9534f; /* 赤色 */
        }
        .calendar-day.saturday {
            color: #0275d8; /* 青色 */
        }
        .reservation-list {
            list-style: none;
            padding: 0;
            margin-top: 5px;
            text-align: left;
            font-size: 0.8em;
        }
        .reservation-list li {
            padding: 2px;
            border-left: 5px solid;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .main-nav a {
            padding: 10px 20px;
            background-color: #6c757d;
            color: #fff;
            border-radius: 5px;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        .main-nav a:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>カレンダー</h1>
        <div class="main-nav">
            <a href="<%= request.getContextPath() %>/attendance?action=filter">勤怠履歴管理</a>
            <a href="<%= request.getContextPath() %>/users?action=list">ユーザー管理</a>
            <a href="<%= request.getContextPath() %>/logout">ログアウト</a>
        </div>
        <div class="calendar-nav">
            <a href="calendar?yearMonth=<c:out value="${prevMonth}"/>" class="button">＜ 前月</a>
            <h2><c:out value="${yearMonth}"/></h2>
            <a href="calendar?yearMonth=<c:out value="${nextMonth}"/>" class="button">次月 ＞</a>
        </div>
        <div class="calendar-grid">
            <div class="calendar-day sunday">日</div>
            <div class="calendar-day">月</div>
            <div class="calendar-day">火</div>
            <div class="calendar-day">水</div>
            <div class="calendar-day">木</div>
            <div class="calendar-day">金</div>
            <div class="calendar-day saturday">土</div>
            <c:forEach var="date" items="${dates}">
                <c:choose>
                    <c:when test="${date != null}">
                        <c:set var="isToday" value="${date.equals(today)}"/>
                        <c:set var="isSunday" value="${date.dayOfWeek.equals(java.time.DayOfWeek.SUNDAY)}"/>
                        <c:set var="isSaturday" value="${date.dayOfWeek.equals(java.time.DayOfWeek.SATURDAY)}"/>
                        <c:set var="isHoliday" value="${holidays.contains(date)}"/>
                        <a href="date_detail?date=<c:out value="${date}"/>" class="calendar-day
                            <c:if test='${isToday}'>today</c:if>
                            <c:if test='${!isToday && isSunday}'>sunday</c:if>
                            <c:if test='${!isToday && isSaturday}'>saturday</c:if>
                            <c:if test='${!isToday && isHoliday}'>holiday</c:if>
                        ">
                            <strong><c:out value="${date.dayOfMonth}" /></strong>
                            <ul class="reservation-list">
                                <c:forEach var="res" items="${reservationsByDate.get(date)}">
                                    <li style="border-left-color: <c:out value="${res.color}"/>;">
                                        <c:out value="${res.username}"/>: <c:out value="${res.type}"/>
                                    </li>
                                </c:forEach>
                            </ul>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="calendar-day empty"></div>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </div>
        <div class="main-nav" style="margin-top: 20px;">
            <a href="jsp/employee_menu.jsp">従業員メニューに戻る</a>
        </div>
    </div>
</body>
</html>