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
<title>Admin Reservation List</title>
<style>
.top-right {
	position: absolute;
	top: 10px;
	right: 10px;
}
</style>
</head>
<body>
	<h1>Reservation List</h1>

	<form action="AdminDashboard.jsp" method="GET">
		<button type="submit" class="top-right">Back to Admin
			Dashboard</button>
	</form>
	<br>

	<!-- Table by Transit Line -->
	<h2>Reservations by Transit Line</h2>
	<table border="1">
		<tr>
			<th>Transit Line</th>
			<th>Reservation ID</th>
			<th>Customer Name</th>
			<th>Departure</th>
			<th>Destination</th>
		</tr>
		<%
		String queryByTransitLine = "SELECT tl.LineName AS TransitLine, r.ReservationID, "
				+ "CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, "
				+ "s1.StationName AS Departure, s2.StationName AS Destination " + "FROM Reservations r "
				+ "JOIN TransitLines tl ON r.LineID = tl.LineID " + "JOIN Customers c ON r.CustomerID = c.CustomerID "
				+ "JOIN Stations s1 ON r.OriginStationID = s1.StationID "
				+ "JOIN Stations s2 ON r.DestinationStationID = s2.StationID " + "ORDER BY tl.LineName";

		try (Statement stmt = con.createStatement()) {
			ResultSet rs = stmt.executeQuery(queryByTransitLine);

			while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getString("TransitLine")%></td>
			<td><%=rs.getInt("ReservationID")%></td>
			<td><%=rs.getString("CustomerName")%></td>
			<td><%=rs.getString("Departure")%></td>
			<td><%=rs.getString("Destination")%></td>
		</tr>
		<%
		}
		} catch (SQLException e) {
		out.println("<p>Error fetching reservations by transit line: " + e.getMessage() + "</p>");
		}
		%>
	</table>

	<h2>Reservations by Customer Name</h2>
	<!-- Table by Customer Name -->
	<table border="1">
		<tr>
			<th>Customer Name</th>
			<th>Reservation ID</th>
			<th>Transit Line</th>
			<th>Departure</th>
			<th>Destination</th>
		</tr>
		<%
		String queryByCustomerName = "SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, r.ReservationID, "
				+ "tl.LineName AS TransitLine, s1.StationName AS Departure, s2.StationName AS Destination "
				+ "FROM Reservations r " + "JOIN Customers c ON r.CustomerID = c.CustomerID "
				+ "JOIN TransitLines tl ON r.LineID = tl.LineID " + "JOIN Stations s1 ON r.OriginStationID = s1.StationID "
				+ "JOIN Stations s2 ON r.DestinationStationID = s2.StationID " + "ORDER BY CustomerName";

		try (Statement stmt = con.createStatement()) {
			ResultSet rs = stmt.executeQuery(queryByCustomerName);

			while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getString("CustomerName")%></td>
			<td><%=rs.getInt("ReservationID")%></td>
			<td><%=rs.getString("TransitLine")%></td>
			<td><%=rs.getString("Departure")%></td>
			<td><%=rs.getString("Destination")%></td>
		</tr>
		<%
		}
		} catch (SQLException e) {
		out.println("<p>Error fetching reservations by customer name: " + e.getMessage() + "</p>");
		}
		%>
	</table>


</body>
</html>