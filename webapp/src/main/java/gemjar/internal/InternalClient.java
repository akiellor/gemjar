package gemjar.internal;

import com.google.common.io.ByteStreams;
import org.eclipse.jetty.io.ByteArrayBuffer;
import org.eclipse.jetty.server.LocalConnector;
import org.eclipse.jetty.testing.HttpTester;

import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

public class InternalClient {
    private final LocalConnector connector;

    public InternalClient(LocalConnector connector) {
        this.connector = connector;
    }

    public Response get(String url) throws Exception {
        HttpTester httpTester = new HttpTester();
        httpTester.setMethod("GET");
        httpTester.setURI(url);
        httpTester.setHeader("Host", "localhost");

        ByteArrayBuffer jettyResponse = connector.getResponses(new ByteArrayBuffer(httpTester.generate()), false);

        HttpTester response = new HttpTester();
        response.parse(jettyResponse.array());

        Map<String, String> headers = new HashMap<String, String>();
        Enumeration headerNames = response.getHeaderNames();
        while(headerNames.hasMoreElements()){
            String header = (String) headerNames.nextElement();
            headers.put(header, response.getHeader(header));
        }

        byte[] content = response.getContentBytes() == null ? new byte[]{} : response.getContentBytes();

        return new Response(response.getStatus(), headers, new ByteArrayInputStream(content));
    }

    public static class Response{
        private final Integer status;
        private final Map<String, String> headers;
        private final InputStream content;

        public Response(Integer status, Map<String, String> headers, InputStream content){
            this.status = status;
            this.headers = headers;
            this.content = content;
        }

        public Integer getStatus() {
            return status;
        }

        public Map<String, String> getHeaders() {
            return headers;
        }

        public InputStream getContent() {
            return content;
        }

        public void dump(String path) throws IOException {
            FileOutputStream out = new FileOutputStream(path);
            ByteStreams.copy(content, out);
            out.flush();
            out.close();
        }
    }
}
