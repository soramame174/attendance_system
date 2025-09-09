<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>管理者メニュー</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
	.attendance-controls {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
    }
    .check-in {
		background-color: #28a745;
	}
	.check-in:hover {
	    background-color: #218838;
	}
	.check-out {
	    background-color: #dc3545;
	}
	.check-out:hover {
	    background-color: #c82333;
	}
    .chart-container {
        width: 100%;
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
        gap: 20px;
    }
    .chart-box {
        width: 50%;
        height: 400px;
        background-color: #f9f9f9;
        border-radius: 8px;
        padding: 20px;
    }
    .table-scroll-container {
	  max-height: 400px;
	  overflow-y: auto;
	  border-radius: 10px;
	  background-color: var(--surface-color);
	}
    .table-scroll-container table {
        width: 100%;
        border-collapse: collapse;
    }
    .table-scroll-container thead th {
        position: sticky;
        top: 0;
        background-color: #f2f2f2;
        z-index: 10;
        box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
    }
    .button.danger.disabled-button {
        background-color: #e0e0e0;
        cursor: not-allowed;
        border: 1px solid #ccc;
        color: #a0a0a0;
    }
</style>
</head>
<body>
<div class="container">
	<h1>管理者メニュー</h1>
	<p>ようこそ, ${user.username}さん (管理者)</p>
	<div class="main-nav">
		<a href="attendance?action=filter">勤怠履歴管理</a>
		<a href="users?action=list">ユーザー管理</a>
		<a href="logout">ログアウト</a>
	</div>
	<c:if test="${not empty sessionScope.successMessage}">
		<p class="success-message"><c:out value="${sessionScope.successMessage}"/></p>
		<c:remove var="successMessage" scope="session"/>
	</c:if>
	
	<div class="section-container">
	    <h2>月別勤怠グラフ</h2>
	    <div class="chart-container">
	        <div class="chart-box">
	            <h3>月別合計労働時間</h3>
	            <canvas id="monthlyTotalHoursChart"></canvas>
	            <c:if test="${empty monthlyTotalHours}">
	                <p class="no-data">データがありません。</p>
	            </c:if>
	        </div>
	        <div class="chart-box">
	            <h3>月別出勤日数</h3>
	            <canvas id="monthlyAttendanceDaysChart"></canvas>
	            <c:if test="${empty monthlyAttendanceDays}">
	                <p class="no-data">データがありません。</p>
	            </c:if>
	        </div>
	    </div>
	</div>
	<h2>勤怠履歴</h2>
	<form action="attendance" method="get" class="filter-form">
		<input type="hidden" name="action" value="filter">
		<div>
			<label for="filterUserId">ユーザーID:</label>
			<input type="text" id="filterUserId" name="filterUserId" value="<c:out value="${param.filterUserId}"/>">
		</div>
		<div>
			<label for="startDate">開始日:</label>
			<input type="date" id="startDate" name="startDate" value="<c:out value="${param.startDate}"/>">
		</div>
		<div>
			<label for="endDate">終了日:</label>
			<input type="date" id="endDate" name="endDate" value="<c:out value="${param.endDate}"/>">
		</div>
		<button type="submit" class="button">フィルタ</button>
	</form>
	<a href="attendance?action=export_csv&filterUserId=<c:out value="${param.filterUserId}"/>&startDate=<c:out value="${param.startDate}"/>&endDate=<c:out value="${param.endDate}"/>" class="button">勤怠履歴を CSV エクスポート</a>
	<h3>勤怠サマリー (合計労働時間)</h3>
	<table class="summary-table">
	<thead>
	<tr>
		<th>ユーザーID</th>
		<th>合計労働時間 (時間)</th>
	</tr>
	</thead>
	<tbody>
		<c:forEach var="entry" items="${totalHoursByUser}">
			<tr>
				<td>${entry.key}</td>
				<td>${entry.value}</td>
			</tr>
		</c:forEach>
		<c:if test="${empty totalHoursByUser}">
			<tr><td colspan="2">データがありません。</td></tr>
		</c:if>
	</tbody>
	</table>
	<h2>管理者用の勤怠打刻</h2>
	<div class="attendance-controls">
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="check_in">
            <button type="submit" class="button check-in">出勤</button>
        </form>
        <form action="attendance" method="post">
            <input type="hidden" name="action" value="check_out">
            <button type="submit" class="button check-out">退勤</button>
        </form>
    </div>
	<h3>詳細勤怠履歴</h3>
	<form id="bulkDeleteForm" action="attendance" method="post">
	    <input type="hidden" name="action" value="bulk_delete">
	    <div class="button-group">
	        <button type="submit" class="button danger" id="bulkDeleteButton">選択項目を削除</button>
	    </div>
	    
	    <div class="table-scroll-container">
	        <table style="margin-top: -1px;">
	            <thead>
	                <tr>
	                    <th><input type="checkbox" id="selectAllCheckboxes"></th>
	                    <th>従業員 ID</th>
	                    <th>出勤時刻</th>
	                    <th>退勤時刻</th>
	                    <th>操作</th>
	                </tr>
	            </thead>
	            <tbody>
	                <c:forEach var="att" items="${allAttendanceRecords}">
	                    <tr>
	                        <td>
	                            <input type="checkbox" class="record-checkbox" name="recordsToDelete" value="${att.userId},${att.checkInTime}">
	                        </td>
	                        <td>${att.userId}</td>
	                        <td>${att.checkInTime}</td>
	                        <td>${att.checkOutTime}</td>
	                        <td class="table-actions">
	                            <form action="attendance" method="post" class="single-delete-form" style="display:inline;">
	                                <input type="hidden" name="action" value="delete_manual">
	                                <input type="hidden" name="userId" value="${att.userId}">
	                                <input type="hidden" name="checkInTime" value="${att.checkInTime}">
	                                <input type="hidden" name="checkOutTime" value="${att.checkOutTime}">
	                                <input type="submit" value="削除" class="button danger single-delete-button">
	                            </form>
	                        </td>
	                    </tr>
	                </c:forEach>
	                <c:if test="${empty allAttendanceRecords}">
	                    <tr><td colspan="5">データがありません。</td></tr>
	                </c:if>
	            </tbody>
	        </table>
	    </div>
    </form>
	<h2>勤怠記録の手動追加</h2>
	<form action="attendance" method="post">
		<input type="hidden" name="action" value="add_manual">
		<p>
			<label for="manualUserId">ユーザーID:</label>
			<input type="text" id="manualUserId" name="userId" required>
		</p>
		<p>
			<label for="manualCheckInTime">出勤時刻:</label>
			<input type="datetime-local" id="manualCheckInTime" name="checkInTime" required>
		</p>
		<p>
			<label for="manualCheckOutTime">退勤時刻 (任意):</label>
			<input type="datetime-local" id="manualCheckOutTime" name="checkOutTime">
		</p>
		<div class="button-group">
			<input type="submit" value="追加">
		</div>
	</form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        function createChart(canvasId, chartData, chartLabel, backgroundColor, borderColor, yAxisTitle) {
            
            const labels = Object.keys(chartData).sort();
            const values = labels.map(key => chartData[key]);
            if (labels.length > 0) {
                document.getElementById(canvasId).style.display = 'block';
                const noDataElement = document.getElementById(canvasId).parentElement.querySelector('.no-data');
                if (noDataElement) {
                    noDataElement.style.display = 'none';
                }

                const ctx = document.getElementById(canvasId).getContext('2d');
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: chartLabel,
                            data: values,
                            backgroundColor: backgroundColor,
                            borderColor: borderColor,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: yAxisTitle
                                }
                            }
                        }
                    }
                });
            } else {
                document.getElementById(canvasId).style.display = 'none';
                const noDataElement = document.getElementById(canvasId).parentElement.querySelector('.no-data');
                if (noDataElement) {
                    noDataElement.style.display = 'block';
                }
            }
        }

        const monthlyTotalHoursRaw = '${monthlyWorkingHours}';
        const monthlyAttendanceDaysRaw = '${monthlyCheckInCounts}';
        
        let monthlyTotalHoursData = {};
        let monthlyAttendanceDaysData = {};
        try {
            if (monthlyTotalHoursRaw && monthlyTotalHoursRaw !== 'null' && monthlyTotalHoursRaw.length > 2) {
                monthlyTotalHoursData = JSON.parse(monthlyTotalHoursRaw.replace(/=/g, '":').replace(/, /g, ',"').replace(/{/g, '{"').replace(/}/g, '"}').replace(/" /g, ',"').replace(/""/g, '"'));
                for (const key in monthlyTotalHoursData) {
                    monthlyTotalHoursData[key] = monthlyTotalHoursData[key] / 60;
                }
            }
        } catch (e) {
            console.error("Error parsing monthlyTotalHours data:", e);
            console.error("Raw data:", monthlyTotalHoursRaw);
        }

        try {
            if (monthlyAttendanceDaysRaw && monthlyAttendanceDaysRaw !== 'null' && monthlyAttendanceDaysRaw.length > 2) {
                monthlyAttendanceDaysData = JSON.parse(monthlyAttendanceDaysRaw.replace(/=/g, '":').replace(/, /g, ',"').replace(/{/g, '{"').replace(/}/g, '"}').replace(/" /g, ',"').replace(/""/g, '"'));
            }
        } catch (e) {
            console.error("Error parsing monthlyAttendanceDays data:", e);
            console.error("Raw data:", monthlyAttendanceDaysRaw);
        }

        createChart('monthlyTotalHoursChart', monthlyTotalHoursData, '合計労働時間（時間）', 'rgba(54, 162, 235, 0.5)', 'rgba(54, 162, 235, 1)', '時間');
        createChart('monthlyAttendanceDaysChart', monthlyAttendanceDaysData, '出勤日数', 'rgba(75, 192, 192, 0.5)', 'rgba(75, 192, 192, 1)', '日数');

        const selectAllCheckbox = document.getElementById('selectAllCheckboxes');
        const bulkDeleteButton = document.getElementById('bulkDeleteButton');
        const bulkDeleteForm = document.getElementById('bulkDeleteForm');

        const recordCheckboxes = document.querySelectorAll('.record-checkbox');

        // 個別削除ボタンの状態を更新する関数
        function updateSingleDeleteButtons() {
            recordCheckboxes.forEach(checkbox => {
                const singleDeleteButton = checkbox.closest('tr').querySelector('.single-delete-button');
                if (singleDeleteButton) {
                    if (checkbox.checked) {
                        singleDeleteButton.disabled = false;
                        singleDeleteButton.classList.remove('disabled-button');
                    } else {
                        singleDeleteButton.disabled = true;
                        singleDeleteButton.classList.add('disabled-button');
                    }
                }
            });
        }
        
        // 一括削除ボタンの状態を更新する関数
        function updateBulkDeleteButtonState() {
            const checkedCount = document.querySelectorAll('.record-checkbox:checked').length;
            bulkDeleteButton.disabled = checkedCount === 0;
            if (checkedCount > 0) {
                bulkDeleteButton.classList.remove('disabled-button');
            } else {
                bulkDeleteButton.classList.add('disabled-button');
            }
        }

        // 全選択チェックボックスのイベントリスナー
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', function() {
                const isChecked = this.checked;
                recordCheckboxes.forEach(checkbox => {
                    checkbox.checked = isChecked;
                });
                updateSingleDeleteButtons();
                updateBulkDeleteButtonState();
            });
        }

        // 個別のチェックボックスのイベントリスナー
        recordCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                // 全選択チェックボックスの状態を更新
                const allChecked = Array.from(recordCheckboxes).every(cb => cb.checked);
                selectAllCheckbox.checked = allChecked;

                updateSingleDeleteButtons();
                updateBulkDeleteButtonState();
            });
        });

        // フォーム送信の制御（一括削除）
        bulkDeleteForm.addEventListener('submit', function(event) {
            const checkedCount = document.querySelectorAll('.record-checkbox:checked').length;
            if (checkedCount === 0) {
                alert('削除する項目を1つ以上選択してください。');
                event.preventDefault();
            } else if (!confirm('本当に選択した勤怠記録をすべて削除しますか？')) {
                event.preventDefault();
            }
        });
        
        // フォーム送信の制御（個別削除）
        document.querySelectorAll('.single-delete-form').forEach(form => {
            form.addEventListener('submit', function(event) {
                const checkbox = form.closest('tr').querySelector('.record-checkbox');
                if (!checkbox.checked) {
                    alert('この項目を削除するにはチェックボックスを選択してください。');
                    event.preventDefault();
                } else if (!confirm('本当にこの勤怠記録を削除しますか？')) {
                    event.preventDefault();
                }
            });
        });

        // ページ読み込み時にボタンの状態を初期化
        updateSingleDeleteButtons();
        updateBulkDeleteButtonState();
    });
</script>
</body>
</html>