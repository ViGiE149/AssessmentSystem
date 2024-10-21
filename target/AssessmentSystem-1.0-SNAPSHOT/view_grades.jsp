<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Test Results</title>
    <style>
        table {
            width: 70%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 10px;
            text-align: center;
        }
        th {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
        }
        
        
        
         
        .navbar {
            background: linear-gradient(to right, #4e54c8, #8f94fb);
            color: #ffffff;
            padding: 9px;
            text-align: right;
         
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
            height: 100%;
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
                <li><a href="lecturerDashboard.jsp">Dashboard</a></li>
                <li><a href="createTest.jsp">Set Test</a></li>
                 <li><a href="testList.jsp">View Tests</a></li>
                <li><a href="activateTest.jsp">Activate Tests</a></li>
            </ul>
        </div>

        <div class="content">
    
    
    <h1>Your Test Results</h1>

    <%
        List<Map<String, String>> testResultsList = (List<Map<String, String>>) request.getAttribute("testResultsList");
        if (testResultsList != null && !testResultsList.isEmpty()) {
    %>
   <form action="viewTestResultsServlet" method="post">
         
         <button type="submit">Download Test Results</button>
    </form>

    <table>
        <thead>
            <tr>
                <th>username</th>
                <th>Test Name</th>
                <th>Score</th>
                <th>Correct Answers</th>
                <th>Total Questions</th>
                <th>Attempt Date</th>
            </tr>
        </thead>
        <tbody>
        <%
            for (Map<String, String> result : testResultsList) {
        %>
            <tr>
                <td><%= result.get("student_id") %></td>
                <td><%= result.get("test_name") %></td>
                <td><%= result.get("score") %></td>
                <td><%= result.get("correct_answers") %></td>
                <td><%= result.get("total_questions") %></td>
                <td><%= result.get("attempt_date") %></td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    <%
        } else {
    %>
        <p>No test results available.</p>
    <%
        }
    %>
    
     </div>
    </div>

</body>
</html>
