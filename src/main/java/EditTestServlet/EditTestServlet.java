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
            testId = Integer.parseInt(request.getParameter("testId")); // Remove the space before testId
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid test ID.");
            return;
        }
        
    

        
        

        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            // Update test details
            updateTestDetails(conn, request, testId);

            // Get question details from the form
            String[] questions = request.getParameterValues("questions");
            String[] questionTypes = request.getParameterValues("questionTypes");
            String[] correctAnswers = request.getParameterValues("correctAnswer");
            String[][] options = {
                request.getParameterValues("option1[]"),
                request.getParameterValues("option2[]"),
                request.getParameterValues("option3[]"),
                request.getParameterValues("option4[]")
            };

            // Delete existing questions and options
            deleteExistingQuestionsAndOptions(conn, testId);

            // Insert updated questions and options
            insertUpdatedQuestionsAndOptions(conn, testId, questions, questionTypes, correctAnswers, options);

            conn.commit(); // Commit transaction
            response.sendRedirect("testList.jsp");

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback transaction on error
                } catch (SQLException ex) {
                    throw new ServletException("Rollback failed", ex);
                }
            }
            throw new ServletException("Database error during update", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    // Log the error but don't throw it
                    e.printStackTrace();
                }
            }
        }
    }

    private void updateTestDetails(Connection conn, HttpServletRequest request, int testId) throws SQLException {
        String testName = request.getParameter("testName");
        int durationHours = Integer.parseInt(request.getParameter("durationHours"));
        int durationMinutes = Integer.parseInt(request.getParameter("durationMinutes"));
        int totalDuration = (durationHours * 60) + durationMinutes;
        String testDate = request.getParameter("testDate");
        String latestPin = request.getParameter("latestPin");
        String showAnswers = request.getParameter("showAnswers");
        boolean showAnswersAtEnd = showAnswers != null && showAnswers.equals("on");

        String sql = "UPDATE tests SET test_name = ?, duration = ?, test_date = ?, latest_pin = ?, show_answers_at_end = ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, testName);
            stmt.setInt(2, totalDuration);
            stmt.setString(3, testDate);
            stmt.setString(4, latestPin);
            stmt.setBoolean(5, showAnswersAtEnd);
            stmt.setInt(6, testId);
            stmt.executeUpdate();
        }
    }

    private void deleteExistingQuestionsAndOptions(Connection conn, int testId) throws SQLException {
        // First delete options for all questions in this test
        String deleteOptionsSql = "DELETE o FROM options o " +
                                "INNER JOIN questions q ON o.question_id = q.id " +
                                "WHERE q.test_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteOptionsSql)) {
            stmt.setInt(1, testId);
            stmt.executeUpdate();
        }

        // Then delete questions
        String deleteQuestionsSql = "DELETE FROM questions WHERE test_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(deleteQuestionsSql)) {
            stmt.setInt(1, testId);
            stmt.executeUpdate();
        }
    }

    private void insertUpdatedQuestionsAndOptions(Connection conn, int testId,
            String[] questions, String[] questionTypes, String[] correctAnswers,
            String[][] options) throws SQLException {
        
        String questionSql = "INSERT INTO questions (test_id, question_text, question_type, correct_answer) VALUES (?, ?, ?, ?)";
        String optionSql = "INSERT INTO options (question_id, option_text) VALUES (?, ?)";

        for (int i = 0; i < questions.length; i++) {
            // Insert question
            PreparedStatement questionStmt = conn.prepareStatement(questionSql, PreparedStatement.RETURN_GENERATED_KEYS);
            questionStmt.setInt(1, testId);
            questionStmt.setString(2, questions[i]);
            questionStmt.setString(3, questionTypes[i]);
            questionStmt.setString(4, correctAnswers[i]);
            questionStmt.executeUpdate();

            // Get the generated question ID
            ResultSet generatedKeys = questionStmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                int questionId = generatedKeys.getInt(1);

                // If it's multiple choice, insert the options
                if (questionTypes[i].equals("multiple_choice")) {
                    PreparedStatement optionStmt = conn.prepareStatement(optionSql);
                    for (int j = 0; j < 4; j++) {
                        if (options[j][i] != null && !options[j][i].trim().isEmpty()) {
                            optionStmt.setInt(1, questionId);
                            optionStmt.setString(2, options[j][i]);
                            optionStmt.addBatch();
                        }
                    }
                    optionStmt.executeBatch();
                    optionStmt.close();
                }
            }
            generatedKeys.close();
            questionStmt.close();
        }
    }
}