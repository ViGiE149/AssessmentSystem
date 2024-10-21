<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #007bff;
        }
        table {
            width: 100%;
            margin: 20px 0;
            border-collapse: collapse;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border: 1px solid #ddd;
            transition: background-color 0.3s;
        }
        th {
            background-color: #007bff;
            color: #fff;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .correct {
            background-color: #d4edda; /* Light green for correct answers */
            font-weight: bold;
        }
        .wrong {
            background-color: #f8d7da; /* Light red for wrong answers */
            font-weight: bold;
        }
        .user-selected {
            background-color: #ffeeba; /* Light yellow for user's selected answer */
        }
        .options {
            padding-left: 20px; /* Indentation for options */
            font-size: 0.9em;
        }
        .score {
            text-align: center;
            font-size: 1.2em;
            margin-top: 20px;
            color: #007bff;
        }
    </style>
</head>
<body>
    <h1>Test Results</h1>

    <%
        // Fetch testId from the request
        int testId = Integer.parseInt(request.getParameter("testId"));
        int totalQuestions = 0;
        int correctAnswers = 0;
        boolean showAnswers = false;
        String testName = "";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Connect to the database
            conn = DatabaseConnection.getConnection();

            // Fetch all questions for the test
            String sql = "SELECT id, question_text, correct_answer FROM questions WHERE test_id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, testId);
            rs = ps.executeQuery();

            // Create a flag to check if we should show answers at the end
            String testInfoSQL = "SELECT show_answers_at_end, test_name FROM tests WHERE id = ?";
            PreparedStatement psTestInfo = conn.prepareStatement(testInfoSQL);
            psTestInfo.setInt(1, testId);
            ResultSet rsTestInfo = psTestInfo.executeQuery();
            if (rsTestInfo.next()) {
                showAnswers = rsTestInfo.getBoolean("show_answers_at_end");
                testName = rsTestInfo.getString("test_name");
            }

            out.println("<table>");
            out.println("<tr><th>Question</th><th>Your Answer</th><th>Correct Answer</th><th>Options</th></tr>");
            
            int questionIndex = 0;
            while (rs.next()) {
                int questionId = rs.getInt("id");
                String questionText = rs.getString("question_text");
                String correctAnswer = rs.getString("correct_answer");

                // Use the correct parameter name based on question ID
                String userAnswer = request.getParameter("question_" + questionId);
                userAnswer = (userAnswer != null) ? userAnswer.trim() : "No answer";

                // Check if the answer is correct
                if (userAnswer.equalsIgnoreCase(correctAnswer)) {
                    correctAnswers++;
                }

                // Save user answer in the database (optional)
                String insertAnswerSQL = "INSERT INTO user_answers (test_id, question_id, user_id, user_answer) VALUES (?, ?, ?, ?)";
                PreparedStatement psInsert = conn.prepareStatement(insertAnswerSQL);
                psInsert.setInt(1, testId);
                psInsert.setInt(2, questionId);
                psInsert.setInt(3, 1); // Assume user_id is 1 (change this as per your login system)
                psInsert.setString(4, userAnswer);
                psInsert.executeUpdate();

                // Determine the CSS class for highlighting
                String userAnswerClass = "";
                String correctAnswerClass = "";
                if (userAnswer.equalsIgnoreCase(correctAnswer)) {
                    correctAnswerClass = "correct"; // Correct answer highlights
                } else {
                    userAnswerClass = "wrong"; // Wrong answer highlights
                }
                
                // Highlight user's selected answer
                if (!userAnswer.equalsIgnoreCase("No answer") && !userAnswerClass.equals("")) {
                    userAnswerClass = "user-selected " + userAnswerClass;
                } else if (userAnswer.equalsIgnoreCase("No answer")) {
                    userAnswerClass = "user-selected"; // Highlight 'No answer' too
                }

                // Fetch options for the current question
                String optionsSQL = "SELECT option_text FROM options WHERE question_id = ?";
                PreparedStatement psOptions = conn.prepareStatement(optionsSQL);
                psOptions.setInt(1, questionId);
                ResultSet rsOptions = psOptions.executeQuery();

                // Store options in a list for rendering
                StringBuilder optionsBuilder = new StringBuilder();
                while (rsOptions.next()) {
                    String optionText = rsOptions.getString("option_text");
                    optionsBuilder.append(optionText).append("<br/>"); // Use <br/> for new lines
                }

                // Show the question, user's answer, correct answer, and options
                out.println("<tr>");
                out.println("<td>" + questionText + "</td>");
                out.println("<td class='" + userAnswerClass + "'>" + userAnswer + "</td>");
                
                if (showAnswers) {
                    out.println("<td class='" + correctAnswerClass + "'>" + correctAnswer + "</td>");
                } else {
                    out.println("<td>Hidden</td>");
                }

                // Display the options for the question
                out.println("<td class='options'>" + optionsBuilder.toString() + "</td>");
                out.println("</tr>");
                
                totalQuestions++;
                questionIndex++;
            }
            
            out.println("</table>");

            // Calculate percentage score
            float scorePercentage = (correctAnswers * 100.0f) / totalQuestions;

            out.println("<div class='score'>Your Score: " + correctAnswers + " out of " + totalQuestions + " (" + String.format("%.2f", scorePercentage) + "%)</div>");

                // Insert the test result
            if (session.getAttribute("username") != null) {
                String insertResultSQL = "INSERT INTO test_results (student_id, test_name,test_id , score, correct_answers, total_questions, attempt_date) VALUES (?, ?,?, ?, ?, ?, NOW())";
                PreparedStatement psInsertResult = conn.prepareStatement(insertResultSQL);
                psInsertResult.setString(1, session.getAttribute("username").toString());
                psInsertResult.setString(2, testName);  
                psInsertResult.setInt(3, testId);
                psInsertResult.setFloat(4, scorePercentage);
                psInsertResult.setInt(5, correctAnswers);
                psInsertResult.setInt(6, totalQuestions);
                psInsertResult.executeUpdate();
                psInsertResult.close();
            }
            
            
            
            if (!showAnswers) {
                out.println("<p>The correct answers will not be shown as per test settings.</p>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error processing your answers. Please try again later.</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>

</body>
</html>
