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
        /* Base Styling */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f9fafc;
            color: #333;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        h1 {
            text-align: center;
            font-size: 2rem;
            margin-top: 20px;
            color: #333;
        }
        .container {
            width: 90%;
            max-width: 800px;
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
        }
        .question {
            margin-bottom: 30px;
            border-bottom: 1px solid #ececec;
            padding-bottom: 15px;
        }
        .question h3 {
            font-size: 1.25rem;
            color: #4A4A4A;
        }
        .options label {
            display: block;
            padding: 8px 15px;
            background-color: #f4f4f4;
            margin-bottom: 10px;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.2s ease;
        }
        .options label:hover {
            background-color: #e2e8f0;
        }
        .options input[type="radio"] {
            margin-right: 10px;
        }
        .submit-btn {
            width: 100%;
            background-color: #007bff;
            color: white;
            padding: 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1.1rem;
            transition: background-color 0.3s ease;
        }
        .submit-btn:hover {
            background-color: #0056b3;
        }
        .timer {
            font-size: 1.5rem;
            text-align: center;
            margin-bottom: 20px;
            background-color: #f4f4f4;
            padding: 10px;
            border-radius: 5px;
            color: #444;
        }

        /* Responsive */
        @media (max-width: 600px) {
            .container {
                width: 95%;
            }
            .submit-btn {
                font-size: 1rem;
                padding: 12px;
            }
        }
    </style>
    <script>
        // Disable right-click context menu
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
        });

        // Function to enter fullscreen mode
        function enterFullscreen() {
            const elem = document.documentElement; // Select the entire document
            if (elem.requestFullscreen) {
                elem.requestFullscreen();
            } else if (elem.mozRequestFullScreen) { // Firefox
                elem.mozRequestFullScreen();
            } else if (elem.webkitRequestFullscreen) { // Chrome, Safari and Opera
                elem.webkitRequestFullscreen();
            } else if (elem.msRequestFullscreen) { // IE/Edge
                elem.msRequestFullscreen();
            }
        }

        // Attempt to enter fullscreen mode when the page loads
        document.addEventListener('DOMContentLoaded', function() {
            enterFullscreen(); // Try to enter fullscreen automatically
        });

        // Periodically check if the user is still focused on the test page
        setInterval(function() {
            if (document.hidden) {
                alert("You have minimized or switched tabs. Please stay focused on your test.");
            }
        }, 30000); // Check every 30 seconds

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

        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                alert("Please stay focused on your test.");
            }
        });
    </script>
</head>
<body>
    <h1>Test: <%= request.getParameter("testName") %></h1>

    <div class="container">
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
                    </label>
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
    </div>

    <script>
        // Start the timer with the duration fetched from the database
        startTimer(<%= durationInSeconds %>);
    </script>
</body>
</html>
