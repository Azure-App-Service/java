package hello;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class GreetingController {

    @GetMapping("/")
    public String parking(Model model) {
        model.addAttribute("javaVersion", System.getProperty("java.version"));
        model.addAttribute("javaVendor", System.getProperty("java.vendor"));
        model.addAttribute("osArch", System.getProperty("os.arch"));
        model.addAttribute("userTimeZone", System.getProperty("user.timezone"));
        return "parking";
    }

}
