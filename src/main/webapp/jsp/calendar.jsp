<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.List" %>
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
        }
        .calendar-day {
            text-align: center;
            padding: 15px 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .calendar-day.empty {
            background-color: transparent;
            border: none;
        }
        .calendar-day.today {
            background-color: #e6f7ff;
            border-color: #007bff;
        }
        .calendar-day a {
            text-decoration: none;
            color: inherit;
            display: block;
            height: 100%;
        }
        .reservation-list {
            list-style: none;
            padding: 0;
            margin: 5px 0 0 0;
        }
        .reservation-list li {
            font-size: 0.8em;
            background-color: #fff;
            padding: 2px 5px;
            border-left: 5px solid; /* 予約色を表示する場所 */
            margin-top: 3px;
            border-radius: 3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            text-align: left;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="calendar-nav">
            <a href="calendar?yearMonth=<c:out value="${prevMonth}"/>">前月</a>
            <h2><c:out value="${yearMonth}"/></h2>
            <a href="calendar?yearMonth=<c:out value="${nextMonth}"/>">次月</a>
        </div>
        <div class="calendar-grid">
            <div class="calendar-day">日</div>
            <div class="calendar-day">月</div>
            <div class="calendar-day">火</div>
            <div class="calendar-day">水</div>
            <div class="calendar-day">木</div>
            <div class="calendar-day">金</div>
            <div class="calendar-day">土</div>
            <c:forEach var="date" items="${dates}">
                <c:choose>
                    <c:when test="${date != null}">
                        <a href="date_detail?date=<c:out value="${date}"/>" class="calendar-day <c:if test='${date.equals(java.time.LocalDate.now())}'>today</c:if>">
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