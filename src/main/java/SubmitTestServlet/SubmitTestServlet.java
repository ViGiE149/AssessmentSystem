package submitTestServlet;

import DatabaseConnection.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/SubmitTestServlet"})
public class SubmitTestServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Consider using a logging framework instead of printStackTrace
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction

            // Insert test details
            String sql = "INSERT INTO tests (test_name, subject, date, duration, test_pin, show_answers, instructions) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, request.getParameter("testName"));
            pstmt.setString(2, request.getParameter("subject"));

            // Handle date
            String dateStr = request.getParameter("date");
            Date sqlDate = Date.valueOf(dateStr); // Ensure the date is in 'yyyy-[m]m-[d]d' format
            pstmt.setDate(3, sqlDate);

            // Handle duration as integer
            int duration = Integer.parseInt(request.getParameter("duration"));
            pstmt.setInt(4, duration);

            pstmt.setString(5, request.getParameter("testPin"));
            pstmt.setString(6, request.getParameter("showAnswers"));
            pstmt.setString(7, request.getParameter("instructions"));
            pstmt.executeUpdate();

            // Get the generated test ID
            rs = pstmt.getGeneratedKeys();
            int testId = -1;
            if (rs.next()) {
                testId = rs.getInt(1);
            } else {
                throw new SQLException("Creating test failed, no ID obtained.");
            }

            // Insert questions and options
            int i = 1;
            while (request.getParameter("questionText_" + i) != null) {
                String questionText = request.getParameter("questionText_" + i);
                String questionType = request.getParameter("questionType_" + i);

                // Insert question
                String sqlQuestion = "INSERT INTO questions (test_id, question_text, question_type) VALUES (?, ?, ?)";
                pstmt = conn.prepareStatement(sqlQuestion, Statement.RETURN_GENERATED_KEYS);
                pstmt.setInt(1, testId);
                pstmt.setString(2, questionText);
                pstmt.setString(3, questionType);
                pstmt.executeUpdate();

                // Get the generated question ID
                rs = pstmt.getGeneratedKeys();
                int questionId = -1;
                if (rs.next()) {
                    questionId = rs.getInt(1);
                } else {
                    throw new SQLException("Creating question failed, no ID obtained.");
                }

                if ("multipleChoice".equals(questionType)) {
                    // Insert options for multiple-choice questions
                    String sqlOptions = "INSERT INTO options (question_id, option_text, option_number, is_correct) VALUES (?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sqlOptions);
                    for (int j = 1; j <= 4; j++) {
                        String optionText = request.getParameter("option_" + i + "_" + j);
                        if (optionText == null || optionText.trim().isEmpty()) {
                            throw new SQLException("Option " + j + " for question " + i + " is empty.");
                        }
                        pstmt.setInt(1, questionId);
                        pstmt.setString(2, optionText);
                        pstmt.setInt(3, j);
                        int correctOption = Integer.parseInt(request.getParameter("correctOption_" + i));
                        pstmt.setBoolean(4, j == correctOption);
                        pstmt.executeUpdate();
                    }
                } else if ("trueFalse".equals(questionType)) {
                    // Update the correct answer for true/false questions
                    String correctAnswer = request.getParameter("correctAnswer_" + i);
                    if (correctAnswer == null || (!correctAnswer.equals("true") && !correctAnswer.equals("false"))) {
                        throw new SQLException("Invalid correct answer for true/false question " + i);
                    }
                    String sqlUpdateCorrectAnswer = "UPDATE questions SET correct_answer = ? WHERE id = ?";
                    pstmt = conn.prepareStatement(sqlUpdateCorrectAnswer);
                    pstmt.setString(1, correctAnswer);
                    pstmt.setInt(2, questionId);
                    pstmt.executeUpdate();
                } else {
                    throw new SQLException("Unknown question type: " + questionType);
                }

                i++;
            }

            conn.commit();  // Commit transaction
            response.sendRedirect(request.getContextPath() + "/testSuccess.jsp");
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            // Optionally, pass error details to failure page
            response.sendRedirect(request.getContextPath() + "/testFailure.jsp");
        } catch (IllegalArgumentException e) {
            // Handle potential parsing errors like Date.valueOf
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            response.sendRedirect(request.getContextPath() + "/testFailure.jsp");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}