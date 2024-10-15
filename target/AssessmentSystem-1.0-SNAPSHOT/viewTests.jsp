<%-- 
    Document   : viewTests
    Created on : 14 Oct 2024, 15:40:32
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Tests</title>
    <style>
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
            background-color: #27ae60;
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
    </style>
</head>
<body>
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
                            <a href="takeTest.jsp?testId=<%= testId %>&testName=<%= testName %>">Take Test</a>
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

</body>
</html>
