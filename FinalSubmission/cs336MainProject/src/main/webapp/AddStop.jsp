<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<title>Add Stop</title>
</head>
<body>
	<%
	String scheduleID = request.getParameter("scheduleID");
	String stationID = request.getParameter("stationID");
	String arrivalTime = request.getParameter("arrivalTime");
	String departureTime = request.getParameter("departureTime");
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();

	if (scheduleID == null || stationID == null || arrivalTime == null || departureTime == null || scheduleID.isEmpty()
			|| stationID.isEmpty() || arrivalTime.isEmpty() || departureTime.isEmpty()) {
		out.println("<h2>Invalid input. Please ensure all fields are filled. <a href='EditSchedule.jsp?scheduleID="
		+ scheduleID + "'>Go back</a></h2>");
		return;
	}

	try {
		// Insert a new stop into TrainStops
		PreparedStatement stmt = con.prepareStatement(
		"INSERT INTO TrainStops (ScheduleID, StationID, ArrivalTime, DepartureTime) VALUES (?, ?, ?, ?)");
		stmt.setInt(1, Integer.parseInt(scheduleID));
		stmt.setInt(2, Integer.parseInt(stationID));
		stmt.setString(3, arrivalTime.replace("T", " "));
		stmt.setString(4, departureTime.replace("T", " "));

		int rows = stmt.executeUpdate();
		if (rows > 0) {
			out.println("<h2>Stop added successfully! <a href='EditSchedule.jsp?scheduleID=" + scheduleID
			+ "'>Go back</a></h2>");
		} else {
			out.println(
			"<h2>Failed to add stop. <a href='EditSchedule.jsp?scheduleID=" + scheduleID + "'>Go back</a></h2>");
		}
	} catch (SQLException e) {
		out.println("<h2>Error adding stop: " + e.getMessage() + ". <a href='EditSchedule.jsp?scheduleID=" + scheduleID
		+ "'>Go back</a></h2>");
	} finally {
		try {
			con.close();
		} catch (SQLException e) {
			out.println("<h2>Error closing the connection: " + e.getMessage() + "</h2>");
		}
	}
	%>
</body>
</html>