# Computers API Tests
# Tests for computer check-in, listing, and frequent devices

# Setup: Create authenticated session
POST {{base_url}}/api/auth/sign-up/email
Content-Type: application/json
{
  "name": "Computer Tester",
  "email": "comptester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200

POST {{base_url}}/api/auth/sign-in/email
Content-Type: application/json
{
  "email": "comptester{{$timestamp}}@example.com",
  "password": "TestPass123!"
}
HTTP 200
[Captures]
auth_cookie: cookie "better_auth.session_token"


# Test 1: Check-in a Computer
POST {{base_url}}/api/computers/checkin
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "Dell",
  "model": "Latitude 5420",
  "color": "Black",
  "ownerName": "John Doe",
  "ownerId": "123456789"
}
HTTP 200
[Captures]
computer_id: jsonpath "$.id"
[Asserts]
jsonpath "$.id" exists
jsonpath "$.brand" == "Dell"
jsonpath "$.model" == "Latitude 5420"
jsonpath "$.checkoutTime" == null


# Test 2: List All Computers
GET {{base_url}}/api/computers
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[0]" exists


# Test 3: Register Frequent Computer
POST {{base_url}}/api/computers/frequent
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "HP",
  "model": "EliteBook 840",
  "color": "Silver",
  "ownerName": "Jane Smith",
  "ownerId": "987654321"
}
HTTP 200
[Captures]
frequent_id: jsonpath "$.id"
qr_checkin_url: jsonpath "$.qrCheckinUrl"
qr_checkout_url: jsonpath "$.qrCheckoutUrl"
[Asserts]
jsonpath "$.id" exists
jsonpath "$.brand" == "HP"
jsonpath "$.qrCheckinUrl" exists
jsonpath "$.qrCheckoutUrl" exists


# Test 4: List Frequent Computers
GET {{base_url}}/api/computers/frequent
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$" isCollection


# Test 5: Get QR Codes for Frequent Computer
GET {{base_url}}/api/computers/frequent/{{frequent_id}}/qrcodes
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$.checkinQR" exists
jsonpath "$.checkoutQR" exists


# Test 6: Check-in Frequent Computer
PATCH {{base_url}}/api/computers/frequent/checkin/{{frequent_id}}
Cookie: better_auth.session_token={{auth_cookie}}
HTTP 200
[Asserts]
jsonpath "$.checkoutTime" == null


# Test 7: Invalid Check-in (Missing Required Fields)
POST {{base_url}}/api/computers/checkin
Cookie: better_auth.session_token={{auth_cookie}}
Content-Type: application/json
{
  "brand": "Dell"
}
HTTP 400
