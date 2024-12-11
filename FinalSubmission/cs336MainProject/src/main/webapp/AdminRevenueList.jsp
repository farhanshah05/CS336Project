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
<title>Admin Revenue List</title>
<style>
.top-right {
	position: absolute;
	top: 10px;
	right: 10px;
}
</style>
</head>
<body>
	<h1>Revenue Listing</h1>

	<form action="AdminDashboard.jsp" method="GET">
		<button type="submit" class="top-right">Back to Admin
			Dashboard</button>
	</form>
	<br>

	<!-- Table for Revenue by Transit Line -->
	<h2>Revenue by Transit Line</h2>
	<table border="1">
		<tr>
			<th>Transit Line</th>
			<th>Total Revenue ($)</th>
		</tr>
		<%
		String queryByTransitLine = "SELECT tl.LineName AS TransitLine, SUM(r.TotalFare) AS TotalRevenue "
				+ "FROM Reservations r " + "JOIN TransitLines tl ON r.LineID = tl.LineID " + "GROUP BY tl.LineName "
				+ "ORDER BY TotalRevenue DESC";

		try (Statement stmt = con.createStatement()) {
			ResultSet rs = stmt.executeQuery(queryByTransitLine);

			while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getString("TransitLine")%></td>
			<td><%=rs.getDouble("TotalRevenue")%></td>
		</tr>
		<%
		}
		} catch (SQLException e) {
		out.println("<p>Error fetching revenue by transit line: " + e.getMessage() + "</p>");
		}
		%>
	</table>

	<!-- Table for Revenue by Customer Name -->
	<h2>Revenue by Customer Name</h2>
	<table border="1">
		<tr>
			<th>Customer Name</th>
			<th>Total Revenue ($)</th>
		</tr>
		<%
		String queryByCustomerName = "SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, SUM(r.TotalFare) AS TotalRevenue "
				+ "FROM Reservations r " + "JOIN Customers c ON r.CustomerID = c.CustomerID "
				+ "GROUP BY c.CustomerID, c.FirstName, c.LastName " + "ORDER BY TotalRevenue DESC";

		try (Statement stmt = con.createStatement()) {
			ResultSet rs = stmt.executeQuery(queryByCustomerName);

			while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getString("CustomerName")%></td>
			<td><%=rs.getDouble("TotalRevenue")%></td>
		</tr>
		<%
		}
		} catch (SQLException e) {
		out.println("<p>Error fetching revenue by customer name: " + e.getMessage() + "</p>");
		}
		%>
	</table>
</body>
</html>