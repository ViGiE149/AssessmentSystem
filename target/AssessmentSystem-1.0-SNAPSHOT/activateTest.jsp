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
    </style>
</head>
<body>

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

</body>
</html>
