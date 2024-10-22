package services;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CreateTestService extends BaseTestService {

    public CreateTestService(Connection conn) {
        super(conn);
    }

   @Override
public void insertQuestions(int testId, String[] questions, String[] questionTypes, String[] correctAnswers, String[][] options) throws SQLException {
    String questionSql = "INSERT INTO questions (test_id, question_text, question_type, correct_answer) VALUES (?, ?, ?, ?)";
    String optionSql = "INSERT INTO options (question_id, option_text) VALUES (?, ?)";

    for (int i = 0; i < questions.length; i++) {
        // Insert the question first
        try (PreparedStatement questionStmt = conn.prepareStatement(questionSql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            questionStmt.setInt(1, testId);
            questionStmt.setString(2, questions[i]);
            questionStmt.setString(3, questionTypes[i]);
            questionStmt.setString(4, correctAnswers[i]); // Save correct answer directly

            questionStmt.executeUpdate();

            // Get the generated question_id
            try (ResultSet rs = questionStmt.getGeneratedKeys()) {
                if (rs.next()) {
                    int questionId = rs.getInt(1);

                    // Now insert all options for this question if it's multiple choice
                    if (questionTypes[i].equals("multiple_choice")) {
                        for (String option : options[i]) {
                            try (PreparedStatement optionStmt = conn.prepareStatement(optionSql)) {
                                optionStmt.setInt(1, questionId);  // Link option to the question
                                optionStmt.setString(2, option);   // Insert option text
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
