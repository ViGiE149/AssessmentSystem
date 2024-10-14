<%-- 
    Document   : setTest
    Created on : 10 Oct 2024, 13:36:20
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set Test</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="styles.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .navbar {
            background: #343a40;
            color: #ffffff;
            padding: 15px;
            text-align: right;
        }
        .navbar a {
            color: #ffffff;
            text-decoration: none;
            margin-left: 20px;
        }
        .container {
            display: flex;
            height: calc(100vh - 60px); /* Adjust for navbar height */
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background: #343a40;
            color: #ffffff;
            padding: 20px;
        }
        .sidebar h2 {
            text-align: center;
        }
        .sidebar ul {
            list-style-type: none;
            padding: 0;
        }
        .sidebar ul li {
            padding: 10px;
            border-bottom: 1px solid #495057;
        }
        .sidebar ul li a {
            color: #ffffff;
            text-decoration: none;
        }
        .sidebar ul li a:hover {
            background: #495057;
        }
        .content {
            flex: 1;
            padding: 20px;
            background: #ffffff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #343a40;
        }
        form {
            display: flex;
            flex-direction: column;
        }
        label {
            margin: 10px 0 5px;
        }
        input, select, textarea {
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #343a40;
            color: #ffffff;
            border: none;
            padding: 10px;
            cursor: pointer;
            border-radius: 4px;
        }
        button:hover {
            background-color: #495057;
        }
    </style>
</head>
<body>
    <h2>Set Test</h2>
    <form action="SubmitTestServlet" method="post">
        <label for="testName">Test Name:</label>
        <input type="text" id="testName" name="testName" required><br><br>

        <label for="subject">Subject:</label>
        <input type="text" id="subject" name="subject" required><br><br>

        <label for="date">Date:</label>
        <input type="date" id="date" name="date" required><br><br>

        <label for="duration">Duration (minutes):</label>
        <input type="number" id="duration" name="duration" required><br><br>

        <label for="testPin">Test PIN:</label>
        <input type="text" id="testPin" name="testPin" required><br><br>

        <label for="showAnswers">Show Answers to Students?</label>
        <select id="showAnswers" name="showAnswers">
            <option value="yes">Yes</option>
            <option value="no">No</option>
        </select><br><br>

        <label for="instructions">Instructions:</label><br>
        <textarea id="instructions" name="instructions" rows="4" cols="50" required></textarea><br><br>

        <h3>Add Questions</h3>
        <div id="questionContainer">
            <div class="question">
                <label for="questionText_1">Question 1:</label><br>
                <textarea id="questionText_1" name="questionText_1" rows="2" cols="50" required></textarea><br><br>

                <label for="questionType_1">Question Type:</label>
                <select id="questionType_1" name="questionType_1" onchange="toggleAnswerOptions(1)" required>
                    <option value="multipleChoice">Multiple-Choice</option>
                    <option value="trueFalse">True/False</option>
                </select><br><br>

                <div id="answerOptions_1">
                    <div id="multipleChoice_1" class="multipleChoice">
                        <label>Options:</label><br>
                        <input type="text" name="option_1_1" placeholder="Option 1"><br>
                        <input type="text" name="option_1_2" placeholder="Option 2"><br>
                        <input type="text" name="option_1_3" placeholder="Option 3"><br>
                        <input type="text" name="option_1_4" placeholder="Option 4"><br><br>

                        <label for="correctOption_1">Correct Option:</label>
                        <input type="number" id="correctOption_1" name="correctOption_1" min="1" max="4" required><br><br>
                    </div>

                    <div id="trueFalse_1" class="trueFalse" style="display:none;">
                        <label for="correctAnswer_1">Correct Answer:</label>
                        <select id="correctAnswer_1" name="correctAnswer_1">
                            <option value="true">True</option>
                            <option value="false">False</option>
                        </select><br><br>
                        <hr>
                    </div>
                </div>
            </div>
        </div>

        <button type="button" onclick="addQuestion()">Add Another Question</button><br><br>
        <button type="submit">Submit Test</button>
    </form>

    <script>
        let questionCount = 1;

        function toggleAnswerOptions(questionNumber) {
            const questionType = document.getElementById('questionType_' + questionNumber).value;
            if (questionType === 'multipleChoice') {
                document.getElementById('multipleChoice_' + questionNumber).style.display = 'block';
                document.getElementById('trueFalse_' + questionNumber).style.display = 'none';
            } else {
                document.getElementById('multipleChoice_' + questionNumber).style.display = 'none';
                document.getElementById('trueFalse_' + questionNumber).style.display = 'block';
            }
        }

        function addQuestion() {
            questionCount++;
            const questionContainer = document.getElementById('questionContainer');
            const questionDiv = document.createElement('div');
            questionDiv.className = 'question';
            questionDiv.innerHTML = `
                <label for="questionText_${questionCount}">Question ${questionCount}:</label><br>
                <textarea id="questionText_${questionCount}" name="questionText_${questionCount}" rows="2" cols="50" required></textarea><br><br>

                <label for="questionType_${questionCount}">Question Type:</label>
                <select id="questionType_${questionCount}" name="questionType_${questionCount}" onchange="toggleAnswerOptions(${questionCount})" required>
                    <option value="multipleChoice">Multiple-Choice</option>
                    <option value="trueFalse">True/False</option>
                </select><br><br>

                <div id="answerOptions_${questionCount}">
                    <div id="multipleChoice_${questionCount}" class="multipleChoice">
                        <label>Options:</label><br>
                        <input type="text" name="option_${questionCount}_1" placeholder="Option 1"><br>
                        <input type="text" name="option_${questionCount}_2" placeholder="Option 2"><br>
                        <input type="text" name="option_${questionCount}_3" placeholder="Option 3"><br>
                        <input type="text" name="option_${questionCount}_4" placeholder="Option 4"><br><br>

                        <label for="correctOption_${questionCount}">Correct Option:</label>
                        <input type="number" id="correctOption_${questionCount}" name="correctOption_${questionCount}" min="1" max="4" required><br><br>
                    </div>

                    <div id="trueFalse_${questionCount}" class="trueFalse" style="display:none;">
                        <label for="correctAnswer_${questionCount}">Correct Answer:</label>
                        <select id="correctAnswer_${questionCount}" name="correctAnswer_${questionCount}">
                            <option value="true">True</option>
                            <option value="false">False</option>
                        </select><br><br>
                    </div>
                </div>
            `;
            questionContainer.appendChild(questionDiv);
        }
    </script>
</body>
</html>
