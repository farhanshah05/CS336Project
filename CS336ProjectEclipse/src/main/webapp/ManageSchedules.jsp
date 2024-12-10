<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><%
    // Retrieve session attributes
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    // Ensure the user is logged in and has the 'employee' role
    if (user == null || !"employee".equals(role)) {
        response.sendRedirect("Login.jsp"); // Redirect unauthorized users to the login page
        return;
    }

    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Train Schedules</title>
</head>
<body>
    <h1>Manage Train Schedules</h1>
    <h2>Welcome, <%= user %>!</h2>

    <h3>Available Train Schedules</h3>
    <table border="1">
        <tr>
            <th>Schedule ID</th>
            <th>Line Name</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Actions</th>
        </tr>
        <%
            try (Statement stmt = con.createStatement()) {
                ResultSet rs = stmt.executeQuery(
                    "SELECT ts.ScheduleID, t.LineName, ts.Departure, ts.Arrival " +
                    "FROM TrainSchedules ts " +
                    "JOIN TransitLines t ON ts.LineID = t.LineID");

                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("ScheduleID") %></td>
            <td><%= rs.getString("LineName") %></td>
            <td><%= rs.getTimestamp("Departure") %></td>
            <td><%= rs.getTimestamp("Arrival") %></td>
            <td>
                <form action="EditSchedule.jsp" method="POST" style="display:inline;">
                    <input type="hidden" name="scheduleID" value="<%= rs.getInt("ScheduleID") %>">
                    <button type="submit">Edit</button>
                </form>
                <form action="DeleteSchedule.jsp" method="POST" style="display:inline;">
                    <input type="hidden" name="scheduleID" value="<%= rs.getInt("ScheduleID") %>">
                    <button type="submit">Delete</button>
                </form>
            </td>
        </tr>
        <%
                }
            } catch (SQLException e) {
                out.println("<p>Error fetching train schedules: " + e.getMessage() + "</p>");
            }
        %>
    </table>
</body>
</html>
