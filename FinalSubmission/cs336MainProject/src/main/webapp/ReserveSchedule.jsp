<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
<title>Reserve/View Train Schedules</title>
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
<script>
	// Function to update the dropdown options based on user selection
	function updateStationDropdowns() {
		const originStation = document.getElementById('originStation').value;
		const destinationStation = document
				.getElementById('destinationStation').value;
		const destinationOptions = document
				.getElementById('destinationStation').options;
		const originOptions = document.getElementById('originStation').options;

		// Optional: You can highlight or show some messages based on the selection
	}
</script>
</head>
<body>

	<div class="home-link">
		<a href="Success.jsp">Home</a>
	</div>

	<h1>Train Schedules</h1>

	<!-- Search by Transit Line -->
	<form method="GET">
		<h3>Search by Transit Line</h3>
		<label for="lineID">Select Transit Line:</label> <select id="lineID"
			name="lineID">
			<option value="">-- Select Line --</option>
			<%
			ApplicationDB db = new ApplicationDB();
			Connection con = null;
			try {
				con = db.getConnection();
				PreparedStatement psLines = con.prepareStatement("SELECT LineID, LineName FROM TransitLines");
				ResultSet rsLines = psLines.executeQuery();
				while (rsLines.next()) {
			%>
			<option value="<%=rsLines.getInt("LineID")%>"
				<%=request.getParameter("lineID") != null
		&& request.getParameter("lineID").equals(String.valueOf(rsLines.getInt("LineID"))) ? "selected" : ""%>>
				<%=rsLines.getString("LineName")%>
			</option>
			<%
			}
			rsLines.close();
			psLines.close();
			} catch (SQLException e) {
			out.println("<p>Error fetching transit lines: " + e.getMessage() + "</p>");
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

	<!-- Search by Origin and Destination -->
	<form method="GET">
		<h3>Search by Origin and Destination</h3>

		<!-- Origin Station Dropdown -->
		<label for="originStation">Select Origin Station:</label> <select
			id="originStation" name="originStation"
			onchange="updateStationDropdowns()">
			<option value="">-- Select Origin --</option>
			<%
			try {
				con = db.getConnection();
				PreparedStatement psStations = con.prepareStatement("SELECT StationID, StationName FROM Stations");
				ResultSet rsStations = psStations.executeQuery();
				while (rsStations.next()) {
			%>
			<option value="<%=rsStations.getInt("StationID")%>"
				<%=request.getParameter("originStation") != null
		&& request.getParameter("originStation").equals(String.valueOf(rsStations.getInt("StationID"))) ? "selected"
				: ""%>>
				<%=rsStations.getString("StationName")%>
			</option>
			<%
			}
			rsStations.close();
			psStations.close();
			} catch (SQLException e) {
			out.println("<p>Error fetching stations: " + e.getMessage() + "</p>");
			}
			%>
		</select>

		<!-- Destination Station Dropdown -->
		<label for="destinationStation">Select Destination Station:</label> <select
			id="destinationStation" name="destinationStation"
			onchange="updateStationDropdowns()">
			<option value="">-- Select Destination --</option>
			<%
			try {
				// Fetch all stations for the destination dropdown
				con = db.getConnection();
				PreparedStatement psDestinations = con.prepareStatement("SELECT StationID, StationName FROM Stations");
				ResultSet rsDestinations = psDestinations.executeQuery();
				while (rsDestinations.next()) {
			%>
			<option value="<%=rsDestinations.getInt("StationID")%>"
				<%=request.getParameter("destinationStation") != null
		&& request.getParameter("destinationStation").equals(String.valueOf(rsDestinations.getInt("StationID")))
				? "selected"
				: ""%>>
				<%=rsDestinations.getString("StationName")%>
			</option>
			<%
			}
			rsDestinations.close();
			psDestinations.close();
			} catch (SQLException e) {
			out.println("<p>Error fetching destination stations: " + e.getMessage() + "</p>");
			}
			%>
		</select>

		<button type="submit">Search</button>
	</form>

	<hr>

	<%
	try {
		String lineID = request.getParameter("lineID");
		String originStation = request.getParameter("originStation");
		String destinationStation = request.getParameter("destinationStation");

		// Fetch schedules based on the selected search method
		PreparedStatement psSchedules = null;

		if (lineID != null && !lineID.isEmpty()) {
			psSchedules = con.prepareStatement("SELECT ts.ScheduleID, tl.LineName, t.TrainName, tl.Fare AS BaseFare, "
			+ "(SELECT s.StationName FROM TrainStops ts1 JOIN Stations s ON ts1.StationID = s.StationID "
			+ "WHERE ts1.ScheduleID = ts.ScheduleID ORDER BY ts1.StopID ASC LIMIT 1) AS Origin, "
			+ "(SELECT s.StationName FROM TrainStops ts2 JOIN Stations s ON ts2.StationID = s.StationID "
			+ "WHERE ts2.ScheduleID = ts.ScheduleID ORDER BY ts2.StopID DESC LIMIT 1) AS Destination, "
			+ "(SELECT ts1.DepartureTime FROM TrainStops ts1 WHERE ts1.ScheduleID = ts.ScheduleID ORDER BY ts1.StopID ASC LIMIT 1) AS Departure "
			+ "FROM TrainSchedules ts " + "JOIN TransitLines tl ON ts.LineID = tl.LineID "
			+ "JOIN Trains t ON tl.TrainID = t.TrainID " + "WHERE ts.LineID = ? ORDER BY ts.ScheduleID ASC");
			psSchedules.setString(1, lineID);
		} else if (originStation != null && !originStation.isEmpty() && destinationStation != null
		&& !destinationStation.isEmpty()) {
			psSchedules = con.prepareStatement("SELECT ts.ScheduleID, tl.LineName, t.TrainName, tl.Fare AS BaseFare, "
			+ "(SELECT s.StationName FROM TrainStops ts1 JOIN Stations s ON ts1.StationID = s.StationID "
			+ "WHERE ts1.ScheduleID = ts.ScheduleID ORDER BY ts1.StopID ASC LIMIT 1) AS Origin, "
			+ "(SELECT s.StationName FROM TrainStops ts2 JOIN Stations s ON ts2.StationID = s.StationID "
			+ "WHERE ts2.ScheduleID = ts.ScheduleID ORDER BY ts2.StopID DESC LIMIT 1) AS Destination, "
			+ "(SELECT ts1.DepartureTime FROM TrainStops ts1 WHERE ts1.ScheduleID = ts.ScheduleID ORDER BY ts1.StopID ASC LIMIT 1) AS Departure "
			+ "FROM TrainSchedules ts " + "JOIN TransitLines tl ON ts.LineID = tl.LineID "
			+ "JOIN Trains t ON tl.TrainID = t.TrainID "
			+ "WHERE ts.ScheduleID IN (SELECT DISTINCT ts.ScheduleID FROM TrainStops ts "
			+ "WHERE ts.StationID = ? AND ts.ScheduleID IN (SELECT DISTINCT ts.ScheduleID FROM TrainStops ts "
			+ "WHERE ts.StationID = ?)) ORDER BY ts.ScheduleID ASC");
			psSchedules.setString(1, originStation);
			psSchedules.setString(2, destinationStation);
		}

		if (psSchedules != null) {
			ResultSet rsSchedules = psSchedules.executeQuery();

			if (!rsSchedules.isBeforeFirst()) {
		out.println("<p>No train schedules found.</p>");
			} else {
		out.println("<table border='1'>");
		out.println(
				"<tr><th>Line Name</th><th>Train Name</th><th>Origin</th><th>Destination</th><th>Departure</th><th>Base Fare</th><th>Reserve</th></tr>");
		while (rsSchedules.next()) {
			int scheduleID = rsSchedules.getInt("ScheduleID");
			String lineName = rsSchedules.getString("LineName");
			String trainName = rsSchedules.getString("TrainName");
			String origin = rsSchedules.getString("Origin");
			String destination = rsSchedules.getString("Destination");
			String departure = rsSchedules.getString("Departure");
			String baseFare = rsSchedules.getString("BaseFare");

			out.println("<tr>");
			out.println("<td>" + lineName + "</td>");
			out.println("<td>" + trainName + "</td>");
			out.println("<td>" + origin + "</td>");
			out.println("<td>" + destination + "</td>");
			out.println("<td>" + departure + "</td>");
			out.println("<td>$" + baseFare + "</td>");
			out.println("<td><form method='get' action='ReserveTrain.jsp'>"
					+ "<input type='hidden' name='lineID' value='" + scheduleID + "'>"
					+ "<input type='hidden' name='lineName' value='" + lineName + "'>"
					+ "<input type='hidden' name='origin' value='" + origin + "'>"
					+ "<input type='hidden' name='destination' value='" + destination + "'>"
					+ "<input type='hidden' name='departure' value='" + departure + "'>"
					+ "<input type='hidden' name='fare' value='" + baseFare + "'>"
					+ "<button type='submit'>Reserve</button></form></td>");
			out.println("</tr>");
		}
		out.println("</table>");
			}
		}
	} catch (SQLException e) {
		out.println("<p>Error fetching train schedules. Please try again later.</p>");
		e.printStackTrace(new java.io.PrintWriter(out));
	} finally {
		if (con != null)
			try {
		con.close();
			} catch (SQLException ignored) {
			}
	}
	%>
</body>
</html>