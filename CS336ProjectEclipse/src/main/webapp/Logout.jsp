<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="refresh" content="3;url=Login.jsp">
<title>Logout Successful!</title></head>
</head>
<body>
<%
    // Invalidate the session to log out the user
    session.invalidate();
%>

<h1>Logout Successful</h1>
<p>You have been logged out. You will be redirected to the login page in 3 seconds.</p>
<p>If you are not redirected, <a href="Login.jsp">click here</a>.</p>

</body>
</html>
