# TestLang++ - Backend API Testing DSL

**SE2062 Assignment - Programming Paradigms**  
**Student:** Kaveen Sasmina  
**Due Date:** October 25, 2025

## 🎯 Overview

TestLang++ is a Domain-Specific Language (DSL) for HTTP API testing that compiles `.test` files into executable JUnit 5 tests using Java's `HttpClient`. This project demonstrates the complete implementation of a compiler including lexical analysis (scanner), syntax analysis (parser), and code generation targeting JUnit 5.

## 📁 Project Structure

```
PP/
├── ast/                    # Abstract Syntax Tree node classes
│   ├── ASTNode.java
│   ├── ProgramNode.java
│   ├── ConfigNode.java
│   ├── VariableNode.java
│   ├── TestNode.java
│   ├── RequestNode.java
│   ├── AssertionNode.java
│   └── HeaderNode.java
├── backend/                # Spring Boot backend (test target)
│   ├── src/
│   ├── target/
│   └── pom.xml
├── build/                  # Compiled classes (generated)
│   ├── ast/
│   ├── codegen/
│   ├── compiler/
│   ├── parser/
│   ├── scanner/
│   └── tests/
├── codegen/                # Code generation (AST → JUnit)
│   ├── CodeGenerator.java
│   └── VariableSubstitutor.java
├── compiler/               # Main compiler entry point
│   └── TestLangCompiler.java
├── examples/               # Sample .test files
│   └── example.test
├── lib/                    # External dependencies
│   └── junit/              # JUnit 5 JARs
├── output/                 # Generated Java test files
│   └── GeneratedTests.java
├── parser/                 # CUP parser specification
│   └── parser.cup
├── scanner/                # JFlex lexer specification
│   └── lexer.flex
├── scripts/                # PowerShell build scripts
│   ├── compile.ps1
│   ├── run-compiler.ps1
│   ├── compile-tests.ps1
│   ├── run-tests.ps1
│   ├── start-backend.ps1
│   └── verify-all.ps1
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- **Java 11+** (JDK 21 recommended)
- **PowerShell** (Windows)
- **Maven** (included in project as `apache-maven-3.9.5/`)

### Step 1: Compile the TestLang++ Compiler

Build the scanner, parser, and code generator:

```powershell
.\scripts\compile.ps1
```

This will:

1. Generate the scanner from `lexer.flex` using JFlex
2. Generate the parser from `parser.cup` using CUP
3. Compile AST classes
4. Compile scanner and parser
5. Compile code generator and compiler

**Output:** Compiled classes in `build/` directory

### Step 2: Run the Compiler on Example

Compile the example `.test` file to generate JUnit tests:

```powershell
.\scripts\run-compiler.ps1 examples\example.test
```

**Output:** `output/GeneratedTests.java` (JUnit 5 test class)

### Step 3: Start the Backend Server

Start the Spring Boot backend (runs on port 8080):

```powershell
.\scripts\start-backend.ps1
```

The server will start at `http://localhost:8080`  
**Keep this terminal open** while running tests.

### Step 4: Compile and Run the Generated Tests

Compile the generated test file:

```powershell
.\scripts\compile-tests.ps1
```

Run the JUnit tests:

```powershell
.\scripts\run-tests.ps1 output\GeneratedTests.java
```

**Expected Result:** All 5 tests pass ✅

### Step 5: Verify Everything (Optional)

Run the complete verification:

```powershell
.\scripts\verify-all.ps1
```

## 📝 TestLang++ Language Specification

### File Structure

A TestLang++ file consists of three sections (in order):

1. **Config block** (optional, 0..1)
2. **Variable declarations** (optional, 0..N)
3. **Test blocks** (required, 1..N)

### 1. Config Block (Optional)

Define base URL and default headers for all requests:

```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
  header "X-App" = "TestLangDemo";
}
```

- `base_url`: If present and request path starts with `/`, the effective URL is `base_url + path`
- `header`: Default headers applied to every request (request-level headers can add/override)

### 2. Variables (Optional)

Declare string or integer variables:

```testlang
let user = "admin";
let password = "1234";
let userId = 42;
```

- Variable names must be identifiers: `[A-Za-z_][A-Za-z0-9_]*`
- Use `$variableName` in strings and paths for substitution
- Example: `"/api/users/$userId"` → `"/api/users/42"`

### 3. Test Blocks (Required)

Each test block becomes a JUnit `@Test` method:

```testlang
test TestName {
  // HTTP requests
  // Assertions
}
```

**Requirements:**

- Each test must execute ≥1 HTTP request
- Each test must have ≥2 assertions

### HTTP Request Statements

**GET Request:**

```testlang
GET "/api/users/42";
```

**DELETE Request:**

```testlang
DELETE "/api/users/999";
```

**POST Request:**

```testlang
POST "/api/login" {
  header "Content-Type" = "application/json";
  body = "{ \"username\": \"admin\", \"password\": \"1234\" }";
};
```

**PUT Request:**

```testlang
PUT "/api/users/$userId" {
  body = "{ \"role\": \"ADMIN\" }";
};
```

### Assertion Statements

```testlang
expect status = 200;                           // Status code equals
expect header "Content-Type" = "application/json";  // Header equals
expect header "Content-Type" contains "json";  // Header contains substring
expect body contains "\"token\":";             // Body contains substring
```

### Lexical Rules

| Token           | Pattern                  | Examples                                                                                                              |
| --------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| **Keywords**    | Reserved words           | `config`, `let`, `test`, `GET`, `POST`, `PUT`, `DELETE`, `expect`, `status`, `body`, `contains`, `header`, `base_url` |
| **Identifiers** | `[A-Za-z_][A-Za-z0-9_]*` | `Login`, `userId`, `test_name`                                                                                        |
| **Numbers**     | `0 \| [1-9][0-9]*`       | `0`, `42`, `200`                                                                                                      |
| **Strings**     | `"([^\\"]                | \\.)\*"`                                                                                                              | `"hello"`, `"user $name"` |
| **Variables**   | `$identifier`            | `$user`, `$userId`                                                                                                    |
| **Comments**    | `//` to end of line      | `// This is a comment`                                                                                                |
| **Operators**   | `=`, `;`, `{`, `}`       | Assignment, statement end, blocks                                                                                     |

### Complete Example

```testlang
// TestLang++ Example - Full Test Suite

config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
  header "X-App" = "TestLangDemo";
}

// Variables
let user = "admin";
let password = "1234";
let userId = 42;

// Test 1: Login
test Login {
  POST "/api/login" {
    body = "{ \"username\": \"$user\", \"password\": \"$password\" }";
  };
  expect status = 200;
  expect header "Content-Type" contains "json";
  expect body contains "\"token\":";
}

// Test 2: Get User
test GetUserById {
  GET "/api/users/$userId";
  expect status = 200;
  expect body contains "\"id\":42";
  expect body contains "\"username\":";
}

// Test 3: Update User
test UpdateUser {
  PUT "/api/users/$userId" {
    body = "{ \"role\": \"ADMIN\" }";
  };
  expect status = 200;
  expect header "X-App" = "TestLangDemo";
  expect header "Content-Type" contains "json";
  expect body contains "\"updated\":true";
  expect body contains "\"role\":\"ADMIN\"";
}

// Test 4: Delete User
test DeleteUser {
  DELETE "/api/users/999";
  expect status = 200;
  expect body contains "\"deleted\":";
}
```

## 🧪 Backend API Reference

The Spring Boot backend provides REST endpoints for testing:

| Method | Endpoint          | Request Body                           | Response                                 | Purpose        |
| ------ | ----------------- | -------------------------------------- | ---------------------------------------- | -------------- |
| POST   | `/api/login`      | `{"username":"str", "password":"str"}` | `{"token":"...", "username":"..."}`      | User login     |
| GET    | `/api/users/{id}` | -                                      | `{"id":N, "username":"..."}`             | Get user by ID |
| PUT    | `/api/users/{id}` | `{"role":"str"}`                       | `{"updated":true, "id":N, "role":"..."}` | Update user    |
| DELETE | `/api/users/{id}` | -                                      | `{"deleted":true, "id":N}`               | Delete user    |

### Testing with cURL (Manual)

```powershell
# Login
curl -X POST http://localhost:8080/api/login `
  -H "Content-Type: application/json" `
  -d '{"username":"admin","password":"1234"}'

# Get user
curl http://localhost:8080/api/users/42

# Update user
curl -X PUT http://localhost:8080/api/users/42 `
  -H "Content-Type: application/json" `
  -d '{"role":"ADMIN"}'

# Delete user
curl -X DELETE http://localhost:8080/api/users/999
```

## 🛠️ Implementation Details

### Scanner (Lexer)

**File:** `scanner/lexer.flex`

- **Tool:** JFlex 1.9.1
- **Input:** `.test` source files
- **Output:** Token stream
- **Features:**
  - Recognizes all keywords (`config`, `let`, `test`, HTTP methods, etc.)
  - Tokenizes identifiers, numbers, strings
  - Handles comments (`//`)
  - Variable reference detection (`$name`)
  - Line and column tracking for error messages

### Parser

**File:** `parser/parser.cup`

- **Tool:** CUP 11b
- **Input:** Token stream from scanner
- **Output:** Abstract Syntax Tree (AST)
- **Grammar:** LL(1) predictive grammar
- **Features:**
  - Builds AST with proper node structure
  - Semantic validation during parsing
  - Error recovery and reporting
  - 22 terminals, 17 non-terminals, 35 productions

### AST (Abstract Syntax Tree)

**Package:** `ast/`

Node hierarchy:

- `ASTNode` - Base class
- `ProgramNode` - Root node (config, variables, tests)
- `ConfigNode` - Configuration block
- `VariableNode` - Variable declaration
- `TestNode` - Test block
- `RequestNode` - HTTP request
- `HeaderNode` - HTTP header
- `AssertionNode` - Test assertion

### Code Generator

**Package:** `codegen/`

- **CodeGenerator.java** - Main code generation logic
- **VariableSubstitutor.java** - Variable substitution in strings/paths

**Generated Code:**

- JUnit 5 test class
- Uses `java.net.http.HttpClient` (Java 11+)
- `@BeforeAll` setup method for client initialization
- Each test → `@Test` method
- Assertions using JUnit 5 (`assertEquals`, `assertTrue`)

### Compiler

**File:** `compiler/TestLangCompiler.java`

Main entry point that orchestrates:

1. Read `.test` file
2. Invoke scanner (lexical analysis)
3. Invoke parser (syntax analysis)
4. Traverse AST
5. Generate Java code
6. Write `GeneratedTests.java`

## 📊 Generated Code Example

**Input** (`example.test`):

```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
}

let user = "admin";

test Login {
  POST "/api/login" {
    body = "{ \"username\": \"$user\", \"password\": \"1234\" }";
  };
  expect status = 200;
  expect body contains "\"token\":";
}
```

**Output** (`GeneratedTests.java`):

```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import java.net.http.*;
import java.net.*;
import java.time.Duration;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class GeneratedTests {
    static String BASE = "http://localhost:8080";
    static Map<String, String> DEFAULT_HEADERS = new HashMap<>();
    static HttpClient client;

    @BeforeAll
    static void setup() {
        client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(5))
            .build();
        DEFAULT_HEADERS.put("Content-Type", "application/json");
    }

    @Test
    void test_Login() throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder(URI.create(BASE + "/api/login"))
            .timeout(Duration.ofSeconds(10))
            .POST(HttpRequest.BodyPublishers.ofString("{ \"username\": \"admin\", \"password\": \"1234\" }", StandardCharsets.UTF_8));
        for (var e : DEFAULT_HEADERS.entrySet()) {
            b.header(e.getKey(), e.getValue());
        }
        HttpResponse<String> resp = client.send(b.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

        assertEquals(200, resp.statusCode());
        assertTrue(resp.body().contains("\"token\":"));
    }
}
```

## ⚠️ Error Handling Examples

The compiler provides clear error messages for invalid input:

### Invalid Input Examples

**1. Invalid identifier:**

```testlang
let 2user = "admin";  // Identifiers cannot start with digit
```

**Error:** `Illegal character <2> at line 1, column 5`

**2. Body must be string:**

```testlang
POST "/api/login" {
  body = 123;  // Body must be string, not number
}
```

**Error:** `Syntax error at line 2, unexpected token: 123`

**3. Status must be number:**

```testlang
expect status = "200";  // Status must be integer
```

**Error:** `Syntax error at line 1, unexpected token: 200`

**4. Missing semicolon:**

```testlang
GET "/api/users/42"  // Missing semicolon
expect status = 200;
```

**Error:** `Syntax error at line 2, unexpected token: expect`

**5. Undefined variable:**

```testlang
GET "/api/users/$unknownVar";  // Variable not declared
```

**Warning:** Variable substitution will use literal string `$unknownVar`

## ✅ Assignment Requirements Checklist

### Language Design (25 marks)

- ✅ Config block with `base_url` and `header`
- ✅ Variable declarations (`let`)
- ✅ Variable substitution in strings/paths (`$var`)
- ✅ Test blocks with unique names
- ✅ HTTP methods: GET, POST, PUT, DELETE
- ✅ Request blocks with headers and body
- ✅ All assertion types (status, header equals/contains, body contains)
- ✅ Comments support (`//`)
- ✅ Clear semantics and documentation

### Scanner & Parser (30 marks)

- ✅ JFlex scanner (`lexer.flex`)
- ✅ CUP parser (`parser.cup`)
- ✅ Proper token definitions
- ✅ Complete grammar (35 productions)
- ✅ AST construction
- ✅ Error detection with line/column numbers
- ✅ Meaningful error messages
- ✅ Clean, maintainable code structure

### Code Generation (30 marks)

- ✅ Generates compilable JUnit 5 code
- ✅ Uses `java.net.http.HttpClient` (Java 11+)
- ✅ Proper `@BeforeAll` setup
- ✅ Each test → `@Test` method
- ✅ Correct HTTP request construction
- ✅ Header handling (default + per-request)
- ✅ Variable substitution in generated code
- ✅ Correct assertions (`assertEquals`, `assertTrue`)
- ✅ Idiomatic Java code

### Demo & Examples (15 marks)

- ✅ Complete `example.test` with ≥2 tests
- ✅ Generated `GeneratedTests.java`
- ✅ All tests pass against backend
- ✅ README with clear instructions
- ✅ PowerShell scripts for automation
- ✅ Demonstrates invalid input handling

### Bonus Features

- ✅ 5 comprehensive test cases
- ✅ Request-level header overrides
- ✅ Multiple assertions per test
- ✅ Automated verification script

## 📚 Technical Requirements

### Tools & Dependencies

- **Java**: JDK 11 or higher (tested with Java 21)
- **JFlex**: 1.9.1 (scanner generator)
- **CUP**: 11b (parser generator)
- **JUnit**: 5.10.0 (testing framework)
- **Maven**: 3.9.5 (backend build, included)
- **Spring Boot**: 2.7.18 (backend framework)

### System Requirements

- **OS**: Windows 10/11
- **Shell**: PowerShell 5.1+
- **Memory**: 512MB minimum
- **Disk**: 100MB for project + dependencies

## 🐛 Troubleshooting

### "Build directory not found"

**Solution:** Run `.\scripts\compile.ps1` first to compile the compiler

### "Dependencies not found"

**Solution:** JFlex and CUP JARs should be in `lib/`. Re-run compile script to auto-download

### Backend connection errors

**Solution:** Ensure backend is running (`.\scripts\start-backend.ps1`) and port 8080 is available

### "java: error: invalid source release: 11"

**Solution:** Ensure JDK 11+ is installed and JAVA_HOME is set correctly

```powershell
java -version  # Should show version 11 or higher
```

### Tests fail with ConnectException

**Solution:** Backend server is not running. Start it in a separate terminal:

```powershell
.\scripts\start-backend.ps1
```

### Port 8080 already in use

**Solution:** Kill existing process or change port in config and backend

```powershell
netstat -ano | findstr :8080
taskkill /PID <process_id> /F
```

## 📖 Grammar Reference

```ebnf
program       ::= config_section variable_declarations test_suite
config_section ::= config_declaration | ε
config_declaration ::= 'config' '{' config_statements '}'
config_statements ::= (base_url_stmt | header_statement)*
variable_declarations ::= variable_declaration*
variable_declaration ::= 'let' IDENTIFIER '=' literal_value ';'
test_suite ::= test_declaration+
test_declaration ::= 'test' IDENTIFIER '{' test_body '}'
test_body ::= statement+
statement ::= http_request | assertion_statement
http_request ::= ('GET' | 'DELETE') STRING ';'
              | ('POST' | 'PUT') STRING optional_request_block ';'
optional_request_block ::= '{' request_statements '}' | ε
assertion_statement ::= 'expect' assertion_type ';'
assertion_type ::= 'status' '=' NUMBER
                | 'header' STRING '=' STRING
                | 'header' STRING 'contains' STRING
                | 'body' 'contains' STRING
```

## 🎓 Learning Outcomes Achieved

1. ✅ **Language Design** - Designed a precise DSL from specification
2. ✅ **Lexical Analysis** - Built scanner with JFlex for tokenization
3. ✅ **Syntax Analysis** - Built parser with CUP for AST construction
4. ✅ **Code Generation** - Generated idiomatic JUnit 5 code
5. ✅ **Error Handling** - Meaningful error messages with line/column
6. ✅ **Integration** - End-to-end testing with Spring Boot backend

## 📄 Files Included in Submission

```
PP/
├── ast/                    # 8 AST node classes
├── backend/                # Spring Boot backend (complete)
├── codegen/                # 2 code generator classes
├── compiler/               # Main compiler
├── examples/
│   └── example.test       # Complete test suite
├── output/
│   └── GeneratedTests.java # Generated JUnit tests
├── parser/
│   └── parser.cup         # Parser specification
├── scanner/
│   └── lexer.flex         # Lexer specification
├── scripts/                # 6 PowerShell automation scripts
└── README.md              # This file
```

## 👤 Author & Submission

**Student Name:** Kaveen Sasmina  
**Course:** SE2062 - Programming Paradigms  
**Assignment:** TestLang++ DSL Compiler  
**Due Date:** October 25, 2025

**Submission Includes:**

- ✅ Source code (scanner, parser, AST, codegen)
- ✅ Example `.test` files
- ✅ Generated `GeneratedTests.java`
- ✅ Working Spring Boot backend
- ✅ Complete README documentation
- ✅ Demo video (≤3 minutes)

## 🎬 Demo Video Content

The submitted demo video demonstrates:

1. **Writing DSL** (30s)
   - Show `example.test` file with config, variables, and tests
2. **Compilation** (45s)
   - Run `.\scripts\compile.ps1` (compile compiler)
   - Run `.\scripts\run-compiler.ps1 examples\example.test`
   - Show generated `GeneratedTests.java`
3. **Execution** (1m)
   - Start backend: `.\scripts\start-backend.ps1`
   - Compile tests: `.\scripts\compile-tests.ps1`
   - Run tests: `.\scripts\run-tests.ps1 output\GeneratedTests.java`
   - Show all 5 tests passing
4. **Error Handling** (45s)
   - Create invalid `.test` file (e.g., missing semicolon)
   - Run compiler
   - Show clear error message with line/column

**Total Duration:** ~3 minutes

## 📞 References

- JFlex User Manual: https://jflex.de/manual.html
- CUP Parser Generator: http://www2.cs.tum.edu/projects/cup/
- JUnit 5 Documentation: https://junit.org/junit5/docs/current/user-guide/
- Java HttpClient: https://docs.oracle.com/en/java/javase/11/docs/api/java.net.http/java/net/http/HttpClient.html

---

**End of README**
