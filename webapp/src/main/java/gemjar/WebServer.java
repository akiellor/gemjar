package gemjar;

import ch.qos.logback.access.jetty.RequestLogImpl;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.AbstractHandler;
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.handler.RequestLogHandler;
import org.eclipse.jetty.webapp.WebAppContext;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigInteger;
import java.net.URL;
import java.security.ProtectionDomain;
import java.security.SecureRandom;

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

        handlers.setHandlers(new Handler[]{new ThreadNamingHandler(), requestLogHandler, webapp});
        server.setHandler(handlers);

        try {
            server.setStopAtShutdown(true);
            server.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static class ThreadNamingHandler extends AbstractHandler implements Handler{
        @Override
        public void handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
            Thread.currentThread().setName(String.format("%s:%s", new TransactionId(), baseRequest.getPathInfo()));
        }
    }

    private static class TransactionId {
        private final String id;

        public TransactionId(){
            SecureRandom random = new SecureRandom();
            id = new BigInteger(50, random).toString(32).toUpperCase();
        }

        @Override public String toString(){
            return id;
        }
    }
}
