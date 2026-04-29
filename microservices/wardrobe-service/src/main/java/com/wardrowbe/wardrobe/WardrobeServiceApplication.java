package com.wardrowbe.wardrobe;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.wardrowbe.wardrobe", "com.wardrowbe.common"})
@EnableDiscoveryClient
public class WardrobeServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(WardrobeServiceApplication.class, args);
    }
}
