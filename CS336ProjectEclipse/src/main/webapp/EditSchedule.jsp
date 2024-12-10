<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<%
    String scheduleID = request.getParameter("scheduleID");

    if (scheduleID == null || scheduleID.isEmpty()) {
        out.println("<h2>Invalid Schedule ID. <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();
%>
<html>
<head>
    <title>Edit Train Schedule</title>
</head>
<body>
    <h1>Edit Train Schedule for Schedule ID: <%= scheduleID %></h1>
    <form method="POST" action="UpdateSchedule.jsp">
        <table border="1">
            <tr>
                <th>Stop ID</th>
                <th>Station</th>
                <th>Arrival Time</th>
                <th>Departure Time</th>
                <th>Action</th>
            </tr>
            <%
                try (PreparedStatement stmt = con.prepareStatement(
                        "SELECT ts.StopID, s.StationName, ts.ArrivalTime, ts.DepartureTime " +
                        "FROM TrainStops ts " +
                        "JOIN Stations s ON ts.StationID = s.StationID " +
                        "WHERE ts.ScheduleID = ? ORDER BY ts.ArrivalTime")) {
                    stmt.setInt(1, Integer.parseInt(scheduleID));
                    ResultSet rs = stmt.executeQuery();

                    while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getInt("StopID") %></td>
                <td><%= rs.getString("StationName") %></td>
                <td>
                    <input type="datetime-local" name="arrivalTime_<%= rs.getInt("StopID") %>" 
                           value="<%= rs.getTimestamp("ArrivalTime").toString().replace(" ", "T") %>">
                </td>
                <td>
                    <input type="datetime-local" name="departureTime_<%= rs.getInt("StopID") %>" 
                           value="<%= rs.getTimestamp("DepartureTime").toString().replace(" ", "T") %>">
                </td>
                <td>
                    <form action="DeleteSchedule.jsp" method="POST">
                        <input type="hidden" name="stopID" value="<%= rs.getInt("StopID") %>">
                        <button type="submit">Delete Stop</button>
                    </form>
                </td>
            </tr>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading stops: " + e.getMessage() + "</p>");
                }
            %>
        </table>
        <input type="hidden" name="scheduleID" value="<%= scheduleID %>">
        <button type="submit">Save Changes</button>
    </form>

    <h3>Add a New Stop</h3>
    <form method="POST" action="AddStop.jsp">
        <input type="hidden" name="scheduleID" value="<%= scheduleID %>">
        <label for="station">Station:</label>
        <select name="stationID">
            <%
                try (Statement stmt = con.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");

                    while (rs.next()) {
            %>
            <option value="<%= rs.getInt("StationID") %>"><%= rs.getString("StationName") %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
                }
            %>
        </select>
        <label for="arrivalTime">Arrival Time:</label>
        <input type="datetime-local" name="arrivalTime" required>
        <label for="departureTime">Departure Time:</label>
        <input type="datetime-local" name="departureTime" required>
        <button type="submit">Add Stop</button>
    </form>

    <br>
    <a href="CustomerRepresentative.jsp">Back to Dashboard</a>
</body>
</html>
