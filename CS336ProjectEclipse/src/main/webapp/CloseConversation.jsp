<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.sql.*" %>
<%
    int conversationID = Integer.parseInt(request.getParameter("conversationID"));
    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try (PreparedStatement ps = con.prepareStatement(
        "UPDATE Conversations SET Status = 'closed' WHERE ConversationID = ?")) {
        ps.setInt(1, conversationID);
        ps.executeUpdate();

        response.sendRedirect("CustomerRepresentative.jsp");
    } catch (SQLException e) {
        out.println("<p>Error closing conversation: " + e.getMessage() + "</p>");
    }
%>
