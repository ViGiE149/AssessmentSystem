import DatabaseConnection.DatabaseConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import DatabaseConnection.DatabaseConnection;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.IOException;
import java.io.OutputStream;


@WebServlet("/viewTestResultsServlet")
public class ViewTestResultsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String studentId = (String) session.getAttribute("username");
          int testId;
       
        if (studentId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        List<Map<String, String>> testResultsList = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection(); // Database connection utility
            testId = Integer.parseInt(request.getParameter("testId"));
            System.out.println("Test ID: " + testId);
            String sql = "SELECT test_name,test_id, score, correct_answers, total_questions, attempt_date " +
             "FROM test_results " +
             "WHERE test_id = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, testId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, String> resultMap = new HashMap<>();
                resultMap.put(" student_id", studentId);     
                resultMap.put("test_name", rs.getString("test_name"));
                   resultMap.put("test_id", rs.getString("test_id"));
                resultMap.put("score", rs.getString("score"));
                resultMap.put("correct_answers", rs.getString("correct_answers"));
                resultMap.put("total_questions", rs.getString("total_questions"));
                resultMap.put("attempt_date", rs.getTimestamp("attempt_date").toString());
                testResultsList.add(resultMap);
            }
            session.setAttribute("testResultsList", testResultsList);
            request.setAttribute("testResultsList", testResultsList);
            request.getRequestDispatcher("view_grades.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    HttpSession session = request.getSession();
    List<Map<String, String>> testResultsList = (List<Map<String, String>>) session.getAttribute("testResultsList");

    // Create Excel file
    Workbook workbook = new XSSFWorkbook();
    Sheet sheet = workbook.createSheet("Test Results");  
    
    System.out.println("Test Results List Size: " + testResultsList.size());

    // Create header row
    Row headerRow = sheet.createRow(0);
    String[] headers = {"Username", "Test Name", "Score", "Correct Answers", "Total Questions", "Attempt Date"};
    for (int i = 0; i < headers.length; i++) {
        headerRow.createCell(i).setCellValue(headers[i]);
    }

    // Populate data
    if (testResultsList != null && !testResultsList.isEmpty()) {
        for (int i = 0; i < testResultsList.size(); i++) {
            Map<String, String> result = testResultsList.get(i);
            Row row = sheet.createRow(i + 1);
            row.createCell(0).setCellValue(result.get("student_id"));
            row.createCell(1).setCellValue(result.get("test_name"));
            row.createCell(2).setCellValue(result.get("score"));
            row.createCell(3).setCellValue(result.get("correct_answers"));
            row.createCell(4).setCellValue(result.get("total_questions"));
            row.createCell(5).setCellValue(result.get("attempt_date"));
        }
    }

    // Set response type and headers
    response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
    response.setHeader("Content-Disposition", "attachment; filename=test_results.xlsx");

    // Write to response output stream
    try (OutputStream out = response.getOutputStream()) {
        workbook.write(out);
    } catch (IOException e) {
        e.printStackTrace();
    } finally {
        workbook.close();
    }
}
}