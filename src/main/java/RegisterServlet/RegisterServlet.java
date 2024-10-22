package RegisterServlet;

import models.User;
import services.UserService;
import services.UserServiceImpl;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserService userService = new UserServiceImpl();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get form data
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String role = request.getParameter("role");

        User user = new User(username, password, email, role);
        boolean isRegistered = userService.registerUser(user);
        
        if (isRegistered) {
            // Registration successful, redirect to login page
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("message", "Registration failed. Try again!");
            request.getRequestDispatcher("registration.jsp").forward(request, response);
        }
    }
}
