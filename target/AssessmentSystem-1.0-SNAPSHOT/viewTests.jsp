<%-- 
    Document   : viewTests
    Created on : 14 Oct 2024, 15:40:32
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Available Tests</title>
    <style>
        table {
            width: 80%;
            margin: 20px auto;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
    </style>
</head>
<body>
    <h1 style="text-align: center;">Available Tests</h1>
    
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Establish connection to the database
            conn = DatabaseConnection.getConnection();

            // SQL query to fetch all tests
            String sql = "SELECT id, test_name, duration, test_date FROM tests";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            // Check if there are any tests available
            if (!rs.isBeforeFirst()) {
                out.println("<p style='text-align: center;'>No tests available.</p>");
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
                        // Loop through the result set and display each test
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
