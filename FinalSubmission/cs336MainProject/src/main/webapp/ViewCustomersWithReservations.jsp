<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
<title>View Customers with Reservations</title>
<script>
	function toggleSearchFields(mode) {
		document.getElementById("searchByLine").style.display = mode === "line" ? "block"
				: "none";
		document.getElementById("searchByOriginDestination").style.display = mode === "originDestination" ? "block"
				: "none";
		document.getElementById("searchMode").value = mode;
	}
</script>
</head>
<body>
	<h1>View Customers with Reservations</h1>

	<!-- Buttons to Toggle Search Modes -->
	<div>
		<button type="button" onclick="toggleSearchFields('line')">Search
			by Transit Line</button>
		<button type="button"
			onclick="toggleSearchFields('originDestination')">Search by
			Origin and Destination</button>
	</div>

	<!-- Search Form -->
	<form method="GET">
		<input type="hidden" id="searchMode" name="searchMode" value="line">

		<!-- Search by Transit Line -->
		<div id="searchByLine" style="display: block;">
			<label for="lineID">Select Transit Line:</label> <select id="lineID"
				name="lineID">
				<option value="">-- Select Line --</option>
				<%
				Connection con = null;
				ApplicationDB db = new ApplicationDB();
				try {
					con = db.getConnection();
					Statement stmt = con.createStatement();
					ResultSet rs = stmt.executeQuery("SELECT LineID, LineName FROM TransitLines");

					while (rs.next()) {
				%>
				<option value="<%=rs.getInt("LineID")%>"
					<%=request.getParameter("lineID") != null
		&& request.getParameter("lineID").equals(String.valueOf(rs.getInt("LineID"))) ? "selected" : ""%>>
					<%=rs.getString("LineName")%>
				</option>
				<%
				}
				} catch (SQLException e) {
				out.println("<p>Error loading transit lines: " + e.getMessage() + "</p>");
				} finally {
				if (con != null)
				try {
					con.close();
				} catch (SQLException ignored) {
				}
				}
				%>
			</select>
		</div>

		<!-- Search by Origin and Destination -->
		<div id="searchByOriginDestination" style="display: none;">
			<label for="originStation">Select Origin Station:</label> <select
				id="originStation" name="originStation">
				<option value="">-- Select Station --</option>
				<%
				try {
					con = db.getConnection();
					Statement stmt = con.createStatement();
					ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");

					while (rs.next()) {
				%>
				<option value="<%=rs.getInt("StationID")%>"
					<%=request.getParameter("originStation") != null
		&& request.getParameter("originStation").equals(String.valueOf(rs.getInt("StationID"))) ? "selected" : ""%>>
					<%=rs.getString("StationName")%>
				</option>
				<%
				}
				} catch (SQLException e) {
				out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
				} finally {
				if (con != null)
				try {
					con.close();
				} catch (SQLException ignored) {
				}
				}
				%>
			</select> <label for="destinationStation">Select Destination Station:</label>
			<select id="destinationStation" name="destinationStation">
				<option value="">-- Select Station --</option>
				<%
				try {
					con = db.getConnection();
					Statement stmt = con.createStatement();
					ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");

					while (rs.next()) {
				%>
				<option value="<%=rs.getInt("StationID")%>"
					<%=request.getParameter("destinationStation") != null
		&& request.getParameter("destinationStation").equals(String.valueOf(rs.getInt("StationID"))) ? "selected" : ""%>>
					<%=rs.getString("StationName")%>
				</option>
				<%
				}
				} catch (SQLException e) {
				out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
				} finally {
				if (con != null)
				try {
					con.close();
				} catch (SQLException ignored) {
				}
				}
				%>
			</select>
		</div>

		<!-- Reservation Date -->
		<label for="reservationDate">Select Reservation Date:</label> <select
			id="reservationDate" name="reservationDate">
			<option value="">-- Select Date --</option>
			<%
			try {
				con = db.getConnection();
				Statement stmt = con.createStatement();
				ResultSet rs = stmt.executeQuery(
				"SELECT DISTINCT DATE(DepartureDateTime) AS ReservationDate FROM Reservations ORDER BY ReservationDate");

				while (rs.next()) {
			%>
			<option value="<%=rs.getString("ReservationDate")%>"
				<%=request.getParameter("reservationDate") != null
		&& request.getParameter("reservationDate").equals(rs.getString("ReservationDate")) ? "selected" : ""%>>
				<%=rs.getString("ReservationDate")%>
			</option>
			<%
			}
			} catch (SQLException e) {
			out.println("<p>Error loading reservation dates: " + e.getMessage() + "</p>");
			} finally {
			if (con != null)
			try {
				con.close();
			} catch (SQLException ignored) {
			}
			}
			%>
		</select>

		<button type="submit">Search</button>
	</form>

	<!-- Results Table -->
	<h2>Results:</h2>
	<table border="1">
		<tr>
			<th>Customer Name</th>
			<th>Transit Line</th>
			<th>Origin Station</th>
			<th>Destination Station</th>
			<th>Departure Date & Time</th>
			<th>Total Fare</th>
		</tr>
		<%
		String searchMode = request.getParameter("searchMode");
		String lineID = request.getParameter("lineID");
		String reservationDate = request.getParameter("reservationDate");
		String originStation = request.getParameter("originStation");
		String destinationStation = request.getParameter("destinationStation");

		try {
			con = db.getConnection();
			String query = "SELECT r.ReservationID, c.FirstName, c.LastName, tl.LineName, s1.StationName AS OriginStation, "
			+ "s2.StationName AS DestinationStation, r.DepartureDateTime, r.TotalFare " + "FROM Reservations r "
			+ "JOIN Customers c ON r.CustomerID = c.CustomerID " + "LEFT JOIN TransitLines tl ON r.LineID = tl.LineID "
			+ "LEFT JOIN Stations s1 ON r.OriginStationID = s1.StationID "
			+ "LEFT JOIN Stations s2 ON r.DestinationStationID = s2.StationID " + "WHERE 1=1 ";

			if (reservationDate != null && !reservationDate.isEmpty()) {
				query += "AND DATE(r.DepartureDateTime) = ? ";
			}
			if ("line".equals(searchMode) && lineID != null && !lineID.isEmpty()) {
				query += "AND r.LineID = ? ";
			}
			if ("originDestination".equals(searchMode)) {
				if (originStation != null && !originStation.isEmpty())
			query += "AND r.OriginStationID = ? ";
				if (destinationStation != null && !destinationStation.isEmpty())
			query += "AND r.DestinationStationID = ? ";
			}

			PreparedStatement pstmt = con.prepareStatement(query);

			int paramIndex = 1;
			if (reservationDate != null && !reservationDate.isEmpty())
				pstmt.setString(paramIndex++, reservationDate);
			if ("line".equals(searchMode) && lineID != null && !lineID.isEmpty())
				pstmt.setInt(paramIndex++, Integer.parseInt(lineID));
			if ("originDestination".equals(searchMode)) {
				if (originStation != null && !originStation.isEmpty())
			pstmt.setInt(paramIndex++, Integer.parseInt(originStation));
				if (destinationStation != null && !destinationStation.isEmpty())
			pstmt.setInt(paramIndex++, Integer.parseInt(destinationStation));
			}

			ResultSet rs = pstmt.executeQuery();

			boolean hasResults = false;
			while (rs.next()) {
				hasResults = true;
		%>
		<tr>
			<td><%=rs.getString("FirstName") + " " + rs.getString("LastName")%></td>
			<td><%=rs.getString("LineName") != null ? rs.getString("LineName") : "N/A"%></td>
			<td><%=rs.getString("OriginStation")%></td>
			<td><%=rs.getString("DestinationStation")%></td>
			<td><%=rs.getTimestamp("DepartureDateTime")%></td>
			<td><%=rs.getBigDecimal("TotalFare")%></td>
		</tr>
		<%
		}
		if (!hasResults) {
		out.println("<tr><td colspan='6'>No results found for the selected criteria.</td></tr>");
		}
		} catch (SQLException e) {
		out.println("<p>Error retrieving reservations: " + e.getMessage() + "</p>");
		} finally {
		if (con != null)
		try {
			con.close();
		} catch (SQLException ignored) {
		}
		}
		%>
	</table>

	<!-- Back Button -->
	<div>
		<button type="button"
			onclick="window.location.href='CustomerRepresentative.jsp'">Back</button>
	</div>
</body>
</html>