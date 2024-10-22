<%-- 
    Document   : deleteTest
    Created on : 22 Oct 2024, 19:54:08
    Author     : Admin
--%>

<%@ page import="java.sql.*, DatabaseConnection.DatabaseConnection" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 50%;
            max-width: 600px;
            text-align: center;
        }
        h1 {
            color: #333;
        }
        p {
            font-size: 18px;
            color: #666;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        a:hover {
            background-color: #0056b3;
        }
        .error {
            color: red;
        }
        .success {
            color: green;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Delete Test</h1>

    <%
        // Get the test ID from the request parameter
        int testId = Integer.parseInt(request.getParameter("testId"));

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // Establish a connection to the database
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction

            // Step 1: Delete options for all questions in this test
            String deleteOptionsSql = "DELETE o FROM options o " +
                                      "INNER JOIN questions q ON o.question_id = q.id " +
                                      "WHERE q.test_id = ?";
            stmt = conn.prepareStatement(deleteOptionsSql);
            stmt.setInt(1, testId);
            stmt.executeUpdate();

            // Step 2: Delete the questions for this test
            String deleteQuestionsSql = "DELETE FROM questions WHERE test_id = ?";
            stmt = conn.prepareStatement(deleteQuestionsSql);
            stmt.setInt(1, testId);
            stmt.executeUpdate();

            // Step 3: Delete the test itself
            String deleteTestSql = "DELETE FROM tests WHERE id = ?";
            stmt = conn.prepareStatement(deleteTestSql);
            stmt.setInt(1, testId);
            int rowsAffected = stmt.executeUpdate();

            // Commit transaction if all steps succeed
            conn.commit();

            if (rowsAffected > 0) {
                out.println("<p class='success'>Test deleted successfully, along with all related questions and options.</p>");
            } else {
                out.println("<p class='error'>Test not found or already deleted.</p>");
            }

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();  // Rollback if something goes wrong
            }
            e.printStackTrace();
            out.println("<p class='error'>Error deleting the test. Please try again later.</p>");
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>

    <a href="testList.jsp">Back to Test List</a>
</div>

</body>
</html>
