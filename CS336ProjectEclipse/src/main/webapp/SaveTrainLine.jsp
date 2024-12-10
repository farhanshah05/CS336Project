<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Save Train Line</title>
</head>
<body>
<%
    String lineName = request.getParameter("lineName");
    String trainID = request.getParameter("trainID");

    if (lineName == null || trainID == null || lineName.isEmpty() || trainID.isEmpty()) {
        out.println("<h2>Invalid input. Please try again. <a href='AddTrainLine.jsp'>Go back</a></h2>");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try {
        PreparedStatement stmt = con.prepareStatement(
            "INSERT INTO TransitLines (LineName, TrainID) VALUES (?, ?)"
        );
        stmt.setString(1, lineName);
        stmt.setInt(2, Integer.parseInt(trainID));

        int rows = stmt.executeUpdate();
        if (rows > 0) {
            out.println("<h2>Train line added successfully! <a href='CustomerRepresentative.jsp'>Go back</a></h2>");
        } else {
            out.println("<h2>Failed to add train line. <a href='AddTrainLine.jsp'>Try again</a></h2>");
        }
    } catch (SQLException e) {
        out.println("<h2>Error saving train line: " + e.getMessage() + ". <a href='AddTrainLine.jsp'>Try again</a></h2>");
    } finally {
        con.close();
    }
%>
</body>
</html>
