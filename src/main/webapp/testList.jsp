

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Tests</title>
    <style>
        /* Existing styles */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }
        h1 {
            text-align: center;
            color: #2c3e50;
            margin-top: 20px;
            font-size: 2.2em;
        }
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
            background-color: #fff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        table, th, td {
            border: 1px solid #dfe6e9;
        }
        th {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: white;
            font-size: 18px;
            padding: 15px;
        }
        td {
            padding: 12px;
            font-size: 16px;
            color: #34495e;
        }
        tr:nth-child(even) {
            background-color: #ecf0f1;
        }
        tr:hover {
            background-color: #bdc3c7;
        }
        a {
            color: #27ae60;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.3s ease;
        }
        a:hover {
            color: #2ecc71;
            text-decoration: underline;
        }
        p {
            text-align: center;
            font-size: 18px;
            color: #7f8c8d;
        }
        
        
        
        
        
        .navbar {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: #ffffff;
            padding: 9px;
            text-align: right;
            position:fixed;
        }
        .navbar a {
            color: #ffffff;
            text-decoration: none;
            margin-left: 20px;
        }
        .container {
            display: flex;
            height: 100%; /* Adjust for navbar height */
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background: linear-gradient(to right, #4e54c8, #8f94fb);
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
            <h2>Lecturer Menu</h2>
            <ul>
                <li><a href="#">Dashboard</a></li>
                <li><a href="createTest.jsp">Set Test</a></li>
                 <li><a href="testList.jsp">View Tests</a></li>
                <li><a href="activateTest.jsp">Activate Tests</a></li>
            </ul>
        </div>

        <div class="content">
    
    
    <h1>Available Activated Tests</h1>
    
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Establish connection to the database
            conn = DatabaseConnection.getConnection();

            // SQL query to fetch only the activated tests (where is_active = 1)
            String sql = "SELECT id, test_name, duration, test_date FROM tests WHERE is_active = 1";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            // Check if there are any activated tests available
            if (!rs.isBeforeFirst()) {
                out.println("<p>No activated tests available.</p>");
            } else {
    %>
                <!-- Table to display available tests -->
                <table>
                    <tr>
                        <th>Test Name</th>
                        <th>Duration (minutes)</th>
                        <th>Test Date</th>
                        <th>Action</th>
                    </tr>
                    <%
                        // Loop through the result set and display each activated test
                        while (rs.next()) {
                            int testId = rs.getInt("id");
                            String testName = rs.getString("test_name");
                            int duration = rs.getInt("duration");
                            Date testDate = rs.getDate("test_date");
                    %>
                    <tr>
                        <td><%= testName %></td>
                        <td><%= duration %></td>
                        <td><%= testDate %></td>
                        <td>
                            <!-- Link to take the test -->
                            <a href="viewTestResultsServlet?testId=<%= testId %>&testName=<%= testName %>">View Grades</a>
                            | 
                            <!-- Link to edit the test -->
                            <a href="EditTestServlet?testId=<%= testId %>">Edit</a>
                            | 
                            <!-- Link to delete the test -->
                            <a href="deleteTest.jsp?testId=<%= testId %>" onclick="return confirm('Are you sure you want to delete this test?');">Delete</a>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </table>
    <%
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error retrieving tests. Please try again later.</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>

    
     </div>
    </div>
</body>
</html>
