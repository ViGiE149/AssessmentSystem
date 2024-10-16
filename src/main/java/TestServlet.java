/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import DatabaseConnection.DatabaseConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Admin
 */
@WebServlet(urlPatterns = {"/TestServlet"})
public class TestServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String testName = request.getParameter("testName");
        int duration = Integer.parseInt(request.getParameter("duration"));
        String testDate = request.getParameter("testDate");
        String latestPin = request.getParameter("latestPin");
        boolean showAnswers = request.getParameter("showAnswers") != null;

        Connection conn = null;
        PreparedStatement stmt = null;
        try {
            conn = DatabaseConnection.getConnection();
            String sql = "INSERT INTO tests (test_name, duration, test_date, latest_pin, show_answers) VALUES (?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, testName);
            stmt.setInt(2, duration);
            stmt.setDate(3, Date.valueOf(testDate));
            stmt.setString(4, latestPin);
            stmt.setBoolean(5, showAnswers);
            stmt.executeUpdate();
            ResultSet rs = stmt.getGeneratedKeys();
            int testId = 0;
            if (rs.next()) {
                testId = rs.getInt(1);
            }

            // Add questions
            String[] questions = request.getParameterValues("questions");
            String[] questionTypes = request.getParameterValues("questionTypes");
            String[] correctAnswers = request.getParameterValues("correctAnswers");

            for (int i = 0; i < questions.length; i++) {
                String questionText = questions[i];
                String questionType = questionTypes[i];
                String correctAnswer = correctAnswers[i];

                String questionSQL = "INSERT INTO questions (test_id, question_text, question_type, correct_answer) VALUES (?, ?, ?, ?)";
                PreparedStatement questionStmt = conn.prepareStatement(questionSQL);
                questionStmt.setInt(1, testId);
                questionStmt.setString(2, questionText);
                questionStmt.setString(3, questionType);
                questionStmt.setString(4, correctAnswer);
                questionStmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("testSuccess.jsp");
    }
}