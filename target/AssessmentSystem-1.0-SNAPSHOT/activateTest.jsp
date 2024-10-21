<%-- 
    Document   : activateTest
    Created on : 15 Oct 2024, 10:28:16
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activate Tests</title>
    <style>
        /* Global Styles */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
            color: #333;
        }

        h1 {
            text-align: center;
            color: #333;
        }

        /* Table Styles */
        .table-container {
            width: 100%;
            max-width: 1000px;
            margin: 0 auto;
            overflow-x: auto;
            background-color: white;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #2c3e50;
            color: white;
        }

        td {
            color: #555;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        /* Button Styles */
        .btn-activate, .btn-deactivate {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .btn-activate {
            background-color: #27ae60;
            color: white;
        }

        .btn-activate:hover {
            background-color: #218c54;
        }

        .btn-deactivate {
            background-color: #e74c3c;
            color: white;
        }

        .btn-deactivate:hover {
            background-color: #c0392b;
        }

        /* Mobile Responsiveness */
        @media only screen and (max-width: 768px) {
            h1 {
                font-size: 24px;
            }

            th, td {
                font-size: 14px;
                padding: 12px;
            }

            .btn-activate, .btn-deactivate {
                font-size: 12px;
                padding: 6px 12px;
            }
        }

        @media only screen and (max-width: 480px) {
            th, td {
                font-size: 12px;
                padding: 10px;
            }

            .btn-activate, .btn-deactivate {
                font-size: 11px;
                padding: 5px 10px;
            }
        }
        
        
        
         
        .navbar {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: #ffffff;
            padding: 4px;
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
                <li><a href="lecturerDashboard.jsp">Dashboard</a></li>
                <li><a href="createTest.jsp">Set Test</a></li>
                 <li><a href="testList.jsp">View Tests</a></li>
                <li><a href="activateTest.jsp">Activate Tests</a></li>
            </ul>
        </div>

        <div class="content">
    
    
    
    
    <h1>Activate or Deactivate Tests</h1>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>Test Name</th>
                    <th>Duration (minutes)</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {
                        conn = DatabaseConnection.getConnection();

                        // Fetch all tests
                        String sql = "SELECT * FROM tests";
                        ps = conn.prepareStatement(sql);
                        rs = ps.executeQuery();

                        while (rs.next()) {
                            int testId = rs.getInt("id");
                            String testName = rs.getString("test_name");
                            int duration = rs.getInt("duration");
                            boolean isActive = rs.getBoolean("is_active");
                %>
                <tr>
                    <td><%= testName %></td>
                    <td><%= duration %></td>
                    <td><%= isActive ? "Active" : "Inactive" %></td>
                    <td>
                        <form action="toggleTestStatus.jsp" method="post">
                            <input type="hidden" name="testId" value="<%= testId %>">
                            <% if (isActive) { %>
                                <button type="submit" name="action" value="deactivate" class="btn-deactivate">Deactivate</button>
                            <% } else { %>
                                <button type="submit" name="action" value="activate" class="btn-activate">Activate</button>
                            <% } %>
                        </form>
                    </td>
                </tr>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (rs != null) rs.close();
                        if (ps != null) ps.close();
                        if (conn != null) conn.close();
                    }
                %>
            </tbody>
        </table>
    </div>

            
             </div>
    </div>
</body>
</html>
