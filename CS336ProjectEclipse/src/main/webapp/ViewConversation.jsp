<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
    <title>View Conversation</title>
</head>
<body>
    <%
        // Retrieve session attributes
        String user = (String) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (user == null || (!"employee".equals(role) && !"customer".equals(role))) {
            response.sendRedirect("Login.jsp");
            return;
        }

        // Retrieve the conversation ID
        int conversationID = Integer.parseInt(request.getParameter("conversationID"));

        ApplicationDB db = new ApplicationDB();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = db.getConnection();

            // Fetch messages for the conversation
            ps = con.prepareStatement(
                "SELECT m.MessageID, m.Message, m.Timestamp, " +
                "CASE " +
                "WHEN m.SenderID = c.CustomerID THEN 'Customer' " +
                "WHEN m.SenderID = e.EmployeeID THEN 'Representative' " +
                "ELSE 'Unknown' END AS SenderType " +
                "FROM Messages m " +
                "JOIN Conversations c ON m.ConversationID = c.ConversationID " +
                "LEFT JOIN Employees e ON e.EmployeeID = m.SenderID " +
                "WHERE m.ConversationID = ? ORDER BY m.Timestamp"
            );
            ps.setInt(1, conversationID);
            rs = ps.executeQuery();

            // Display conversation messages
    %>
    <h1>Conversation Details</h1>
    <table border="1">
        <tr>
            <th>Message</th>
            <th>Sender</th>
            <th>Timestamp</th>
        </tr>
        <%
            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("Message") %></td>
            <td><%= rs.getString("SenderType") %></td>
            <td><%= rs.getTimestamp("Timestamp") %></td>
        </tr>
        <%
            }
        %>
    </table>

    <!-- Reply to the conversation -->
    <h2>Reply</h2>
    <form method="POST">
        <textarea name="replyMessage" rows="4" cols="50" required></textarea><br>
        <button type="submit">Send Reply</button>
    </form>

    <!-- Back Button -->
    <br>
    <form action="<%= "employee".equals(role) ? "CustomerRepresentative.jsp" : "CustomerDashboard.jsp" %>" method="GET">
        <button type="submit">Back to <%= "employee".equals(role) ? "Dashboard" : "Customer Dashboard" %></button>
    </form>

    <%
        } catch (SQLException e) {
            out.println("<p>Error retrieving conversation: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
            if (con != null) try { con.close(); } catch (SQLException ignored) {}
        }

        // Handle reply submission
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String replyMessage = request.getParameter("replyMessage");

            try {
                con = db.getConnection();

                // Determine the sender and receiver IDs based on the role
                int senderID = 0;
                int receiverID = 0;

                if ("customer".equals(role)) {
                    ps = con.prepareStatement("SELECT CustomerID FROM Customers WHERE Username = ?");
                    ps.setString(1, user);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        senderID = rs.getInt(1);
                    }

                    // Assign a default representative (fallback logic)
                    ps = con.prepareStatement(
                        "SELECT EmployeeID FROM Employees WHERE EmployeeID = (SELECT EmployeeID FROM Conversations WHERE ConversationID = ? LIMIT 1)"
                    );
                    ps.setInt(1, conversationID);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        receiverID = rs.getInt(1);
                    }
                } else if ("employee".equals(role)) {
                    ps = con.prepareStatement("SELECT EmployeeID FROM Employees WHERE Username = ?");
                    ps.setString(1, user);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        senderID = rs.getInt(1);
                    }

                    // Set the receiver as the customer
                    ps = con.prepareStatement(
                        "SELECT CustomerID FROM Conversations WHERE ConversationID = ?"
                    );
                    ps.setInt(1, conversationID);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        receiverID = rs.getInt(1);
                    }
                }

                // Insert the reply as a message
                ps = con.prepareStatement(
                    "INSERT INTO Messages (ConversationID, SenderID, ReceiverID, Message) VALUES (?, ?, ?, ?)"
                );
                ps.setInt(1, conversationID);
                ps.setInt(2, senderID);
                ps.setInt(3, receiverID);
                ps.setString(4, replyMessage);
                ps.executeUpdate();

                out.println("<p>Message sent successfully. <a href='ViewConversation.jsp?conversationID=" + conversationID + "'>Go back</a></p>");
            } catch (SQLException e) {
                out.println("<p>Error sending message: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
                if (con != null) try { con.close(); } catch (SQLException ignored) {}
            }
        }
    %>
</body>
</html>
