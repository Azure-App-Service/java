package com.microsoft.appservice.microprofile;

import javax.enterprise.context.ApplicationScoped;
import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

@ApplicationPath("/")
@ApplicationScoped
public class MicroprofileRestApplication extends Application {

}
