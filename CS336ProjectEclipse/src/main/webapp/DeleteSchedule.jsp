<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Schedule</title>
</head>
<body>
<%
    String scheduleID = request.getParameter("scheduleID");
    String stopID = request.getParameter("stopID");
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try {
        con.setAutoCommit(false); // Start transaction

        if (stopID != null) {
            // Delete a single stop
            PreparedStatement deleteStopStmt = con.prepareStatement("DELETE FROM TrainStops WHERE StopID = ?");
            deleteStopStmt.setInt(1, Integer.parseInt(stopID));
            deleteStopStmt.executeUpdate();
            con.commit();
            out.println("<h2>Stop deleted successfully. <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        } else if (scheduleID != null) {
            // Delete all stops for the schedule
            PreparedStatement deleteStopsStmt = con.prepareStatement("DELETE FROM TrainStops WHERE ScheduleID = ?");
            deleteStopsStmt.setInt(1, Integer.parseInt(scheduleID));
            deleteStopsStmt.executeUpdate();

            // Delete the schedule itself
            PreparedStatement deleteScheduleStmt = con.prepareStatement("DELETE FROM TrainSchedules WHERE ScheduleID = ?");
            deleteScheduleStmt.setInt(1, Integer.parseInt(scheduleID));
            deleteScheduleStmt.executeUpdate();

            con.commit();
            out.println("<h2>Schedule and all associated stops deleted successfully. <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        } else {
            out.println("<h2>Invalid request. No schedule or stop specified. <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        }
    } catch (SQLException e) {
        con.rollback();
        out.println("<h2>Error processing request: " + e.getMessage() + ". <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
    } finally {
        try {
            con.setAutoCommit(true);
            con.close();
        } catch (SQLException e) {
            out.println("<h2>Error closing connection: " + e.getMessage() + ". <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        }
    }
%>
</body>
</html>
