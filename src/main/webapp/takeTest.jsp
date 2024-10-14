<%@ page import="java.sql.*, java.util.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="DatabaseConnection.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Take Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            text-align: center;
        }
        .question {
            margin-bottom: 20px;
        }
        .options {
            margin-left: 20px;
        }
        .submit-btn {
            display: block;
            width: 100%;
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            border: none;
            cursor: pointer;
            text-align: center;
            margin-top: 20px;
        }
        .submit-btn:hover {
            background-color: #45a049;
        }
        .timer {
            font-size: 24px;
            text-align: center;
            margin-bottom: 20px;
        }
    </style>
    <script>
        // Timer variables
        var totalTimeInSeconds = 0;

        function startTimer(duration) {
            totalTimeInSeconds = duration;
            var timerDisplay = document.getElementById("timerDisplay");
            var timer = setInterval(function () {
                var minutes = parseInt(totalTimeInSeconds / 60, 10);
                var seconds = parseInt(totalTimeInSeconds % 60, 10);

                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;

                timerDisplay.textContent = minutes + ":" + seconds;

                if (totalTimeInSeconds <= 0) {
                    clearInterval(timer);
                    document.getElementById("testForm").submit(); // Automatically submit the form when time is up
                } else {
                    totalTimeInSeconds--; // Decrement the timer
                }
            }, 1000);
        }
    </script>
</head>
<body>
    <h1>Test: <%= request.getParameter("testName") %></h1>
    <div class="timer">
        Time Remaining: <span id="timerDisplay">00:00</span>
    </div>

    <form id="testForm" action="submitTest.jsp" method="post">
        <input type="hidden" name="testId" value="<%= request.getParameter("testId") %>">
        
        <%
            int testId = Integer.parseInt(request.getParameter("testId"));
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            int durationInSeconds = 0; // Initialize the variable to store duration

            try {
                conn = DatabaseConnection.getConnection();

                // Fetch test duration
                String testSql = "SELECT duration FROM tests WHERE id = ?";
                PreparedStatement testPs = conn.prepareStatement(testSql);
                testPs.setInt(1, testId);
                ResultSet testRs = testPs.executeQuery();

                int testDurationInMinutes = 0; // Duration in minutes
                if (testRs.next()) {
                    testDurationInMinutes = testRs.getInt("duration");
                    durationInSeconds = testDurationInMinutes * 60; // Convert to seconds
                }
                testRs.close();
                testPs.close();

                // Fetch questions for the test
                String sql = "SELECT * FROM questions WHERE test_id = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, testId);
                rs = ps.executeQuery();
                int questionNumber = 1;

                while (rs.next()) {
                    String questionText = rs.getString("question_text");
                    String questionType = rs.getString("question_type");
                    int questionId = rs.getInt("id");
        %>
        <div class="question">
            <h3>Question <%= questionNumber++ %>: <%= questionText %></h3>

            <% if (questionType.equals("multiple_choice")) { %>
            <div class="options">
                <%
                    // Fetch options for the current question
                    PreparedStatement optionStmt = conn.prepareStatement("SELECT * FROM options WHERE question_id = ?");
                    optionStmt.setInt(1, questionId);
                    ResultSet optionRs = optionStmt.executeQuery();

                    while (optionRs.next()) {
                        String optionText = optionRs.getString("option_text");
                %>
                <label>
                    <input type="radio" name="question_<%= questionId %>" value="<%= optionText %>"> <%= optionText %>
                </label><br>
                <% } %>
            </div>
            <% } else if (questionType.equals("true_false")) { %>
            <div class="options">
                <label>
                    <input type="radio" name="question_<%= questionId %>" value="true"> True
                </label><br>
                <label>
                    <input type="radio" name="question_<%= questionId %>" value="false"> False
                </label>
            </div>
            <% } %>
        </div>
        <% 
                } 
            } catch (SQLException e) { 
                e.printStackTrace(); 
            } finally { 
                if (rs != null) rs.close(); 
                if (ps != null) ps.close(); 
                if (conn != null) conn.close(); 
            } 
        %>

        <button type="submit" class="submit-btn">Submit Test</button>
    </form>

    <script>
        // Start the timer with the duration fetched from the database
        startTimer(<%= durationInSeconds %>);
    </script>
</body>
</html>
