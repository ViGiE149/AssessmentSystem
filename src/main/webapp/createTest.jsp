<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Test</title>
    <style>
        /* General Styles */
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f9;
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
    <form action="createTest" method="post">
        <h3>Create a New Test</h3>
        <label>Test Name:</label>
        <input type="text" name="testName" required /><br>

        <label>Test Duration:</label>
        <div>
            <input type="number" name="durationHours" min="0" required placeholder="Hours" style="width: 48%; display: inline-block;"/>
            <input type="number" name="durationMinutes" min="0" max="59" required placeholder="Minutes" style="width: 48%; display: inline-block;"/>
        </div><br>

        <label>Test Date:</label>
        <input type="date" name="testDate" required /><br>

        <label>Latest PIN:</label>
        <input type="text" name="latestPin" required /><br>

        <label>
            <input type="checkbox" name="showAnswers" />
            Show answers at the end
        </label><br>

        <h4>Questions</h4>
        <div id="questions-container">
            <div class="question">
                <label>Question Text:</label>
                <textarea name="questions" required></textarea><br>

                <label>Question Type:</label>
                <select name="questionTypes" onchange="toggleQuestionOptions(this)">
                    <option value="multiple_choice">Multiple Choice</option>
                    <option value="true_false">True/False</option>
                </select><br>

                <div class="options-container" style="display: block;">
                    <h5>Enter Options for Multiple Choice</h5>
                    <label>Option 1:</label>
                    <input type="text" name="option1[]" /><br>
                    <label>Option 2:</label>
                    <input type="text" name="option2[]" /><br>
                    <label>Option 3:</label>
                    <input type="text" name="option3[]" /><br>
                    <label>Option 4:</label>
                    <input type="text" name="option4[]" /><br>
                    <label>Correct Answer (Option Number):</label>
                    <input type="text" name="correctAnswer" /><br>
                </div>

                <div class="true-false-container" style="display: none;">
                    <label>Correct Answer:</label>
                    <select name="correctAnswer">
                        <option value="true">True</option>
                        <option value="false">False</option>
                    </select><br>
                </div>
            </div>
        </div>

        <button type="button" onclick="addQuestion()">Add Another Question</button><br><br>
        <input type="submit" value="Create Test" />
    </form>

    <script>
        function addQuestion() {
            var container = document.getElementById('questions-container');
            var newQuestion = document.createElement('div');
            newQuestion.classList.add('question');
            newQuestion.innerHTML = `
                <label>Question Text:</label>
                <textarea name="questions" required></textarea><br>
                
                <label>Question Type:</label>
                <select name="questionTypes" onchange="toggleQuestionOptions(this)">
                    <option value="multiple_choice">Multiple Choice</option>
                    <option value="true_false">True/False</option>
                </select><br>

                <div class="options-container" style="display: block;">
                    <h5>Enter Options for Multiple Choice</h5>
                    <label>Option 1:</label>
                    <input type="text" name="option1[]" /><br>
                    <label>Option 2:</label>
                    <input type="text" name="option2[]" /><br>
                    <label>Option 3:</label>
                    <input type="text" name="option3[]" /><br>
                    <label>Option 4:</label>
                    <input type="text" name="option4[]" /><br>
                    <label>Correct Answer (Option Number):</label>
                    <input type="text" name="correctAnswer" /><br>
                </div>

                <div class="true-false-container" style="display: none;">
                    <label>Correct Answer:</label>
                    <select name="correctAnswer">
                        <option value="true">True</option>
                        <option value="false">False</option>
                    </select><br>
                </div>
            `;
            container.appendChild(newQuestion);
        }

        function toggleQuestionOptions(select) {
            var optionsContainer = select.closest('.question').querySelector('.options-container');
            var trueFalseContainer = select.closest('.question').querySelector('.true-false-container');

            if (select.value === 'multiple_choice') {
                optionsContainer.style.display = 'block';
                trueFalseContainer.style.display = 'none';

                // Add required attribute to multiple choice options
                optionsContainer.querySelectorAll('input').forEach(input => {
                    input.required = true;
                });
                trueFalseContainer.querySelector('select').required = false;
            } else {
                optionsContainer.style.display = 'none';
                trueFalseContainer.style.display = 'block';

                // Remove required from multiple choice options and add it to true/false answer
                optionsContainer.querySelectorAll('input').forEach(input => {
                    input.required = false;
                });
                trueFalseContainer.querySelector('select').required = true;
            }
        }
    </script>
</body>
</html>
