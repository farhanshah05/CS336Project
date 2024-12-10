<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add New Train Line</title>
</head>
<body>
    <h1>Add a New Train Line</h1>
    <form method="POST" action="SaveTrainLine.jsp">
        <label for="lineName">Line Name:</label>
        <input type="text" id="lineName" name="lineName" required><br><br>
        <label for="trainID">Select Train:</label>
        <select id="trainID" name="trainID" required>
            <%
                ApplicationDB db = new ApplicationDB();
                Connection con = db.getConnection();

                try (Statement stmt = con.createStatement()) {
                    ResultSet rs = stmt.executeQuery("SELECT TrainID, TrainName FROM Trains");
                    while (rs.next()) {
            %>
            <option value="<%= rs.getInt("TrainID") %>"><%= rs.getString("TrainName") %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error loading trains: " + e.getMessage() + "</p>");
                } finally {
                    con.close();
                }
            %>
        </select><br><br>
        <button type="submit">Save</button>
        <a href="CustomerRepresentative.jsp">Cancel</a>
    </form>
</body>
</html>
