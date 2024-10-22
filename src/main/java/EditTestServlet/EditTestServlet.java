package EditTestServlet;

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
                List<String> questions = new ArrayList<>();
                List<String> questionTypes = new ArrayList<>();
                List<String> correctAnswers = new ArrayList<>();
                List<String[]> optionsList = new ArrayList<>();

                while (questionRs.next()) {
                    questions.add(questionRs.getString("question_text"));
                    questionTypes.add(questionRs.getString("question_type"));
                    correctAnswers.add(questionRs.getString("correct_answer"));

                    // Fetch options for this question
                    String optionSql = "SELECT option_text FROM options WHERE question_id = ?";
                    try (PreparedStatement optionStmt = conn.prepareStatement(optionSql)) {
                        optionStmt.setInt(1, questionRs.getInt("id"));
                        try (ResultSet optionRs = optionStmt.executeQuery()) {
                            List<String> options = new ArrayList<>();
                            while (optionRs.next()) {
                                options.add(optionRs.getString("option_text"));
                            }
                            optionsList.add(options.toArray(new String[0])); // Convert List to Array
                        }
                    }
                }

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

        String testName = request.getParameter("testName");
        int durationHours = Integer.parseInt(request.getParameter("durationHours"));
        int durationMinutes = Integer.parseInt(request.getParameter("durationMinutes"));
        String testDate = request.getParameter("testDate");
        String latestPin = request.getParameter("latestPin");
        boolean showAnswers = request.getParameter("showAnswers") != null;

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            // Update test details
            updateTestDetails(conn, testId, testName, durationHours, durationMinutes, testDate, latestPin, showAnswers);

            // Delete existing questions and options
            deleteExistingQuestionsAndOptions(conn, testId);

            // Collect questions, question types, correct answers, and options
            String[] questions = request.getParameterValues("questions");
            String[] questionTypes = request.getParameterValues("questionTypes");
            String[] correctAnswers = new String[questions.length];
            String[][] options = new String[questions.length][];

            for (int i = 0; i < questions.length; i++) {
                correctAnswers[i] = request.getParameter("correctAnswer_" + i);
                if (questionTypes[i].equals("multiple_choice")) {
                    options[i] = new String[4]; // Assuming 4 options
                    for (int j = 0; j < 4; j++) {
                        options[i][j] = request.getParameter("options_" + i + "_" + j);
                    }
                }
            }

            // Insert updated questions and options
            insertUpdatedQuestionsAndOptions(conn, testId, questions, questionTypes, correctAnswers, options);

            conn.commit(); // Commit transaction
            response.sendRedirect("testList.jsp"); // Redirect to the test list or appropriate page
        } catch (SQLException e) {
            throw new ServletException("Database access error", e);
        }
    }

    private void updateTestDetails(Connection conn, int testId, String testName, int durationHours, int durationMinutes, String testDate, String latestPin, boolean showAnswers) throws SQLException {
        int totalDuration = (durationHours * 60) + durationMinutes;
        String sql = "UPDATE tests SET test_name = ?, duration = ?, test_date = ?, latest_pin = ?, show_answers_at_end = ? WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, testName);
            stmt.setInt(2, totalDuration);
            stmt.setString(3, testDate);
            stmt.setString(4, latestPin);
            stmt.setBoolean(5, showAnswers);
            stmt.setInt(6, testId);
            stmt.executeUpdate();
        }
    }

    private void deleteExistingQuestionsAndOptions(Connection conn, int testId) throws SQLException {
        // Delete options for all questions in this test
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
            try (PreparedStatement questionStmt = conn.prepareStatement(questionSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
                questionStmt.setInt(1, testId);
                questionStmt.setString(2, questions[i]);
                questionStmt.setString(3, questionTypes[i]);
                questionStmt.setString(4, correctAnswers[i]);
                questionStmt.executeUpdate();

                // Get the generated question ID
                try (ResultSet generatedKeys = questionStmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int questionId = generatedKeys.getInt(1);

                        // Insert options for this question
                        if (options[i] != null) {
                            for (String option : options[i]) {
                                try (PreparedStatement optionStmt = conn.prepareStatement(optionSql)) {
                                    optionStmt.setInt(1, questionId);
                                    optionStmt.setString(2, option);
                                    optionStmt.executeUpdate();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
