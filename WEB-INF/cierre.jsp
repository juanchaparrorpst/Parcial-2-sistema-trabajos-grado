<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Cierra lo que abre /WEB-INF/menu.jsp. Se incluye al final de cada
    pagina con <jsp:include page="/WEB-INF/cierre.jsp" />.
--%>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/modal-detalle.jsp" />

<script src="${pageContext.request.contextPath}/js/menu.js"></script>
<script src="${pageContext.request.contextPath}/js/tabla.js"></script>
<script src="${pageContext.request.contextPath}/js/modal.js"></script>
<script src="${pageContext.request.contextPath}/js/app.js"></script>
</body>
</html>
