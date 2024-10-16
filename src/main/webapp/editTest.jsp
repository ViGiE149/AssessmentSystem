<%-- 
    Document   : editTest
    Created on : 16 Oct 2024, 15:53:18
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Test</title>
    <style>
        /* Same styles as createTest.jsp */   /* General Styles */
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            margin: 0;
            padding: 20px;
        }

        h3, h4, h5 {
            color: #333;
        }

        form {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            margin: auto;
        }

        label {
            font-weight: bold;
            margin-top: 10px;
            display: block;
            color: #333;
        }

        input[type="text"], input[type="number"], input[type="date"], textarea, select {
            width: calc(100% - 22px);
            padding: 10px;
            margin: 5px 0 15px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 16px;
        }

        textarea {
            height: 100px;
            resize: vertical;
        }

        input[type="checkbox"] {
            margin-right: 10px;
        }

        .question, .options-container, .true-false-container {
            margin-bottom: 20px;
        }

        button, input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        button:hover, input[type="submit"]:hover {
            background-color: #45a049;
        }

        button {
            display: inline-block;
            margin-top: 10px;
        }

        .options-container, .true-false-container {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 5px;
            border: 1px solid #ddd;
        }

        .options-container h5 {
            margin-top: 0;
        }
    </style>
</head>
<body>
   <form action="EditTestServlet" method="post">
        <input type="hidden" name="testId" value="<%= request.getAttribute("testId") %>">
        
        <h3>Edit Test</h3>
        <label>Test Name:</label>
        <input type="text" name="testName" value="<%= request.getAttribute("testName") %>" required /><br>

        <label>Test Duration:</label>
        <div>
            <input type="number" name="durationHours" min="0" value="<%= request.getAttribute("durationHours") %>" required placeholder="Hours" style="width: 48%; display: inline-block;"/>
            <input type="number" name="durationMinutes" min="0" max="59" value="<%= request.getAttribute("durationMinutes") %>" required placeholder="Minutes" style="width: 48%; display: inline-block;"/>
        </div><br>

        <label>Test Date:</label>
        <input type="date" name="testDate" value="<%= request.getAttribute("testDate") %>" required /><br>

        <label>Latest PIN:</label>
        <input type="text" name="latestPin" value="<%= request.getAttribute("latestPin") %>" required /><br>

        <label>
            <input type="checkbox" name="showAnswers" <%= request.getAttribute("showAnswers") != null ? "checked" : "" %> />
            Show answers at the end
        </label><br>

        <h4>Questions</h4>
        <div id="questions-container">
            <% 
            String[] questions = (String[]) request.getAttribute("questions");
            String[] questionTypes = (String[]) request.getAttribute("questionTypes");
            String[] correctAnswers = (String[]) request.getAttribute("correctAnswers");
            String[][] options = (String[][]) request.getAttribute("options");

            for (int i = 0; i < questions.length; i++) { 
            %>
                <div class="question">
                    <label>Question Text:</label>
                    <textarea name="questions" required><%= questions[i] %></textarea><br>

                    <label>Question Type:</label>
                    <select name="questionTypes" onchange="toggleQuestionOptions(this)">
                        <option value="multiple_choice" <%= questionTypes[i].equals("multiple_choice") ? "selected" : "" %>>Multiple Choice</option>
                        <option value="true_false" <%= questionTypes[i].equals("true_false") ? "selected" : "" %>>True/False</option>
                    </select><br>

                    <div class="options-container" style="<%= questionTypes[i].equals("multiple_choice") ? "display: block;" : "display: none;" %>">
                        <h5>Enter Options for Multiple Choice</h5>
                        <% 
                        if (options[i] != null) {
                            for (int j = 0; j < 4; j++) { 
                        %>
                            <label>Option <%= j + 1 %>:</label>
                            <input type="text" name="option<%= i %>_<%= j + 1 %>" 
                                   value="<%= j < options[i].length ? options[i][j] : "" %>" /><br>
                        <% 
                            }
                        } else { 
                        %>
                            <label>No options available for this question.</label><br>
                        <% 
                        } 
                        %>
                        <label>Correct Answer (Option Number):</label>
                        <input type="text" name="correctAnswer<%= i %>" value="<%= correctAnswers[i] %>" /><br>
                    </div>

                    <div class="true-false-container" style="<%= questionTypes[i].equals("true_false") ? "display: block;" : "display: none;" %>">
                        <label>Correct Answer:</label>
                        <select name="correctAnswer<%= i %>">
                            <option value="true" <%= correctAnswers[i].equals("true") ? "selected" : "" %>>True</option>
                            <option value="false" <%= correctAnswers[i].equals("false") ? "selected" : "" %>>False</option>
                        </select><br>
                    </div>
                </div>
            <% } %>
        </div>

        <button type="button" onclick="addQuestion()">Add Another Question</button><br><br>
        <input type="submit" value="Update Test" />
    </form>

    <script>
        function addQuestion() {
            // Similar JavaScript code as in createTest.jsp to add questions
        }

        function toggleQuestionOptions(select) {
            // Similar JavaScript code as in createTest.jsp
        }
    </script>
</body>
</html>
