<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<%
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
<html>
<head>
    <title>Customer Representative Dashboard</title>
</head>
<body>
    <h1>Welcome, <%= user %>!</h1>
    <h2>Customer Representative Dashboard</h2>

    <form action="Logout.jsp" method="GET" style="margin-top: 20px;">
	    <button type="submit">Logout</button>
	</form><br>

    <!-- Manage Train Schedules -->
    <h3>Manage Train Schedules</h3>

    <!-- Sorting Options -->
    <form method="GET">
        <label for="sort">Sort By:</label>
        <select name="sort" id="sort">
            <option value="">--Select--</option>
            <option value="departure">Departure Time</option>
            <option value="arrival">Arrival Time</option>
            <option value="lineName">Line Name</option>
            <option value="fare">Total Fare</option>
        </select>
        <button type="submit">Sort</button>
    </form>

    <table border="1">
        <tr>
            <th>Schedule ID</th>
            <th>Line Name</th>
            <th>Departure (First Stop)</th>
            <th>Arrival (Last Stop)</th>
            <th>Total Fare</th>
            <th>Actions</th>
        </tr>
        <%
            String sortOption = request.getParameter("sort");
            String orderByClause = "";

            if ("departure".equals(sortOption)) {
                orderByClause = "ORDER BY Departure";
            } else if ("arrival".equals(sortOption)) {
                orderByClause = "ORDER BY Arrival";
            } else if ("lineName".equals(sortOption)) {
                orderByClause = "ORDER BY tl.LineName";
            } else if ("fare".equals(sortOption)) {
                orderByClause = "ORDER BY TotalFare DESC";
            }

            String query = "SELECT ts.ScheduleID, tl.LineName, " +
                           "(SELECT MIN(ts1.ArrivalTime) FROM TrainStops ts1 WHERE ts1.ScheduleID = ts.ScheduleID) AS Departure, " +
                           "(SELECT MAX(ts2.DepartureTime) FROM TrainStops ts2 WHERE ts2.ScheduleID = ts.ScheduleID) AS Arrival, " +
                           "(SELECT SUM(r.TotalFare) FROM Reservations r WHERE r.LineID = tl.LineID) AS TotalFare " +
                           "FROM TrainSchedules ts " +
                           "JOIN TransitLines tl ON ts.LineID = tl.LineID " +
                           orderByClause;

            try (Statement stmt = con.createStatement()) {
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("ScheduleID") %></td>
            <td><%= rs.getString("LineName") %></td>
            <td><%= rs.getTimestamp("Departure") %></td>
            <td><%= rs.getTimestamp("Arrival") %></td>
            <td><%= rs.getDouble("TotalFare") %></td>
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
    <form action="AddTrainSchedule.jsp" method="GET">
        <button type="submit">Add New Train Schedule</button>
    </form>
    <br>

    <!-- Manage Conversations Section -->
    <h3>Open Questions</h3>
    <form method="GET">
        <label for="search">Search:</label>
        <input type="text" id="search" name="search" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
        <button type="submit">Search</button>
        <button type="button" onclick="location.href='CustomerRepresentative.jsp';">Clear</button>
    </form>

    <table border="1">
        <tr>
            <th>Conversation ID</th>
            <th>Customer Name</th>
            <th>Subject</th>
            <th>Latest Reply</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
        <%
            String searchKeyword = request.getParameter("search");
            String convQuery = "SELECT c.ConversationID, cu.FirstName AS CustomerName, cu.LastName AS CustomerLastName, " +
                           "(SELECT m.Message FROM Messages m WHERE m.ConversationID = c.ConversationID ORDER BY m.Timestamp ASC LIMIT 1) AS Subject, " +
                           "(SELECT m.Message FROM Messages m WHERE m.ConversationID = c.ConversationID ORDER BY m.Timestamp DESC LIMIT 1) AS LatestReply, " +
                           "c.Status " +
                           "FROM Conversations c " +
                           "JOIN Customers cu ON c.CustomerID = cu.CustomerID " +
                           "WHERE c.Status = 'open'";

            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                convQuery += " AND (cu.FirstName LIKE '%" + searchKeyword + "%' " +
                         "OR cu.LastName LIKE '%" + searchKeyword + "%' " +
                         "OR (SELECT m.Message FROM Messages m WHERE m.ConversationID = c.ConversationID ORDER BY m.Timestamp ASC LIMIT 1) LIKE '%" + searchKeyword + "%')";
            }

            try (Statement stmt = con.createStatement()) {
                ResultSet rs = stmt.executeQuery(convQuery);

                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("ConversationID") %></td>
            <td><%= rs.getString("CustomerName") + " " + rs.getString("CustomerLastName") %></td>
            <td><%= rs.getString("Subject") != null ? rs.getString("Subject") : "No messages yet" %></td>
            <td><%= rs.getString("LatestReply") != null ? rs.getString("LatestReply") : "No replies yet" %></td>
            <td><%= rs.getString("Status") %></td>
            <td>
                <form action="ViewConversation.jsp" method="GET" style="display:inline;">
                    <input type="hidden" name="conversationID" value="<%= rs.getInt("ConversationID") %>">
                    <button type="submit">View</button>
                </form>
                <form action="CloseConversation.jsp" method="POST" style="display:inline;">
                    <input type="hidden" name="conversationID" value="<%= rs.getInt("ConversationID") %>">
                    <button type="submit">Close</button>
                </form>
            </td>
        </tr>
        <%
                }
            } catch (SQLException e) {
                out.println("<p>Error fetching conversations: " + e.getMessage() + "</p>");
            }
        %>
    </table>
    <br>

    <!-- Other Actions -->
<h3>Other Actions</h3>
<form action="ViewCustomersWithReservations.jsp" method="GET">
    <button type="submit">View Customers with Reservations</button>
</form>

</body>
</html>
