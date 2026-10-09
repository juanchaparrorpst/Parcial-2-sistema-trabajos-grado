<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Cierra lo que abre /WEB-INF/menu.jsp. Se incluye al final de cada
    pagina con <jsp:include page="/WEB-INF/cierre.jsp" />.

    El "?v=" al final de cada <script>/<link> es para que el navegador no
    se quede sirviendo una copia vieja de el cache cuando el archivo
    cambia (paso horas depurando esto en el Prompt 2.1: el archivo en el
    servidor ya estaba corregido, pero el navegador seguia ejecutando la
    version anterior). Subir este numero cada vez que se edite algun CSS
    o JS compartido.
--%>
        </main>
    </div>
</div>

<jsp:include page="/WEB-INF/modal-detalle.jsp" />

<script src="${pageContext.request.contextPath}/js/menu.js?v=2"></script>
<script src="${pageContext.request.contextPath}/js/tabla.js?v=2"></script>
<script src="${pageContext.request.contextPath}/js/modal.js?v=2"></script>
<script src="${pageContext.request.contextPath}/js/app.js?v=2"></script>
</body>
</html>
