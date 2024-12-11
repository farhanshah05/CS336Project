<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login</title>
<style>
body {
	display: flex;
	justify-content: center;
	align-items: center;
	height: 100vh;
	margin: 0;
}

.form-container {
	text-align: center;
}
</style>
</head>
<body>
	<div class="form-container">
		<form action="CheckLogin.jsp" method="POST">
			Username: <input type="text" name="Username" /> <br /> <br />
			Password: <input type="password" name="Password" /> <br /> <br />
			<input type="submit" value="Submit" />
		</form>
	</div>
</body>
</html>


