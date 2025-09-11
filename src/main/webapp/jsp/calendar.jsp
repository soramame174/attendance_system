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
            flex-grow: 1;
            text-align: center;
        }
        .calendar-nav-button {
            padding: 8px 15px;
            border: 1px solid var(--border-color);
            border-radius: 5px;
            background-color: var(--primary-color);
            color: white;
            text-decoration: none;
            transition: background-color 0.3s, border-color 0.3s;
        }
        .calendar-nav-button:hover {
            background-color: var(--primary-hover-color);
            border-color: var(--primary-hover-color);
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
            background-color: #e0f7fa;
            border-color: #00bcd4;
        }
        /* 土日と祝日の文字色を確実に適用 */
        .calendar-day.sunday, .calendar-day.holiday {
            color: var(--danger-color);
        }
        .calendar-day.saturday {
            color: var(--primary-color);
        }
        /* 日付の文字色も変更 */
        .calendar-day.sunday strong, .calendar-day.holiday strong {
            color: var(--danger-color) !important;
        }
        .calendar-day.saturday strong {
		    color: var(--primary-color) !important;
		}
        
        .calendar-day strong {
            display: block;
            font-size: 1.2em;
            margin-bottom: 5px;
        }
        .reservation-list {
            list-style: none;
            padding: 0;
            margin: 0;
            font-size: 0.8em;
            text-align: left;
        }
        .reservation-list li {
            padding: 2px 5px;
            border-left: 5px solid;
            margin-bottom: 2px;
            overflow: hidden;
            white-space: nowrap;
            text-overflow: ellipsis;
            color: #333;
        }
        /* 曜日タイトルの色 */
        .day-of-week {
            font-weight: bold;
            text-align: center;
            padding: 10px 5px;
        }
        .day-of-week.sunday {
            color: var(--danger-color);
        }
        .day-of-week.saturday {
            color: var(--primary-color);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>カレンダー</h1>
        <div class="calendar-nav">
            <a href="calendar?yearMonth=${prevMonth}" class="calendar-nav-button">&lt; 前の月</a>
            <h2><c:out value="${yearMonth}" /></h2>
            <a href="calendar?yearMonth=${nextMonth}" class="calendar-nav-button">次の月 &gt;</a>
        </div>
        <div class="calendar-grid">
            <div class="day-of-week sunday">日</div>
            <div class="day-of-week">月</div>
            <div class="day-of-week">火</div>
            <div class="day-of-week">水</div>
            <div class="day-of-week">木</div>
            <div class="day-of-week">金</div>
            <div class="day-of-week saturday">土</div>
            <c:forEach var="date" items="${dates}">
                <c:choose>
                    <c:when test="${not empty date}">
                        <c:set var="isToday" value="${date.equals(today)}"/>
                        <c:set var="isSunday" value="${date.dayOfWeek.equals(java.time.DayOfWeek.SUNDAY)}"/>
                        <c:set var="isSaturday" value="${date.dayOfWeek.equals(java.time.DayOfWeek.SATURDAY)}"/>
                        <c:set var="isHoliday" value="${holidays.contains(date)}"/>
                        
                        <a href="date_detail?date=<c:out value="${date}"/>" class="calendar-day
                            <c:if test='${isToday}'>today</c:if>
                            <c:if test='${isSunday || isHoliday}'>sunday holiday</c:if>
                            <c:if test='${isSaturday}'>saturday</c:if>
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
            <c:choose>
                <c:when test="${currentUser.role eq 'admin'}">
                    <a href="jsp/admin_menu.jsp">管理者メニューに戻る</a>
                </c:when>
                <c:otherwise>
                    <a href="jsp/employee_menu.jsp">従業員メニューに戻る</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</body>
</html>