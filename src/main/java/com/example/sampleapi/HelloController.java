
package com.example.sampleapi;

import java.time.Instant;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @Value("${APP_NAME:sample-api}")
    private String appName;

    @Value("${COLOR:unknown}")
    private String color;

    @Value("${ENV:local}")
    private String env;

    @GetMapping("/")
    public String hello() {
        return String.format("Hello from %s | env=%s | color=%s | ts=%s", appName, env, color, Instant.now());
    }
}
