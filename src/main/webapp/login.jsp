<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            width: 320px;
            text-align: center;
        }
        .login-container h2 {
            margin-bottom: 20px;
            font-size: 2rem;
            color: #333;
        }
        .login-container input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 1rem;
        }
        .login-container button {
            width: 100%;
            padding: 10px;
            background-color: #ff4757;
            color: white;
            border: none;
            border-radius: 30px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s, transform 0.3s;
        }
        .login-container button:hover {
            background-color: #ff6b81;
            transform: translateY(-3px);
        }
        .error-message {
            color: #ff4757;
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
    <div class="login-container">
        <h2>Login</h2>
        <form action="LoginServlet" method="POST">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>

        <!-- Display error message if login fails -->
        <div class="error-message">
            <%= request.getAttribute("errorMessage") != null ? request.getAttribute("errorMessage") : "" %>
        </div>

        <div class="register-link">
            <p>Don't have an account? <a href="registration.jsp">Register here</a></p>
        </div>
    </div>
</body>
</html>
