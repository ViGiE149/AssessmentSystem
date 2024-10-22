package services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public abstract class BaseTestService {
    protected Connection conn;

    public BaseTestService(Connection conn) {
        this.conn = conn;
    }

    // Common method for inserting a test
    public int insertTest(String testName, int duration, String testDate, String latestPin, boolean showAnswersAtEnd, String userId) throws SQLException {
        String sql = "INSERT INTO tests (test_name, duration, test_date, latest_pin, show_answers_at_end, user_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, testName);
            stmt.setInt(2, duration);
            stmt.setString(3, testDate);
            stmt.setString(4, latestPin);
            stmt.setBoolean(5, showAnswersAtEnd);
            stmt.setString(6, userId);
            stmt.executeUpdate();

            // Return generated test ID
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Test creation failed, no ID obtained.");
                }
            }
        }
    }

    // Abstract method to insert questions, implemented by subclasses
    public abstract void insertQuestions(int testId, String[] questions, String[] questionTypes, String[] correctAnswers, String[][] options) throws SQLException;
}
