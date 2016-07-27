<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.leeward.wedding.sdk.JSPErrorHandler" isErrorPage="true" %>
<%@page import="com.leeward.wedding.constants.AppConstants"%>
<%
	String dateTime = JSPErrorHandler.error(request, exception);
%>

<div class="page-header padding-top-xl error-page-header">
<h1>Something's Wrong!</h1>
</div>
<div class="form-container padding-bottom-sm padding-top-sm error-page-form-container color-black">
<p>It looks as though we've broken something on our system.</p> 
<p>Not to worry!  Our wonderful staff has been notified of this and will get 
on fixing the problem real soon!</p>
	<div class="row">
		<div class="col-md-12">
			Return to our <a href="${pageContext.request.contextPath}/">Homepage &raquo;</a>
		</div>
	</div>
<hr/>
<%--<p>Error description: <em><%=exception.getClass().getName()%></em></p> --%>
<p class="error">Error code: <strong><%=dateTime%></strong></p>
</div>