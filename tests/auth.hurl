# Authentication Tests
# Tests for user registration, login, and session management

# Test 1: User Registration
POST {{base_url}}/api/auth/sign-up/email
Content-Type: application/json
{
  "name": "Test User",
  "email": "testuser{{$timestamp}}@example.com",
  "password": "SecurePassword123!"
}
HTTP 200
[Captures]
user_email: jsonpath "$.user.email"
[Asserts]
jsonpath "$.user" exists
jsonpath "$.user.name" == "Test User"


# Test 2: User Login with Valid Credentials
POST {{base_url}}/api/auth/sign-in/email
Content-Type: application/json
{
  "email": "{{user_email}}",
  "password": "SecurePassword123!"
}
HTTP 200
[Captures]
session_cookie: cookie "better_auth.session_token"
[Asserts]
jsonpath "$.user" exists
jsonpath "$.user.email" == {{user_email}}


# Test 3: Get Session (Authenticated)
GET {{base_url}}/api/auth/get-session
Cookie: better_auth.session_token={{session_cookie}}
HTTP 200
[Asserts]
jsonpath "$.session" exists
jsonpath "$.user" exists


# Test 4: Login with Invalid Credentials
POST {{base_url}}/api/auth/sign-in/email
Content-Type: application/json
{
  "email": "nonexistent@example.com",
  "password": "WrongPassword123"
}
HTTP 401


# Test 5: Sign Out
POST {{base_url}}/api/auth/sign-out
Cookie: better_auth.session_token={{session_cookie}}
HTTP 200
