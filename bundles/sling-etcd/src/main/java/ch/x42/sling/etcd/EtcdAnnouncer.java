package ch.x42.sling.etcd;

import java.net.MalformedURLException;
import java.util.Map;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.apache.commons.httpclient.methods.multipart.StringPart;
import org.apache.felix.scr.annotations.Activate;
import org.apache.felix.scr.annotations.Component;
import org.apache.felix.scr.annotations.ConfigurationPolicy;
import org.apache.felix.scr.annotations.Deactivate;
import org.apache.felix.scr.annotations.Property;
import org.apache.sling.commons.osgi.PropertiesUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** Announces a Sling instance to etcd via HTTP */
@Component(
        metatype=true,
        configurationFactory=true,
        policy=ConfigurationPolicy.REQUIRE)
public class EtcdAnnouncer implements Runnable {
    private final Logger log = LoggerFactory.getLogger(getClass());
    
    private HttpClient httpClient;
    
    @Property
    public static final String PROP_ETCD_URL = "etcd.url";
    private String etcdUrl;
    
    @Property
    public static final String PROP_SLING_HOST = "sling.host";
    
    @Property
    public static final String PROP_SLING_PORT = "sling.port";
    private String slingHostPort;
    
    @Property
    public static final String PROP_INTERVAL_SECONDS = "interval.seconds";
    private int announceInterval;
    
    @Property
    public static final String PROP_TTL_SECONDS = "ttl.seconds";
    private int ttlSeconds;
    
    boolean running;
    Thread announceThread;
    
    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName())
        .append(": ")
        .append(slingHostPort)
        .append(", interval=")
        .append(announceInterval)
        .append(", etcd TTL=")
        .append(ttlSeconds);
        return sb.toString();
    }
    
    @Activate
    protected void activate(final Map<String, Object> config) throws MalformedURLException {
        etcdUrl = PropertiesUtil.toString(config.get(PROP_ETCD_URL), "NOTSET://ETCD_URL");
        slingHostPort = 
            PropertiesUtil.toString(config.get(PROP_SLING_HOST), "NOTSET:SLING_HOST")
            + ":"
            + PropertiesUtil.toString(config.get(PROP_SLING_PORT), "NOTSET:SLING_PORT")
        ;
        announceInterval = PropertiesUtil.toInteger(config.get(PROP_INTERVAL_SECONDS), 30);
        ttlSeconds = PropertiesUtil.toInteger(config.get(PROP_TTL_SECONDS), 15);
        
        httpClient = new HttpClient();
        
        running = true;
        announceThread = new Thread(this, "Announce thread for " + slingHostPort);
        announceThread.setDaemon(true);
        announceThread.start();
    }
    
    @Deactivate
    protected void deactivate(final Map<String, Object> config) throws MalformedURLException {
        running = false;
        announceThread = null;
    }
    
    public void run() {
        log.info("{} starting: {}", Thread.currentThread().getName(), this);
        while(running) {
            announce();
            try {
                Thread.sleep(announceInterval * 1000L);
            } catch(InterruptedException iex) {
                log.warn("Interrupted, announce canceled");
                running = false;
            }
        }
        httpClient = null;
    }
    
    public void announce() {
        // curl -s -XPUT -d value="192.168.59.103:$PORT" -d ttl=$TTL http://$HOST_IP:4001/v2/keys/http/backends/sling$PORT;
        final PutMethod put = new PutMethod(etcdUrl);
        final NameValuePair [] params = {
                new NameValuePair("value", slingHostPort),
                new NameValuePair("ttl", String.valueOf(ttlSeconds))
        };
        put.setQueryString(params);
        log.info("Announcing {} with TTL {} to {}", new Object[] { slingHostPort, ttlSeconds, etcdUrl });
        try {
            final int status = httpClient.executeMethod(put);
            if(status != 200 && status != 201) {
                log.warn("PUT failed, status={}", status);
            }
        } catch (Exception e) {
            log.warn("HTTP request failed:" + put, e);
        }
    }
}