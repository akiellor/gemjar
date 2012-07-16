package gemjar;

import ch.qos.logback.access.jetty.RequestLogImpl;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.handler.RequestLogHandler;
import org.eclipse.jetty.webapp.WebAppContext;

import java.net.URL;
import java.security.ProtectionDomain;

public class WebServer {
    public static void main(String[] args){
        Server server = new Server(8080);

        ProtectionDomain domain = WebServer.class.getProtectionDomain();
        URL location = domain.getCodeSource().getLocation();

        HandlerCollection handlers = new HandlerCollection();

        RequestLogHandler requestLogHandler = new RequestLogHandler();
        RequestLogImpl requestLog = new RequestLogImpl();
        requestLog.setResource("/logback-access.xml");
        requestLogHandler.setRequestLog(requestLog);

        WebAppContext webapp = new WebAppContext();
        webapp.setContextPath("/");
        webapp.setDescriptor(location.toExternalForm() + "/WEB-INF/web.xml");
        webapp.setServer(server);
        webapp.setWar(location.toExternalForm());

        handlers.setHandlers(new Handler[]{requestLogHandler, webapp});
        server.setHandler(handlers);

        try {
            server.setStopAtShutdown(true);
            server.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
