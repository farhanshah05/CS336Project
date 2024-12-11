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
%>
<html>
<head>
<meta charset="UTF-8">
<title>Admin Employee Manager</title>
<style>
.top-right {
	position: absolute;
	top: 10px;
	right: 10px;
}
</style>
</head>
<body>

	<h1>
		Welcome,
		<%=user%>!
	</h1>
	<h2>Manage Customer Representatives</h2>

	<form action="AdminDashboard.jsp" method="GET">
		<button type="submit" class="top-right">Back to Admin
			Dashboard</button>
	</form>

	<%
	// Database connection setup
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();

	// Handle Delete Request
	String deleteID = request.getParameter("deleteID");
	if (deleteID != null) {
		String deleteQuery = "DELETE FROM Employees WHERE EmployeeID = ?";
		try (PreparedStatement pstmt = con.prepareStatement(deleteQuery)) {
			pstmt.setInt(1, Integer.parseInt(deleteID));
			pstmt.executeUpdate();
			out.println("<p>Representative deleted successfully!</p>");
		} catch (SQLException e) {
			out.println("<p>Error deleting representative: " + e.getMessage() + "</p>");
		}
	}

	// Handle Add Request
	if (request.getParameter("add") != null) {
		String firstName = request.getParameter("firstName");
		String lastName = request.getParameter("lastName");
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String ssn = request.getParameter("ssn");

		String addQuery = "INSERT INTO Employees (FirstName, LastName, Username, Password, SSN) VALUES (?, ?, ?, ?, ?)";
		try (PreparedStatement pstmt = con.prepareStatement(addQuery)) {
			pstmt.setString(1, firstName);
			pstmt.setString(2, lastName);
			pstmt.setString(3, username);
			pstmt.setString(4, password);
			pstmt.setString(5, ssn);
			pstmt.executeUpdate();
			out.println("<p>Representative added successfully!</p>");
		} catch (SQLException e) {
			out.println("<p>Error adding representative: " + e.getMessage() + "</p>");
		}
	}

	if (request.getParameter("editID") != null) {
		String editID = request.getParameter("editID");
		String firstName = request.getParameter("editFirstName");
		String lastName = request.getParameter("editLastName");
		String username = request.getParameter("editUsername");
		String password = request.getParameter("editPassword");
		String ssn = request.getParameter("editSSN");

		// Base query without SSN
		String updateQuery = "UPDATE Employees SET FirstName = ?, LastName = ?, Username = ?, Password = ?";

		// Check if SSN is provided
		if (ssn != null && !ssn.trim().isEmpty()) {
			updateQuery += ", SSN = ?";
		}
		updateQuery += " WHERE EmployeeID = ?";

		try (PreparedStatement pstmt = con.prepareStatement(updateQuery)) {
			pstmt.setString(1, firstName);
			pstmt.setString(2, lastName);
			pstmt.setString(3, username);
			pstmt.setString(4, password);

			int paramIndex = 5; // Start at the fifth parameter
			if (ssn != null && !ssn.trim().isEmpty()) {
		pstmt.setString(paramIndex++, ssn); // Add SSN if provided
			}
			pstmt.setInt(paramIndex, Integer.parseInt(editID)); // Employee ID

			pstmt.executeUpdate();
			out.println("<p>Representative updated successfully!</p>");
		} catch (SQLException e) {
			out.println("<p>Error updating representative: " + e.getMessage() + "</p>");
		}
	}
	%>

	<table border="1">
		<tr>
			<th>Employee ID</th>
			<th>First Name</th>
			<th>Last Name</th>
			<th>Username</th>
			<th>Actions</th>
		</tr>
		<%
		String query = "SELECT EmployeeID, FirstName, LastName, Username FROM Employees";
		try (Statement stmt = con.createStatement()) {
			ResultSet rs = stmt.executeQuery(query);

			while (rs.next()) {
		%>
		<tr>
			<td><%=rs.getInt("EmployeeID")%></td>
			<td><%=rs.getString("FirstName")%></td>
			<td><%=rs.getString("LastName")%></td>
			<td><%=rs.getString("Username")%></td>
			<td>
				<!-- Edit button -->
				<form method="POST" action="">
					<input type="hidden" name="editID"
						value="<%=rs.getInt("EmployeeID")%>">
					<!-- First Name and Last Name on the same line -->
					First Name: <input type="text" name="editFirstName"
						value="<%=rs.getString("FirstName")%>"> Last Name: <input
						type="text" name="editLastName"
						value="<%=rs.getString("LastName")%>"><br>
					<!-- Username and Password on the same line -->
					Username: <input type="text" name="editUsername"
						value="<%=rs.getString("Username")%>"> Password: <input
						type="password" name="editPassword"><br> SSN: <input
						type="text" name="editSSN" placeholder="Enter new SSN (if needed)"><br>
					<button type="submit">Save Changes</button>
				</form> <br> <!-- Delete button -->
				<form method="POST" action="">
					<input type="hidden" name="deleteID"
						value="<%=rs.getInt("EmployeeID")%>">
					<button type="submit"
						onclick="return confirm('Are you sure you want to delete this representative?')">Delete
						Representative</button>
				</form>
			</td>
		</tr>
		<%
		}
		} catch (SQLException e) {
		out.println("<p>Error fetching representatives: " + e.getMessage() + "</p>");
		}
		%>
	</table>

	<h2>Add New Representative</h2>
	<form method="POST" action="">
		First Name: <input type="text" name="firstName" required> Last
		Name: <input type="text" name="lastName" required><br>
		Username: <input type="text" name="username" required>
		Password: <input type="password" name="password" required><br>
		SSN: <input type="text" name="ssn" placeholder="Enter SSN" required><br>
		<button type="submit" name="add">Add Representative</button>
	</form>



</body>
</html>