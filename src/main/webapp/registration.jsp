<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Page</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            width: 400px;
            text-align: center;
        }
        h2 {
            margin-bottom: 20px;
            font-size: 2rem;
            color: #333;
        }
        label {
            display: block;
            margin-bottom: 8px;
            text-align: left;
        }
        input[type="text"], input[type="password"], select {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
        }
        input[type="submit"] {
            background-color: #ff4757;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 30px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s, transform 0.3s;
        }
        input[type="submit"]:hover {
            background-color: #ff6b81;
            transform: translateY(-3px);
        }
        .error {
            color: red;
            margin-top: 10px;
            font-size: 0.9rem;
        }
        .register-link {
            margin-top: 20px;
            font-size: 0.9rem;
        }
        .register-link a {
            color: #4e54c8;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Registration Form</h2>
        <form action="RegisterServlet" method="post">
            <label for="username">Username</label>
            <input type="text" id="username" name="username" required>

            <label for="password">Password</label>
            <input type="password" id="password" name="password" required>

            <label for="email">Email</label>
            <input type="text" id="email" name="email" required>

            <label for="role">Role</label>
            <select id="role" name="role" required>
                <option value="student">Student</option>
                <option value="lecturer">Lecturer</option>
            </select>

            <input type="submit" value="Register">
            
            <div class="register-link">
                <p>Already have an account? <a href="login.jsp">Login here</a></p>
            </div>
        </form>

        <%-- Display error messages if any --%>
        <%
            String message = (String) request.getAttribute("message");
            if (message != null) {
        %>
        <div class="error">
            <%= message %>
        </div>
        <% } %>
    </div>
</body>
</html>
