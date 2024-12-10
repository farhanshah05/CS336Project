<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Update Schedule</title>
</head>
<body>
<%
    // Initialize variables and capture inputs
    String scheduleID = request.getParameter("scheduleID");
    boolean hasError = false;

    if (scheduleID == null || scheduleID.isEmpty()) {
        out.println("<h2>Invalid Schedule ID. <a href='customer_rep.jsp'>Go back</a></h2>");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try {
        con.setAutoCommit(false); // Start a transaction

        // Loop through the parameters to find all stop updates
        for (String paramName : request.getParameterMap().keySet()) {
            if (paramName.startsWith("arrivalTime_")) {
                String stopID = paramName.substring("arrivalTime_".length());
                String arrivalTime = request.getParameter("arrivalTime_" + stopID);
                String departureTime = request.getParameter("departureTime_" + stopID);

                // Validate input format
                if (arrivalTime == null || departureTime == null || 
                    arrivalTime.isEmpty() || departureTime.isEmpty()) {
                    hasError = true;
                    break;
                }

                try {
                    // Update database
                    PreparedStatement stmt = con.prepareStatement(
                        "UPDATE TrainStops SET ArrivalTime = ?, DepartureTime = ? WHERE StopID = ?"
                    );
                    stmt.setString(1, arrivalTime.replace("T", " "));
                    stmt.setString(2, departureTime.replace("T", " "));
                    stmt.setInt(3, Integer.parseInt(stopID));

                    if (stmt.executeUpdate() == 0) {
                        hasError = true;
                        break;
                    }
                } catch (SQLException e) {
                    hasError = true;
                    out.println("<p>Error updating stop ID " + stopID + ": " + e.getMessage() + "</p>");
                }
            }
        }

        if (hasError) {
            con.rollback(); // Revert changes if there was an error
            out.println("<h2>Invalid input. Please try again. <a href='EditSchedule.jsp?scheduleID=" + scheduleID + "'>Go back</a></h2>");
        } else {
            con.commit(); // Commit changes if everything is successful
            out.println("<h2>Schedule updated successfully! <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        }
    } catch (Exception e) {
        con.rollback();
        out.println("<p>Error updating schedule: " + e.getMessage() + "</p>");
    } finally {
        try {
            con.setAutoCommit(true); // Reset auto-commit
            con.close();
        } catch (SQLException e) {
            out.println("<p>Error closing the connection: " + e.getMessage() + "</p>");
        }
    }
%>
</body>
</html>
