# Health Check Tests
# This file tests the basic health and availability of the API

# Test 1: API Root Endpoint
GET {{base_url}}
HTTP 200
[Asserts]
duration < 2000


# Test 2: OpenAPI Documentation
GET {{base_url}}/openapi
HTTP 200
[Asserts]
duration < 3000
jsonpath "$.openapi" exists


# Test 3: Swagger UI
GET {{base_url}}/swagger
HTTP 200
[Asserts]
duration < 3000
