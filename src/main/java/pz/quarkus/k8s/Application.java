package pz.quarkus.k8s;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@Path("/quarkusk8s")
public class Application {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        return "abc";
    }
}