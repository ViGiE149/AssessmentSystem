import DatabaseConnection.DatabaseConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/createTest"})
public class createTest extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(createTest.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error during GET request.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException e) {
            throw new ServletException("SQL error occurred", e);
        }
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        response.setContentType("text/html;charset=UTF-8");

        // Get form data
        String testName = request.getParameter("testName");
        int duration = Integer.parseInt(request.getParameter("duration"));
        String testDate = request.getParameter("testDate");
        String latestPin = request.getParameter("latestPin");
        String showAnswers = request.getParameter("showAnswers");
        boolean showAnswersAtEnd = showAnswers != null && showAnswers.equals("on");

        // Get question details
        String[] questions = request.getParameterValues("questions");
        String[] questionTypes = request.getParameterValues("questionTypes");
        String[] correctAnswers = request.getParameterValues("correctAnswer");
        String[][] options = {
                request.getParameterValues("option1[]"),
                request.getParameterValues("option2[]"),
                request.getParameterValues("option3[]"),
                request.getParameterValues("option4[]")
        };

        Connection conn = null;
        PreparedStatement testStmt = null;
        PreparedStatement questionStmt = null;
        PreparedStatement optionStmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Insert into test table
            String testSql = "INSERT INTO tests (test_name, duration, test_date, latest_pin, show_answers_at_end) VALUES (?, ?, ?, ?, ?)";
            testStmt = conn.prepareStatement(testSql, PreparedStatement.RETURN_GENERATED_KEYS);
            testStmt.setString(1, testName);
            testStmt.setInt(2, duration);
            testStmt.setString(3, testDate);
            testStmt.setString(4, latestPin);
            testStmt.setBoolean(5, showAnswersAtEnd);
            testStmt.executeUpdate();

            // Retrieve generated test ID
            try (ResultSet generatedKeys = testStmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int testId = generatedKeys.getInt(1); // Safely get the generated key

                    // Insert each question and its options
                    String questionSql = "INSERT INTO questions (test_id, question_text, question_type, correct_answer) VALUES (?, ?, ?, ?)";
                    String optionSql = "INSERT INTO options (question_id, option_text) VALUES (?, ?)";

                    for (int i = 0; i < questions.length; i++) {
                        // Insert question
                        questionStmt = conn.prepareStatement(questionSql, PreparedStatement.RETURN_GENERATED_KEYS);
                        questionStmt.setInt(1, testId);
                        questionStmt.setString(2, questions[i]);
                        questionStmt.setString(3, questionTypes[i]);
                        questionStmt.setString(4, correctAnswers[i]);
                        questionStmt.executeUpdate();

                        // Retrieve generated question ID
                        try (ResultSet questionKeys = questionStmt.getGeneratedKeys()) {
                            if (questionKeys.next()) {
                                int questionId = questionKeys.getInt(1);

                                // If it's multiple choice, insert the options
                                if (questionTypes[i].equals("multiple_choice")) {
                                    optionStmt = conn.prepareStatement(optionSql);
                                    for (int j = 0; j < 4; j++) {
                                        optionStmt.setInt(1, questionId);
                                        optionStmt.setString(2, options[j][i]);
                                        optionStmt.addBatch();
                                    }
                                    optionStmt.executeBatch();
                                }
                            }
                        }
                    }

                    // Redirect to success page or display success message
                    response.sendRedirect("success.jsp");
                } else {
                    throw new SQLException("Creating test failed, no ID obtained.");
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        } finally {
            try {
                if (optionStmt != null) optionStmt.close();
                if (questionStmt != null) questionStmt.close();
                if (testStmt != null) testStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                Logger.getLogger(createTest.class.getName()).log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
}
