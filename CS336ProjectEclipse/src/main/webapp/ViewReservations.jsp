<%@ page import="java.sql.*, java.util.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<html>
<head>
<title>View and Cancel Reservations</title>
<script>
	function cancelReservation(reservationID) {
		const xhr = new XMLHttpRequest();
		xhr.open("POST", "ViewReservations.jsp", true);
		xhr.setRequestHeader("Content-type",
				"application/x-www-form-urlencoded");
		xhr.onreadystatechange = function() {
			if (xhr.readyState === XMLHttpRequest.DONE) {
				if (xhr.status === 200) {
					location.reload(); // Reload the page to show updated reservations
				} else {
					alert("Failed to cancel reservation. Please try again.");
				}
			}
		};
		xhr.send("action=cancel&reservationID=" + reservationID);
	}
</script>
</head>
<body>
	<div style="text-align: right;">
		<a href="Success.jsp">Home</a>
	</div>
	<h1>Your Reservations</h1>

	<%
	// Retrieve the logged-in user's CustomerID from session
	String username = (String) session.getAttribute("user");
	if (username == null) {
		out.println("<p>Please <a href='Login.jsp'>log in</a> to view your reservations.</p>");
		return;
	}

	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();

	try {
		// Get CustomerID for the logged-in username
		PreparedStatement psCustomer = con.prepareStatement("SELECT CustomerID FROM Customers WHERE Username = ?");
		psCustomer.setString(1, username);
		ResultSet rsCustomer = psCustomer.executeQuery();
		int customerID = 0;
		if (rsCustomer.next()) {
			customerID = rsCustomer.getInt("CustomerID");
		}
		rsCustomer.close();
		psCustomer.close();

		if (customerID == 0) {
			out.println("<p>Unable to find your customer details. Please contact support.</p>");
			return;
		}

		// Handle reservation cancellation
		if ("cancel".equals(request.getParameter("action"))) {
			String reservationID = request.getParameter("reservationID");
			if (reservationID != null) {
		PreparedStatement psCancel = con
				.prepareStatement("DELETE FROM Reservations WHERE ReservationID = ? AND CustomerID = ?");
		psCancel.setInt(1, Integer.parseInt(reservationID));
		psCancel.setInt(2, customerID);
		int rowsAffected = psCancel.executeUpdate();
		psCancel.close();

		if (rowsAffected > 0) {
			response.setStatus(HttpServletResponse.SC_OK);
		} else {
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
		return; // Stop further processing for AJAX requests
			}
		}

		// Fetch and display Current Reservations
		out.println("<h2>Current Reservations</h2>");
		PreparedStatement psCurrent = con
		.prepareStatement("SELECT r.ReservationID, tl.LineName, t.TrainName, s1.StationName AS OriginStationName, "
				+ "s2.StationName AS DestinationStationName, r.DepartureDateTime, r.TotalFare "
				+ "FROM Reservations r " + "JOIN TransitLines tl ON r.LineID = tl.LineID "
				+ "JOIN Trains t ON tl.TrainID = t.TrainID "
				+ "JOIN Stations s1 ON r.OriginStationID = s1.StationID "
				+ "JOIN Stations s2 ON r.DestinationStationID = s2.StationID "
				+ "WHERE r.CustomerID = ? AND r.ReservationStatus = 'Current' AND r.DepartureDateTime >= NOW() "
				+ "ORDER BY r.DepartureDateTime ASC");
		psCurrent.setInt(1, customerID);
		ResultSet rsCurrent = psCurrent.executeQuery();

		if (!rsCurrent.isBeforeFirst()) {
			out.println("<p>No current reservations found.</p>");
		} else {
			out.println("<table border='1'>");
			out.println(
			"<tr><th>Reservation ID</th><th>Line Name</th><th>Train Name</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Total Fare</th><th>Cancel</th></tr>");
			while (rsCurrent.next()) {
		int reservationID = rsCurrent.getInt("ReservationID");
		out.println("<tr id='reservation-row-" + reservationID + "'>");
		out.println("<td>" + reservationID + "</td>");
		out.println("<td>" + rsCurrent.getString("LineName") + "</td>");
		out.println("<td>" + rsCurrent.getString("TrainName") + "</td>");
		out.println("<td>" + rsCurrent.getString("OriginStationName") + "</td>");
		out.println("<td>" + rsCurrent.getString("DestinationStationName") + "</td>");
		out.println("<td>" + rsCurrent.getTimestamp("DepartureDateTime") + "</td>");
		out.println("<td>$" + rsCurrent.getDouble("TotalFare") + "</td>");
		out.println("<td><button onclick='cancelReservation(" + reservationID + ")'>Cancel</button></td>");
		out.println("</tr>");
			}
			out.println("</table>");
		}
		rsCurrent.close();
		psCurrent.close();

		// Fetch and display Past Reservations
		out.println("<h2>Past Reservations</h2>");
		PreparedStatement psPast = con
		.prepareStatement("SELECT r.ReservationID, tl.LineName, t.TrainName, s1.StationName AS OriginStationName, "
				+ "s2.StationName AS DestinationStationName, r.DepartureDateTime, r.TotalFare "
				+ "FROM Reservations r " + "JOIN TransitLines tl ON r.LineID = tl.LineID "
				+ "JOIN Trains t ON tl.TrainID = t.TrainID "
				+ "JOIN Stations s1 ON r.OriginStationID = s1.StationID "
				+ "JOIN Stations s2 ON r.DestinationStationID = s2.StationID "
				+ "WHERE r.CustomerID = ? AND r.ReservationStatus = 'Past' AND r.DepartureDateTime < NOW() "
				+ "ORDER BY r.DepartureDateTime DESC");
		psPast.setInt(1, customerID);
		ResultSet rsPast = psPast.executeQuery();

		if (!rsPast.isBeforeFirst()) {
			out.println("<p>No past reservations found.</p>");
		} else {
			out.println("<table border='1'>");
			out.println(
			"<tr><th>Reservation ID</th><th>Line Name</th><th>Train Name</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Total Fare</th></tr>");
			while (rsPast.next()) {
		out.println("<tr>");
		out.println("<td>" + rsPast.getInt("ReservationID") + "</td>");
		out.println("<td>" + rsPast.getString("LineName") + "</td>");
		out.println("<td>" + rsPast.getString("TrainName") + "</td>");
		out.println("<td>" + rsPast.getString("OriginStationName") + "</td>");
		out.println("<td>" + rsPast.getString("DestinationStationName") + "</td>");
		out.println("<td>" + rsPast.getTimestamp("DepartureDateTime") + "</td>");
		out.println("<td>$" + rsPast.getDouble("TotalFare") + "</td>");
		out.println("</tr>");
			}
			out.println("</table>");
		}
		rsPast.close();
		psPast.close();

	} catch (SQLException e) {
		out.println("<p>An error occurred. Please try again later.</p>");
		e.printStackTrace(new java.io.PrintWriter(out));
	} finally {
		db.closeConnection(con);
	}
	%>
</body>
</html>


