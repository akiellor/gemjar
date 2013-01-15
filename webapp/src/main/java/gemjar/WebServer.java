package gemjar;

import com.google.common.io.CharStreams;
import com.google.common.io.Files;
import gemjar.internal.InternalClient;
import org.eclipse.jetty.server.*;
import org.eclipse.jetty.server.handler.AbstractHandler;
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.nio.SelectChannelConnector;
import org.eclipse.jetty.servlet.ServletContextHandler;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigInteger;
import java.security.SecureRandom;

public class WebServer {
    private final Server server;

    public static void main(String[] args) throws IOException {
        new WebServer().stopAtShutdown().selectChannelConnector().start();
    }

    public WebServer() throws IOException {
        server = new Server();

        ServletContextHandler webapp = new ServletContextHandler();
        webapp.setInitParameter("rackup", CharStreams.toString(new InputStreamReader(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.ru"))));
        webapp.setResourceBase(Files.createTempDir().getCanonicalPath());
        webapp.addServlet(org.jruby.rack.RackServlet.class, "/*");
        webapp.addEventListener(new org.jruby.rack.RackServletContextListener());

        HandlerCollection handlers = new HandlerCollection();

        handlers.setHandlers(new Handler[]{new ThreadNamingHandler(), webapp});
        server.setHandler(handlers);
    }

    public LocalConnectorWebServer localConnector() {
        LocalConnector connector = new LocalConnector();
        server.setConnectors(new Connector[]{connector});
        return new LocalConnectorWebServer(this, connector);
    }

    public WebServer selectChannelConnector() {
        Connector connector = new SelectChannelConnector();
        connector.setPort(8080);
        server.setConnectors(new Connector[]{connector});
        return this;
    }

    public WebServer start() {
        try {
            server.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return this;
    }

    public WebServer stop(){
        try {
            server.stop();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return this;
    }

    public WebServer stopAtShutdown() {
        server.setStopAtShutdown(true);
        return this;
    }

    private static class ThreadNamingHandler extends AbstractHandler implements Handler {
        @Override
        public void handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
            Thread.currentThread().setName(new TransactionId().toString());
        }
    }

    private static class TransactionId {
        private final String id;

        public TransactionId() {
            SecureRandom random = new SecureRandom();
            id = new BigInteger(50, random).toString(32).toUpperCase();
        }

        @Override public String toString() {
            return id;
        }
    }

    public static class LocalConnectorWebServer {
        private final WebServer webServer;
        private final LocalConnector connector;

        public LocalConnectorWebServer(WebServer webServer, LocalConnector connector){
            this.webServer = webServer;
            this.connector = connector;
        }

        public LocalConnectorWebServer start(){
            webServer.start();
            return this;
        }

        public LocalConnectorWebServer stop(){
            webServer.stop();
            return this;
        }

        public InternalClient getClient(){
            return new InternalClient(connector);
        }
    }
}
