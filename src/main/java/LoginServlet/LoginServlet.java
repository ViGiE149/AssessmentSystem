package LoginServlet;

import DatabaseConnection.DatabaseConnection;
import RegisterServlet.HashUtil;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(urlPatterns = {"/LoginServlet"}) // Changed URL pattern
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
          String hashedPassword = HashUtil.hashPassword(password);

        try (Connection connection = DatabaseConnection.getConnection();
    
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM users WHERE username = ?")) {

            statement.setString(1, username);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    String storedPassword = resultSet.getString("password");
                         
                    if (storedPassword.equals(hashedPassword)) {
                        String role = resultSet.getString("role");
                        HttpSession session = request.getSession();
                        session.setAttribute("username", username);
                        session.setAttribute("role", role);

                        if ("Lecturer".equalsIgnoreCase(role)) {
                            response.sendRedirect("lecturerDashboard.jsp");
                        } else if ("Student".equalsIgnoreCase(role)) {
                            response.sendRedirect("studentDashboard.jsp");
                        } else {
                            request.setAttribute("errorMessage", "Role not recognized");
                            request.getRequestDispatcher("login.jsp").forward(request, response);
                        }
                    } else {
                        request.setAttribute("errorMessage", "Invalid username or password");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("errorMessage", "Invalid username or password");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
             e.printStackTrace(); // This will print the stack trace to the console
             request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
             request.getRequestDispatcher("login.jsp").forward(request, response);
         }

    }
}
