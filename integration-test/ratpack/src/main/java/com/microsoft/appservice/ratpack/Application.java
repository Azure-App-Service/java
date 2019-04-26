package com.microsoft.appservice.ratpack;

import ratpack.server.RatpackServer;
import ratpack.server.ServerConfig;


public class Application {

    public static void main(String args[]) throws Exception {
        RatpackServer.start(server -> {
            int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
            server.serverConfig(ServerConfig.embedded().port(port));
            server.handlers(chain -> {
                chain.get("", ctx -> {
                    ctx.header("Content-type: text/plain");
                    ctx.render("Hello App Service");
                });
            });
        });
    }

}
