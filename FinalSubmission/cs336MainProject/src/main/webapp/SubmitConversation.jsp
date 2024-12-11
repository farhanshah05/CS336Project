<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
<title>Submit Conversation</title>
</head>
<body>
	<h1>Submit Conversation</h1>
	<%
	// Ensure the user is logged in as a customer
	String user = (String) session.getAttribute("user");
	String role = (String) session.getAttribute("role");

	if (user == null || !"customer".equals(role)) {
		response.sendRedirect("Login.jsp"); // Redirect unauthorized users to login page
		return;
	}

	ApplicationDB db = new ApplicationDB();
	Connection con = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
		// Get customer details from session
		con = db.getConnection();
		pstmt = con.prepareStatement("SELECT CustomerID FROM Customers WHERE Username = ?");
		pstmt.setString(1, user);
		rs = pstmt.executeQuery();

		if (!rs.next()) {
			throw new Exception("Customer not found.");
		}

		int customerID = rs.getInt("CustomerID");
		String message = request.getParameter("message");

		// Assign the first available employee for simplicity
		pstmt = con.prepareStatement("SELECT EmployeeID FROM Employees LIMIT 1");
		rs = pstmt.executeQuery();

		if (!rs.next()) {
			throw new Exception("No available employees.");
		}

		int employeeID = rs.getInt("EmployeeID");

		// Step 1: Insert a new conversation
		pstmt = con.prepareStatement("INSERT INTO Conversations (CustomerID, EmployeeID, Status) VALUES (?, ?, 'open')",
		Statement.RETURN_GENERATED_KEYS);
		pstmt.setInt(1, customerID);
		pstmt.setInt(2, employeeID);
		pstmt.executeUpdate();

		rs = pstmt.getGeneratedKeys();
		if (!rs.next()) {
			throw new Exception("Failed to create a new conversation.");
		}

		int conversationID = rs.getInt(1); // Get the generated ConversationID

		// Step 2: Insert the initial message
		pstmt = con.prepareStatement(
		"INSERT INTO Messages (ConversationID, SenderID, ReceiverID, Message) VALUES (?, ?, ?, ?)");
		pstmt.setInt(1, conversationID);
		pstmt.setInt(2, customerID); // Sender is the customer
		pstmt.setInt(3, employeeID); // Receiver is the employee
		pstmt.setString(4, message);
		pstmt.executeUpdate();

		// Success
		out.println("<p>Conversation started successfully! An employee will assist you shortly.</p>");
		out.println("<button onclick=\"location.href='CustomerDashboard.jsp';\">Back to Dashboard</button>");
	} catch (Exception e) {
		out.println("<p>Error: " + e.getMessage() + "</p>");
		out.println("<button onclick=\"location.href='CustomerDashboard.jsp';\">Back to Dashboard</button>");
	} finally {
		if (rs != null)
			try {
		rs.close();
			} catch (SQLException ignored) {
			}
		if (pstmt != null)
			try {
		pstmt.close();
			} catch (SQLException ignored) {
			}
		if (con != null)
			try {
		con.close();
			} catch (SQLException ignored) {
			}
	}
	%>
</body>
</html>