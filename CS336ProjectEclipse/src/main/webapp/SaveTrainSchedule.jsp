<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Save Train Schedule</title>
</head>
<body>
<%
    String lineID = request.getParameter("lineID");
    String firstStop = request.getParameter("firstStop");
    String nextStop = request.getParameter("nextStop");
    String arrivalTime = request.getParameter("arrivalTime");
    String departureTime = request.getParameter("departureTime");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try {
        // Insert into TrainSchedules
        PreparedStatement psSchedule = con.prepareStatement(
            "INSERT INTO TrainSchedules (LineID) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
        psSchedule.setInt(1, Integer.parseInt(lineID));
        psSchedule.executeUpdate();

        ResultSet generatedKeys = psSchedule.getGeneratedKeys();
        int scheduleID = 0;
        if (generatedKeys.next()) {
            scheduleID = generatedKeys.getInt(1);
        }

        // Insert Stops
        PreparedStatement psStop1 = con.prepareStatement(
            "INSERT INTO TrainStops (ScheduleID, StationID, ArrivalTime, DepartureTime) VALUES (?, ?, ?, ?)");
        psStop1.setInt(1, scheduleID);
        psStop1.setInt(2, Integer.parseInt(firstStop));
        psStop1.setString(3, arrivalTime);
        psStop1.setString(4, departureTime);
        psStop1.executeUpdate();

        PreparedStatement psStop2 = con.prepareStatement(
            "INSERT INTO TrainStops (ScheduleID, StationID, ArrivalTime, DepartureTime) VALUES (?, ?, ?, ?)");
        psStop2.setInt(1, scheduleID);
        psStop2.setInt(2, Integer.parseInt(nextStop));
        psStop2.setString(3, arrivalTime);
        psStop2.setString(4, departureTime);
        psStop2.executeUpdate();

        out.println("<p>Train schedule added successfully!</p>");
        out.println("<a href='CustomerRepresentative.jsp'>Back to Dashboard</a>");
    } catch (SQLException e) {
        out.println("<p>Error saving train schedule: " + e.getMessage() + "</p>");
        out.println("<a href='AddTrainSchedule.jsp'>Go Back</a>");
    } finally {
        con.close();
    }
%>
</body>
</html>
