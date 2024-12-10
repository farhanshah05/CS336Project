<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Train Schedule</title>
</head>
<body>
    <h1>Add a New Train Schedule</h1>
    <form method="POST" action="SaveTrainSchedule.jsp">
        <!-- Select Train Line -->
        <label for="lineID">Select Train Line:</label>
        <select id="lineID" name="lineID" required>
            <%
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();

                try (Statement stmt = con.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT LineID, LineName FROM TransitLines");
                    while (rs.next()) {
            %>
            <option value="<%= rs.getInt("LineID") %>"><%= rs.getString("LineName") %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading train lines: " + e.getMessage() + "</p>");
                } finally {
                    con.close();
                }
            %>
        </select><br><br>

        <!-- First Stop -->
        <label for="firstStop">First Stop:</label>
        <select id="firstStop" name="firstStop" required>
            <%
                db = new ApplicationDB();
                con = db.getConnection();

                try (Statement stmt = con.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");
                    while (rs.next()) {
            %>
            <option value="<%= rs.getInt("StationID") %>"><%= rs.getString("StationName") %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
                } finally {
                    con.close();
                }
            %>
        </select><br><br>

        <!-- Next Stop -->
        <label for="nextStop">Next Stop:</label>
        <select id="nextStop" name="nextStop" required>
            <%
                db = new ApplicationDB();
                con = db.getConnection();

                try (Statement stmt = con.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");
                    while (rs.next()) {
            %>
            <option value="<%= rs.getInt("StationID") %>"><%= rs.getString("StationName") %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
                } finally {
                    con.close();
                }
            %>
        </select><br><br>

        <!-- Arrival Time -->
        <label for="arrivalTime">Arrival Time:</label>
        <input type="datetime-local" id="arrivalTime" name="arrivalTime" required>
        <span>(Example: 2024-12-04 07:00:00.0)</span><br><br>

        <!-- Departure Time -->
        <label for="departureTime">Departure Time:</label>
        <input type="datetime-local" id="departureTime" name="departureTime" required>
        <span>(Example: 2024-12-04 07:10:00.0)</span><br><br>

        <!-- Submit Button -->
        <button type="submit">Save</button>
        <a href="CustomerRepresentative.jsp">Cancel</a>
    </form>
</body>
</html>
