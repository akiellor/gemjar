package gemjar;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.webapp.WebAppContext;

import java.net.URL;
import java.security.ProtectionDomain;

public class WebServer {
    public static void main(String[] args){
        Server server = new Server(8080);

        ProtectionDomain domain = WebServer.class.getProtectionDomain();
        URL location = domain.getCodeSource().getLocation();

        WebAppContext webapp = new WebAppContext();
        webapp.setContextPath("/");
        webapp.setDescriptor(location.toExternalForm() + "/WEB-INF/web.xml");
        webapp.setServer(server);
        webapp.setWar(location.toExternalForm());
        server.setHandler(webapp);

        try {
            server.setStopAtShutdown(true);
            server.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
