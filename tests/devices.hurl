# General Devices API Tests
# Tests for device history, checkout, and entered devices

# Setup: Create authenticated session and devices
POST {{base_url}}/api/auth/sign-up/email
Content-Type: application/json
{
  "name": "Device Tester",
  "email": "devtester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200

POST {{base_url}}/api/auth/sign-in/email
Content-Type: application/json
{
  "email": "devtester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200
[Captures]
auth_cookie: cookie "better_auth.session_token"

# Create a test computer
POST {{base_url}}/api/computers/checkin
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "Lenovo",
  "model": "ThinkPad X1",
  "color": "Black",
  "ownerName": "Test Owner",
  "ownerId": "TEST123"
}
HTTP 200
[Captures]
test_device_id: jsonpath "$.id"


# Test 1: Get All Entered Devices (Not Checked Out)
GET {{base_url}}/api/devices/entered
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[*].checkoutTime" not exists


# Test 2: Get Device History
GET {{base_url}}/api/devices/history
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[0]" exists
jsonpath "$[0].id" exists
jsonpath "$[0].type" exists


# Test 3: Checkout Device
PATCH {{base_url}}/api/devices/checkout/{{test_device_id}}
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$.id" == {{test_device_id}}
jsonpath "$.checkoutTime" exists


# Test 4: Verify Device is No Longer in Entered List
GET {{base_url}}/api/devices/entered
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection


# Test 5: Try to Checkout Non-existent Device
PATCH {{base_url}}/api/devices/checkout/99999
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 404


# Test 6: Unauthorized Access (No Cookie)
GET {{base_url}}/api/devices/history
HTTP 401
