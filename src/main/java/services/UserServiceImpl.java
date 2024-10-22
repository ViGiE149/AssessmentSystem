/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author Admin
 */
package services;

import DatabaseConnection.DatabaseConnection;
import models.User;
import RegisterServlet.HashUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserServiceImpl implements UserService {

    @Override
    public boolean registerUser(User user) {
        String encryptedPassword = HashUtil.hashPassword(user.getPassword());
        try (Connection connection = DatabaseConnection.getConnection()) {
            String sql = "INSERT INTO users (username, password, email, role) VALUES (?, ?, ?, ?)";
            PreparedStatement statement = connection.prepareStatement(sql);
            statement.setString(1, user.getUsername());
            statement.setString(2, encryptedPassword);
            statement.setString(3, user.getEmail());
            statement.setString(4, user.getRole());

            int result = statement.executeUpdate();
            return result > 0; // return true if registration is successful
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false; // registration failed
        }
    }

    @Override
    public User loginUser(String username, String password) {
        String hashedPassword = HashUtil.hashPassword(password);
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement("SELECT * FROM users WHERE username = ?")) {

            statement.setString(1, username);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    String storedPassword = resultSet.getString("password");
                    if (storedPassword.equals(hashedPassword)) {
                        String role = resultSet.getString("role");
                        return new User(username, storedPassword, resultSet.getString("email"), role);
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null; // return null if login fails
    }
}
