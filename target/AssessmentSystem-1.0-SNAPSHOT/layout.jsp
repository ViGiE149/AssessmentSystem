<%-- 
    Document   : layout
    Created on : 21 Oct 2024, 18:32:32
    Author     : Admin
--%>

<!-- navbar.jsp -->
<div class="navbar">
    <button class="toggle-button" onclick="toggleSidebar()"><i class="fas fa-bars"></i> Menu</button>
    <a href="logout.jsp">Logout</a>
</div>

<div class="sidebar" id="sidebar">
    <h2>Lecturer Menu</h2>
    <ul>
        <li><a href="createTest.jsp">Set Test</a></li>
        <li><a href="testList.jsp">View Tests</a></li>
        <li><a href="activateTest.jsp">Activate Tests</a></li>
    </ul>
</div>

<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('closed');
    }
</script>
