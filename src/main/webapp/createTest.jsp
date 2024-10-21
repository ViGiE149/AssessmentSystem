<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Test</title>
    <style>
        /* General Styles */
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
        
        
        
        
        
        .navbar {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: #ffffff;
            padding: 4px;
            text-align: right;
            position:fixed;
        }
        .navbar a {
            color: #ffffff;
            text-decoration: none;
            margin-left: 20px;
        }
        .container {
            display: flex;
            height: 100%; /* Adjust for navbar height */
        }
        .sidebar {
            width: 250px;
            height: 100vh;
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: #ffffff;
            padding: 20px;
            transition: transform 0.3s ease;
            transform: translateX(0); /* Sidebar visible by default */
        }
        .sidebar.closed {
            transform: translateX(-100%); /* Hide sidebar */
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
        .toggle-button {
            display: none;
            background: #343a40;
            color: #ffffff;
            border: none;
            padding: 10px;
            cursor: pointer;
            margin-left: 20px;
        }
        @media (max-width: 768px) {
            .toggle-button {
                display: inline-block;
            }
            .sidebar {
                position: absolute; /* Change to absolute for mobile */
                z-index: 1000; /* Ensure it overlaps the content */
            }
            .container {
                flex-direction: column; /* Stack content on mobile */
            }
            .content {
                padding: 20px;
            }
        }
        
        
        
        
    </style>
</head>
<body>
    <div class="navbar">
        <button class="toggle-button" onclick="toggleSidebar()"><i class="fas fa-bars"></i> Menu</button>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="container">
        <div class="sidebar" id="sidebar">
            <h2>Lecturer Menu</h2>
            <ul>
                <li><a href="#">Dashboard</a></li>
                <li><a href="createTest.jsp">Set Test</a></li>
                 <li><a href="testList.jsp">View Tests</a></li>
                <li><a href="activateTest.jsp">Activate Tests</a></li>
            </ul>
        </div>

        <div class="content">
    <form action="createTest" method="post">
        
        <input type="hidden" name="userId" value="<%= session.getAttribute("username") %>"> 
        
        
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
        
    </div>
    </div>

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
                    <input type="text" name="correctAnswer[]" /><br>
        
               

        
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
