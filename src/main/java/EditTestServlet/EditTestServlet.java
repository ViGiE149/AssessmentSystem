/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package EditTestServlet;

import testsClass.Test; // Ensure this import is necessary or remove it
import DatabaseConnection.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for editing test details.
 */
@WebServlet(urlPatterns = {"/EditTestServlet"})
public class EditTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int testId;
        try {
            testId = Integer.parseInt(request.getParameter("testId"));
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid test ID.");
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM tests WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, testId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        // Set test attributes for JSP
                        request.setAttribute("testId", testId);
                        request.setAttribute("testName", rs.getString("test_name"));
                        request.setAttribute("durationHours", rs.getInt("duration") / 60);
                        request.setAttribute("durationMinutes", rs.getInt("duration") % 60);
                        request.setAttribute("testDate", rs.getString("test_date"));
                        request.setAttribute("latestPin", rs.getString("latest_pin"));
                        request.setAttribute("showAnswers", rs.getBoolean("show_answers_at_end"));

                        // Fetch questions and options
                        fetchQuestionsAndOptions(conn, testId, request);

                        // Forward to editTest.jsp
                        request.getRequestDispatcher("/editTest.jsp").forward(request, response);
                    } else {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Test not found.");
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database access error", e);
        }
    }

    private void fetchQuestionsAndOptions(Connection conn, int testId, HttpServletRequest request) throws SQLException {
        String questionSql = "SELECT * FROM questions WHERE test_id = ?";
        try (PreparedStatement questionStmt = conn.prepareStatement(questionSql)) {
            questionStmt.setInt(1, testId);
            try (ResultSet questionRs = questionStmt.executeQuery()) {
                // Initialize lists to hold questions and options
                List<String> questions = new ArrayList<>();
                List<String> questionTypes = new ArrayList<>();
                List<String> correctAnswers = new ArrayList<>();
                List<String[]> optionsList = new ArrayList<>();

                while (questionRs.next()) {
                    // Fetch question details
                    questions.add(questionRs.getString("question_text"));
                    questionTypes.add(questionRs.getString("question_type"));
                    correctAnswers.add(questionRs.getString("correct_answer"));

                    // Fetch options for this question
                    String optionSql = "SELECT option_text FROM options WHERE question_id = ?";
                    try (PreparedStatement optionStmt = conn.prepareStatement(optionSql)) {
                        optionStmt.setInt(1, questionRs.getInt("id")); // Assuming question ID is in the 'id' column
                        try (ResultSet optionRs = optionStmt.executeQuery()) {
                            List<String> options = new ArrayList<>();
                            while (optionRs.next()) {
                                options.add(optionRs.getString("option_text"));
                            }
                            optionsList.add(options.toArray(new String[0])); // Convert List to Array
                        }
                    }
                }

                // Set attributes for JSP
                request.setAttribute("questions", questions.toArray(new String[0]));
                request.setAttribute("questionTypes", questionTypes.toArray(new String[0]));
                request.setAttribute("correctAnswers", correctAnswers.toArray(new String[0]));
                request.setAttribute("options", optionsList.toArray(new String[optionsList.size()][]));
            }
        }
    }

  @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    int testId;
    try {
        testId = Integer.parseInt(request.getParameter("testId"));
    } catch (NumberFormatException e) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid test ID.");
        return;
    }

    try {
        // Process updated test details from the form
        String testName = request.getParameter("testName");
        int durationHours = Integer.parseInt(request.getParameter("durationHours"));
        int durationMinutes = Integer.parseInt(request.getParameter("durationMinutes"));
        String testDate = request.getParameter("testDate");
        String latestPin = request.getParameter("latestPin");
        boolean showAnswersAtEnd = request.getParameter("showAnswers") != null;

        int totalDuration = (durationHours * 60) + durationMinutes;

        // Update the test in the database
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE tests SET test_name = ?, duration = ?, test_date = ?, latest_pin = ?, show_answers_at_end = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, testName);
                stmt.setInt(2, totalDuration);
                stmt.setString(3, testDate);
                stmt.setString(4, latestPin);
                stmt.setBoolean(5, showAnswersAtEnd);
                stmt.setInt(6, testId);
                
                int rowsUpdated = stmt.executeUpdate();
                System.out.println("Rows updated: " + rowsUpdated); // Debugging line
                if (rowsUpdated == 0) {
                    throw new SQLException("No rows updated, check if test ID is correct.");
                }
            }
        }

        // Redirect to a success page or back to the test list
        response.sendRedirect("testList");
    } catch (SQLException e) {
        throw new ServletException("Database access error", e);
    } catch (NumberFormatException e) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid duration values.");
    }
}

}
