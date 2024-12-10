<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Check Login</title>
</head>
<body>
<%
    String userid = request.getParameter("Username");
    String pass = request.getParameter("Password");
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        con = db.getConnection();

        // Query to validate username and password
        String query = "SELECT role FROM users WHERE username = ? AND password = ?";
        pstmt = con.prepareStatement(query);
        pstmt.setString(1, userid);
        pstmt.setString(2, pass);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // User exists
            String role = rs.getString("role");
            session.setAttribute("user", userid);
            session.setAttribute("role", role);

            // Redirect based on role
            if ("employee".equalsIgnoreCase(role)) {
                response.sendRedirect("CustomerRepresentative.jsp");
            } else if ("customer".equalsIgnoreCase(role)) {
                response.sendRedirect("CustomerDashboard.jsp");
            } else if ("admin".equalsIgnoreCase(role)) {
                response.sendRedirect("AdminDashboard.jsp");
            } else {
                out.println("<p>Invalid role detected. Please contact support.</p>");
            }
        } else {
            // Invalid login
            out.println("<p>Invalid username or password. <a href='Login.jsp'>Try again</a></p>");
        }
    } catch (SQLException e) {
        out.println("<p>Error processing request: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.close(); } catch (SQLException ignored) {}
    }
%>
</body>
</html>
