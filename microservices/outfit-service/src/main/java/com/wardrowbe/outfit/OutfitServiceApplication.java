package com.wardrowbe.outfit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication(scanBasePackages = {"com.wardrowbe.outfit", "com.wardrowbe.common"})
@EnableDiscoveryClient
@EnableFeignClients
public class OutfitServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OutfitServiceApplication.class, args);
    }
}
