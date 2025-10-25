package com.testlang.demo.controller;

import com.testlang.demo.model.*;
import com.testlang.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {
    
    @Autowired
    private UserService userService;
    
    /**
     * POST /api/login
     * Test Case 1: Login with credentials
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest request) {
        // Accept multiple valid credentials
        boolean validCredentials = 
            ("admin".equals(request.getUsername()) && "1234".equals(request.getPassword())) ||
            ("testuser".equals(request.getUsername()) && "test123".equals(request.getPassword()));
        
        if (validCredentials) {
            LoginResponse response = new LoginResponse();
            response.setToken("fake-jwt-token-12345");
            response.setUsername(request.getUsername());
            return ResponseEntity.ok()
                .header("Content-Type", "application/json")
                .body(response);
        }
        return ResponseEntity.status(401).build();
    }
    
    /**
     * GET /api/users/{id}
     * Test Case 2: Get user by ID
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUser(@PathVariable Integer id) {
        User user = userService.getUserById(id);
        if (user != null) {
            return ResponseEntity.ok()
                .header("Content-Type", "application/json")
                .body(user);
        }
        return ResponseEntity.notFound().build();
    }
    
    /**
     * PUT /api/users/{id}
     * Test Case 3: Update user
     */
    @PutMapping("/users/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(
            @PathVariable Integer id,
            @RequestBody UpdateRequest request) {
        
        User user = userService.getUserById(id);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        
        // Update user
        if (request.getRole() != null) {
            user.setRole(request.getRole());
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("updated", true);
        response.put("id", id);
        response.put("role", user.getRole());
        
        return ResponseEntity.ok()
            .header("Content-Type", "application/json")
            .header("X-App", "TestLangDemo")
            .body(response);
    }
    
    /**
     * DELETE /api/users/{id}
     * Test Case 4: Delete user
     */
    @DeleteMapping("/users/{id}")
    public ResponseEntity<Map<String, Object>> deleteUser(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        response.put("deleted", true);
        response.put("id", id);
        
        return ResponseEntity.ok()
            .header("Content-Type", "application/json")
            .body(response);
    }
}