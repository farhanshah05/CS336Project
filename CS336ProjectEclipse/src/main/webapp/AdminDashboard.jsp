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
<title>Admin Dashboard</title>
</head>
<body>

	<h1>Welcome, <%= user %>!</h1>
    <h2>Admin Dashboard</h2>

<form action="Logout.jsp" method="GET" style="margin-top: 20px;">
    <button type="submit">Logout</button>
</form><br><br>
    
    <form action="AdminEmployeeManager.jsp" method="GET" style="display:inline;">
        <button type="submit">Manage Customer Representatives</button>
    </form>
    
    <form action="AdminSalesReport.jsp" method="GET" style="display:inline;">
        <button type="submit">Monthly Sales Reports</button>
    </form>
    
    <form action="AdminReservationList.jsp" method="GET" style="display:inline;">
        <button type="submit">List of Reservations</button>
    </form>
    
    <form action="AdminRevenueList.jsp" method="GET" style="display:inline;">
        <button type="submit">List of Revenue</button>
    </form>
    
    <%
    // Query to find the best customer
    String bestCustomerQuery = "SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, " +
                               "COUNT(r.ReservationID) AS NumberOfReservations " +
                               "FROM Reservations r " +
                               "JOIN Customers c ON r.CustomerID = c.CustomerID " +
                               "GROUP BY c.CustomerID, c.FirstName, c.LastName " +
                               "ORDER BY NumberOfReservations DESC " +
                               "LIMIT 1";

    String bestCustomerName = "No customer data available";
    int bestCustomerReservations = 0;

    try (Statement stmt = con.createStatement()) {
        ResultSet rs = stmt.executeQuery(bestCustomerQuery);

        if (rs.next()) {
            bestCustomerName = rs.getString("CustomerName");
            bestCustomerReservations = rs.getInt("NumberOfReservations");
        }
    } catch (SQLException e) {
        out.println("<p>Error fetching the best customer: " + e.getMessage() + "</p>");
    }
%>

	<h3>Best Customer!</h3>
	<div style="padding: 10px; border: 2px solid #4CAF50; background-color: #e8f5e9; display: inline-block;">
	    <h2 style="color: #4CAF50; margin: 0; font-size: 1.5em; font-weight: bold;">
	        <%= bestCustomerName %>
	    </h2>
	    <p style="margin: 0; font-size: 1.2em;">Reservations: <strong><%= bestCustomerReservations %></strong></p>
	</div>

    
    <h3>Most Popular Train Lines</h3>
    
    <table border="1">
    <tr>
        <th>Transit Line</th>
        <th>Number of Reservations</th>
    </tr>
    <%
        // SQL query to fetch the 5 most active transit lines
        String query = "SELECT tl.LineName AS TransitLine, " +
                       "COUNT(r.ReservationID) AS NumberOfReservations " +
                       "FROM Reservations r " +
                       "JOIN TransitLines tl ON r.LineID = tl.LineID " +
                       "GROUP BY tl.LineName " +
                       "ORDER BY NumberOfReservations DESC " +
                       "LIMIT 5";

        try (Statement stmt = con.createStatement()) {
            ResultSet rs = stmt.executeQuery(query);

            while (rs.next()) {
    %>
    <tr>
        <td><%= rs.getString("TransitLine") %></td>
        <td><%= rs.getInt("NumberOfReservations") %></td>
    </tr>
    <%
            }
        } catch (SQLException e) {
            out.println("<p>Error fetching most active transit lines: " + e.getMessage() + "</p>");
        }
    %>
</table>
   

</body>
</html>
