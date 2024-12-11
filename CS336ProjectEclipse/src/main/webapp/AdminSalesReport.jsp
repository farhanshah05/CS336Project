<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<%
    // Retrieve session attributes
    String user = (String) session.getAttribute("user");
    String role = (String) session.getAttribute("role");

    // Ensure the user is logged in and has the 'admin' role
    if (user == null || !"admin".equals(role)) {
        response.sendRedirect("Login.jsp"); // Redirect unauthorized users to the login page
        return;
    }

    ApplicationDB db = new ApplicationDB();	
    Connection con = db.getConnection();
%>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Sales Report</title>
</head>
<body>

<h2>Monthly Sales Report</h2>

<form action="AdminDashboard.jsp" method="GET">
    <button type="submit">Back to Admin Dashboard</button>
</form> <br>

<table border="1">
    <tr>
        <th>Month</th>
        <th>Total Sales ($)</th>
        <th>Total Reservations</th>
    </tr>
    <%
        String query = "SELECT DATE_FORMAT(ReservationDate, '%Y-%m') AS Month, " +
                       "SUM(TotalFare) AS TotalSales, COUNT(ReservationID) AS TotalReservations " +
                       "FROM Reservations " +
                       "GROUP BY DATE_FORMAT(ReservationDate, '%Y-%m') " +
                       "ORDER BY Month ASC";

        try (Statement stmt = con.createStatement()) {
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
    %>
    <tr>
        <td><%= rs.getString("Month") %></td>
        <td><%= rs.getDouble("TotalSales") %></td>
        <td><%= rs.getInt("TotalReservations") %></td>
    </tr>
    <%
            }
        } catch (SQLException e) {
            out.println("<p>Error fetching sales report: " + e.getMessage() + "</p>");
        }
    %>
</table>

</body>
</html>