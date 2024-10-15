<%-- 
    Document   : toggleTestStatus
    Created on : 15 Oct 2024, 10:25:27
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
    <title>Toggle Test Status</title>
</head>
<body>
    <%
        int testId = Integer.parseInt(request.getParameter("testId"));
        String action = request.getParameter("action");
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Toggle test status based on the action
            String sql = "UPDATE tests SET is_active = ? WHERE id = ?";
            ps = conn.prepareStatement(sql);

            if (action.equals("activate")) {
                ps.setBoolean(1, true);
            } else if (action.equals("deactivate")) {
                ps.setBoolean(1, false);
            }
            
            ps.setInt(2, testId);
            ps.executeUpdate();

            response.sendRedirect("activateTest.jsp"); // Redirect back to the activation page
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    %>
</body>
</html>

