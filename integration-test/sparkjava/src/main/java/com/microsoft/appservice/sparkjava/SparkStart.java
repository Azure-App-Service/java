package com.microsoft.appservice.sparkjava;

import static spark.Spark.get;
import static spark.Spark.port;

public class SparkStart {

    public static void main(String args[]) {
        port(8080);
        get("/", (req, res) -> {
            res.type("text/plain");
            return "Hello App Service";
        });
    }

}
