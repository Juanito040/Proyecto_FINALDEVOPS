# Medical Devices API Tests
# Tests for medical device check-in and listing

# Setup: Create authenticated session
POST {{base_url}}/api/auth/sign-up/email
Content-Type: application/json
{
  "name": "Medical Tester",
  "email": "medtester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200

POST {{base_url}}/api/auth/sign-in/email
Content-Type: application/json
{
  "email": "medtester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200
[Captures]
auth_cookie: cookie "better_auth.session_token"


# Test 1: Check-in Medical Device (Without Photo - Should Fail if Photo Required)
POST {{base_url}}/api/medicaldevices/checkin
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "Philips",
  "model": "Ultrasound X300",
  "serial": "SN123456789",
  "ownerName": "Dr. Smith",
  "ownerId": "DOC123"
}
HTTP 400


# Test 2: List All Medical Devices
GET {{base_url}}/api/medicaldevices
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection


# Test 3: Invalid Check-in (Missing Serial Number)
POST {{base_url}}/api/medicaldevices/checkin
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "GE Healthcare",
  "model": "Monitor PRO",
  "ownerName": "Dr. Johnson",
  "ownerId": "DOC456"
}
HTTP 400
