package com.example.hellospring1520;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Hellospring1520Application {

	public static void main(String[] args) {
		SpringApplication.run(Hellospring1520Application.class, args);
	}

}

@RestController
class Controller {

	@GetMapping("/")
	public String hello() {
		return "Hello App Service";
	}

}