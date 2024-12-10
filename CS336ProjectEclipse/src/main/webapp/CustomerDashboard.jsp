<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
    <script>
        function clearFiltersAndReload() {
            document.getElementById("searchKeyword").value = "";
            document.forms[0].submit(); // Submit the form with an empty search field
        }
    </script>
</head>
<body>
    <%
        String user = (String) session.getAttribute("user");
        String role = (String) session.getAttribute("role");

        if (user == null || !"customer".equals(role)) {
            response.sendRedirect("Login.jsp");
            return;
        }
    %>

    <h1>Welcome, <%= user %>!</h1>
    <h2>Customer Dashboard</h2>

    <!-- Browse Questions and Answers -->
    <h3>Browse Questions and Answers</h3>
    <form method="GET">
        <label for="searchKeyword">Search Questions:</label>
        <input type="text" id="searchKeyword" name="searchKeyword" value="<%= request.getParameter("searchKeyword") != null ? request.getParameter("searchKeyword") : "" %>">
        <button type="submit">Search</button>
        <button type="button" onclick="clearFiltersAndReload()">Clear</button>
    </form>

    <table border="1">
        <tr>
            <th>Question</th>
            <th>Answer</th>
            <th>Status</th>
            <th>Actions</th>
        </tr>
        <%
            String searchKeyword = request.getParameter("searchKeyword");
            ApplicationDB db = new ApplicationDB();
            Connection con = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                con = db.getConnection();
                String query = 
                    "SELECT m1.Message AS Question, " +
                    "(SELECT m2.Message FROM Messages m2 WHERE m2.ConversationID = m1.ConversationID AND m2.SenderID != m1.SenderID ORDER BY m2.Timestamp DESC LIMIT 1) AS Answer, " +
                    "c.ConversationID, c.Status " +
                    "FROM Messages m1 " +
                    "JOIN Conversations c ON m1.ConversationID = c.ConversationID " +
                    "WHERE c.CustomerID = (SELECT CustomerID FROM Customers WHERE Username = ?) AND m1.SenderID = c.CustomerID " +
                    "AND m1.Timestamp = (SELECT MIN(Timestamp) FROM Messages WHERE ConversationID = c.ConversationID) ";

                if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    query += "AND m1.Message LIKE ?";
                }

                pstmt = con.prepareStatement(query);
                pstmt.setString(1, user);
                if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                    pstmt.setString(2, "%" + searchKeyword + "%");
                }

                rs = pstmt.executeQuery();
                boolean hasResults = false;
                while (rs.next()) {
                    hasResults = true;
        %>
                    <tr>
                        <td><%= rs.getString("Question") %></td>
                        <td><%= rs.getString("Answer") != null ? rs.getString("Answer") : "Not answered yet" %></td>
                        <td><%= rs.getString("Status") %></td>
                        <td>
                            <form action="ViewConversation.jsp" method="GET" style="display:inline;">
                                <input type="hidden" name="conversationID" value="<%= rs.getInt("ConversationID") %>">
                                <button type="submit">View</button>
                            </form>
                        </td>
                    </tr>
        <%
                }
                if (!hasResults) {
        %>
                    <tr>
                        <td colspan="4">No questions found.</td>
                    </tr>
        <%
                }
            } catch (SQLException e) {
                out.println("<p>Error fetching questions: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (con != null) try { con.close(); } catch (SQLException ignored) {}
            }
        %>
    </table>

    <!-- Send a Question -->
    <h3>Send a Question</h3>
    <form method="POST">
        <label for="question">Your Question:</label><br>
        <textarea id="question" name="question" rows="4" cols="50" required></textarea><br>
        <button type="submit">Submit</button>
    </form>

    <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String question = request.getParameter("question");

            try {
                con = db.getConnection();

                // Assign a default employee if EmployeeID is required
                int defaultEmployeeID = 1; // Replace with an actual employee ID from your database

                // Start a new conversation
                int conversationID = 0;
                pstmt = con.prepareStatement(
                    "INSERT INTO Conversations (CustomerID, EmployeeID, Status) VALUES ((SELECT CustomerID FROM Customers WHERE Username = ?), ?, 'open')",
                    Statement.RETURN_GENERATED_KEYS
                );
                pstmt.setString(1, user);
                pstmt.setInt(2, defaultEmployeeID);
                pstmt.executeUpdate();
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    conversationID = rs.getInt(1);
                }

                // Insert the question as a message
                pstmt = con.prepareStatement(
                    "INSERT INTO Messages (ConversationID, SenderID, ReceiverID, Message) VALUES (?, (SELECT CustomerID FROM Customers WHERE Username = ?), ?, ?)"
                );
                pstmt.setInt(1, conversationID);
                pstmt.setString(2, user);
                pstmt.setInt(3, defaultEmployeeID);
                pstmt.setString(4, question);
                pstmt.executeUpdate();

                out.println("<p>Question submitted successfully. <a href='CustomerDashboard.jsp'>Go back</a></p>");
            } catch (SQLException e) {
                out.println("<p>Error submitting question: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (con != null) try { con.close(); } catch (SQLException ignored) {}
            }
        }
    %>

</body>
</html>
