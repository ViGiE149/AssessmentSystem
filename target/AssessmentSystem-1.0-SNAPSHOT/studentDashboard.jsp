<%-- 
    Document   : studentDashboard
    Created on : 10 Oct 2024, 13:10:21
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="styles.css"> <!-- Link to your CSS file for styles -->
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .navbar {
            background: #343a40;
            color: #ffffff;
            padding: 15px;
            text-align: right;
        }
        .navbar a {
            color: #ffffff;
            text-decoration: none;
            margin-left: 20px;
        }
        .container {
            display: flex;
            height: calc(100vh - 60px); /* Adjust for navbar height */
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background: #343a40;
            color: #ffffff;
            padding: 20px;
            transition: transform 0.3s ease;
            transform: translateX(0); /* Sidebar visible by default */
        }
        .sidebar.closed {
            transform: translateX(-100%); /* Hide sidebar */
        }
        .sidebar h2 {
            text-align: center;
        }
        .sidebar ul {
            list-style-type: none;
            padding: 0;
        }
        .sidebar ul li {
            padding: 10px;
            border-bottom: 1px solid #495057;
        }
        .sidebar ul li a {
            color: #ffffff;
            text-decoration: none;
        }
        .sidebar ul li a:hover {
            background: #495057;
        }
        .content {
            flex: 1;
            padding: 20px;
            background: #ffffff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #343a40;
        }
        .toggle-button {
            display: none;
            background: #343a40;
            color: #ffffff;
            border: none;
            padding: 10px;
            cursor: pointer;
            margin-left: 20px;
        }
        @media (max-width: 768px) {
            .toggle-button {
                display: inline-block;
            }
            .sidebar {
                position: absolute; /* Change to absolute for mobile */
                z-index: 1000; /* Ensure it overlaps the content */
            }
            .container {
                flex-direction: column; /* Stack content on mobile */
            }
            .content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

    <div class="navbar">
        <button class="toggle-button" onclick="toggleSidebar()"><i class="fas fa-bars"></i> Menu</button>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="container">
        <div class="sidebar" id="sidebar">
            <h2>Student Menu</h2>
            <ul>
                <li><a href="viewTests.jsp">View Tests</a></li>
                <li><a href="viewCourses.jsp">View Courses</a></li>
                <li><a href="submitAssignments.jsp">Submit Assignments</a></li>
                <li><a href="viewGrades.jsp">View Grades</a></li>
                <li><a href="profile.jsp">Edit Profile</a></li>
            </ul>
        </div>

        <div class="content">
            <%
//                HttpSession session = request.getSession(false);
                String username = (String) session.getAttribute("username");
                if (username == null) {
                    response.sendRedirect("login.jsp");
                }
            %>
            <h1>Welcome, <%= username %>!</h1>
            <p>Select an option from the menu to get started.</p>
        </div>
    </div>

    <script>
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('closed');
        }
    </script>

</body>
</html>