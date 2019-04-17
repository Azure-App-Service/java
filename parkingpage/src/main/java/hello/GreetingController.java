package hello;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class GreetingController {

    @GetMapping("/")
    public String parking(Model model) {
        model.addAttribute("javaVersion", System.getProperty("java.version"));
        model.addAttribute("javaHome", System.getProperty("java.home"));
        return "parking";
    }

}
