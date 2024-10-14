<%-- 
    Document   : logout.jsp
    Created on : 10 Oct 2024, 13:07:10
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% 
    // Invalidate the session
//    HttpSession session = request.getSession(false);
    if (session != null) {
        session.invalidate(); // Remove user session
    }
    // Redirect to login page
    response.sendRedirect("login.jsp");
%>
