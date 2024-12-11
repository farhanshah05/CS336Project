<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Customer Portal</title>
<style>
body {
	margin: 0;
}

.logout {
	position: absolute;
	top: 10px;
	right: 10px;
}

.container {
	text-align: center;
	margin-top: 50px;
}

.container button {
	display: block;
	margin: 10px auto;
	padding: 10px 20px;
	font-size: 16px;
}
</style>
</head>
<body>
	<%
	if (session.getAttribute("user") == null) {
	%>
	You are not logged in
	<br />
	<a href="Login.jsp">Please Login</a>
	<%
	} else {
	%>
	<div class="logout">
		<a href="Logout.jsp">Log out</a>
	</div>
	<div class="container">
		<h2>
			Welcome
			<%=session.getAttribute("user")%></h2>
		<%
		String role = (String) session.getAttribute("role");
		if ("customer".equals(role)) {
		%>
		<button onclick="location.href='CustomerDashboard.jsp'">Customer
			Dashboard</button>
		<button onclick="location.href='ReserveSchedule.jsp'">Reserve/View
			Train Schedules</button>
		<button onclick="location.href='ViewReservations.jsp'">View
			Reservations</button>
		<%
		}
		if ("employee".equals(role)) {
		%>
		<button onclick="location.href='CustomerRepresentative.jsp'">Customer
			Representative Dashboard</button>

		<%
		}
		if ("admin".equals(role)) {
		%>
		<button onclick="location.href='AdminDashboard.jsp'">Admin
			Dashboard</button>
		<%
		}
		%>
	</div>
	<%
	}
	%>
</body>
</html>
