<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%@ page import="java.sql.*" %>
<%
    int conversationID = Integer.parseInt(request.getParameter("conversationID"));
    String replyMessage = request.getParameter("replyMessage");
    String user = (String) session.getAttribute("user");

    ApplicationDB db = new ApplicationDB();
    Connection con = db.getConnection();

    try (PreparedStatement ps = con.prepareStatement(
        "INSERT INTO Messages (ConversationID, SenderType, SenderID, ReceiverID, Message) " +
        "VALUES (?, 'employee', (SELECT EmployeeID FROM Employees WHERE Username = ?), " +
        "(SELECT CustomerID FROM Conversations WHERE ConversationID = ?), ?)")) {
        ps.setInt(1, conversationID);
        ps.setString(2, user);
        ps.setInt(3, conversationID);
        ps.setString(4, replyMessage);
        ps.executeUpdate();

        response.sendRedirect("ViewConversation.jsp?conversationID=" + conversationID);
    } catch (SQLException e) {
        out.println("<p>Error sending reply: " + e.getMessage() + "</p>");
    }
%>
