<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.sql.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
<title>Reserve a Train</title>
<style>
/* Styling for the Home link at the top right */
.home-link {
	position: absolute;
	top: 10px;
	right: 10px;
	font-size: 18px;
	font-weight: bold;
}
</style>
</head>
<body>
	<!-- Home Link -->
	<div class="home-link">
		<a href="Success.jsp">Home</a>
	</div>

	<h1>Reserve a Train</h1>
	<%
	String lineID = request.getParameter("lineID");
	String lineName = request.getParameter("lineName");
	String origin = request.getParameter("origin");
	String destination = request.getParameter("destination");
	String departure = request.getParameter("departure");
	String baseFare = request.getParameter("fare");

	if (lineID == null || lineName == null || origin == null || destination == null || departure == null
			|| baseFare == null) {
		out.println("<p>Invalid train schedule details. Please try again.</p>");
		return;
	}

	// Retrieve logged-in user's CustomerID from session
	String username = (String) session.getAttribute("user");
	if (username == null) {
		out.println("<p>Please <a href='Login.jsp'>log in</a> to make a reservation.</p>");
		return;
	}

	int customerID = 0;
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();

	try {
		// Fetch CustomerID
		PreparedStatement psCustomer = con.prepareStatement("SELECT CustomerID FROM Customers WHERE Username = ?");
		psCustomer.setString(1, username);
		ResultSet rsCustomer = psCustomer.executeQuery();
		if (rsCustomer.next()) {
			customerID = rsCustomer.getInt("CustomerID");
		}
		rsCustomer.close();
		psCustomer.close();

		if (customerID == 0) {
			out.println("<p>Unable to find customer details. Please contact support.</p>");
			return;
		}

		// Check if the form is submitted
		if ("POST".equalsIgnoreCase(request.getMethod())) {
			String ticketType = request.getParameter("ticketType");
			String discountType = request.getParameter("discountType");

			double fare = Double.parseDouble(baseFare);
			// Apply ticket type multiplier
			if ("Round-Trip".equalsIgnoreCase(ticketType)) {
		fare *= 2; // Double the fare for round-trip
			}
			// Apply discount based on type
			if ("Child".equalsIgnoreCase(discountType)) {
		fare *= 0.75; // 25% discount
			} else if ("Senior".equalsIgnoreCase(discountType)) {
		fare *= 0.65; // 35% discount
			} else if ("Disabled".equalsIgnoreCase(discountType)) {
		fare *= 0.50; // 50% discount
			}

			// Insert reservation into database
			PreparedStatement psReservation = con.prepareStatement(
			"INSERT INTO Reservations (CustomerID, LineID, OriginStationID, DestinationStationID, DepartureDateTime, ReservationDate, TotalFare, ReservationStatus) "
					+ "VALUES (?, ?, (SELECT StationID FROM Stations WHERE StationName = ?), (SELECT StationID FROM Stations WHERE StationName = ?), ?, CURDATE(), ?, 'Current')");
			psReservation.setInt(1, customerID);
			psReservation.setInt(2, Integer.parseInt(lineID));
			psReservation.setString(3, origin);
			psReservation.setString(4, destination);
			psReservation.setString(5, departure);
			psReservation.setDouble(6, fare);

			int rowsInserted = psReservation.executeUpdate();
			psReservation.close();

			if (rowsInserted > 0) {
		out.println("<p>Reservation confirmed successfully!</p>");
		out.println("<p>Fare: $" + String.format("%.2f", fare) + "</p>");
		out.println("<p><a href='ViewReservations.jsp'>View Reservations</a></p>");
			} else {
		out.println("<p>Failed to confirm reservation. Please try again.</p>");
			}

			db.closeConnection(con);
			return;
		}

	} catch (SQLException e) {
		out.println("<p>An error occurred. Please try again later.</p>");
		e.printStackTrace(new java.io.PrintWriter(out));
		return;
	} finally {
		db.closeConnection(con);
	}
	%>

	<!-- Display Train Details -->
	<form method="post" action="ReserveTrain.jsp">
		<table border="1">
			<tr>
				<th>Line Name</th>
				<th>Origin</th>
				<th>Destination</th>
				<th>Departure</th>
				<th>Base Fare</th>
			</tr>
			<tr>
				<td><%=lineName%></td>
				<td><%=origin%></td>
				<td><%=destination%></td>
				<td><%=departure%></td>
				<td>$<%=baseFare%></td>
			</tr>
		</table>

		<!-- Hidden Fields to Pass Data -->
		<input type="hidden" name="lineID" value="<%=lineID%>"> <input
			type="hidden" name="lineName" value="<%=lineName%>"> <input
			type="hidden" name="origin" value="<%=origin%>"> <input
			type="hidden" name="destination" value="<%=destination%>"> <input
			type="hidden" name="departure" value="<%=departure%>"> <input
			type="hidden" name="fare" value="<%=baseFare%>">

		<!-- Ticket Type -->
		<label for="ticketType">Ticket Type:</label> <select name="ticketType"
			id="ticketType">
			<option value="One-Way">One-Way</option>
			<option value="Round-Trip">Round-Trip</option>
		</select>

		<!-- Discount Type -->
		<label for="discountType">Discount Type:</label> <select
			name="discountType" id="discountType">
			<option value="Normal">Normal</option>
			<option value="Child">Child (25% Off)</option>
			<option value="Senior">Senior (35% Off)</option>
			<option value="Disabled">Disabled (50% Off)</option>
		</select> <br> <br>
		<button type="submit">Confirm Reservation</button>
	</form>
</body>
</html>
