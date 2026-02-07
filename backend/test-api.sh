#!/bin/bash
# API Test Script for FindItKIET Backend

BASE_URL="http://localhost:3000/api/v1"

echo "🧪 FindItKIET Backend API Testing"
echo "=================================="
echo ""

# Test 1: Health Check
echo "📡 Test 1: Health Check"
curl -s "$BASE_URL/../health" | jq '.'
echo ""
echo ""

# Test 2: Register User
echo "👤 Test 2: Register New User"
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@kiet.edu",
    "password": "password123",
    "name": "Test User"
  }')
echo "$REGISTER_RESPONSE" | jq '.'

# Extract tokens
ACCESS_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.accessToken')
REFRESH_TOKEN=$(echo "$REGISTER_RESPONSE" | jq -r '.data.refreshToken')
echo ""
echo "✅ Access Token: ${ACCESS_TOKEN:0:50}..."
echo ""
echo ""

# Test 3: Login
echo "🔐 Test 3: Login"
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@kiet.edu",
    "password": "password123"
  }')
echo "$LOGIN_RESPONSE" | jq '.'
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.data.accessToken')
echo ""
echo ""

# Test 4: Create Item (FOUND)
echo "📦 Test 4: Create Found Item"
ITEM_RESPONSE=$(curl -s -X POST "$BASE_URL/items" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{
    "title": "Black Leather Wallet",
    "description": "Found in library, contains student ID",
    "category": "ACCESSORIES",
    "status": "FOUND",
    "location": "Library 2nd Floor",
    "reportedAt": "2026-02-03T10:00:00Z",
    "imageUrls": ["https://example.com/wallet.jpg"]
  }')
echo "$ITEM_RESPONSE" | jq '.'
ITEM_ID=$(echo "$ITEM_RESPONSE" | jq -r '.data.id')
echo ""
echo "✅ Item ID: $ITEM_ID"
echo ""
echo ""

# Test 5: List Items
echo "📋 Test 5: List All Items"
curl -s "$BASE_URL/items" | jq '.data[] | {id, title, status, category}'
echo ""
echo ""

# Test 6: Get Item Details
echo "🔍 Test 6: Get Item Details"
curl -s "$BASE_URL/items/$ITEM_ID" | jq '.'
echo ""
echo ""

# Test 7: Create Claim
echo "✅ Test 7: Submit Claim (needs second user)"
echo "Creating second user..."
CLAIMER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "claimer@kiet.edu",
    "password": "password123",
    "name": "Item Claimer"
  }')
CLAIMER_TOKEN=$(echo "$CLAIMER_RESPONSE" | jq -r '.data.accessToken')

CLAIM_RESPONSE=$(curl -s -X POST "$BASE_URL/items/$ITEM_ID/claims" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLAIMER_TOKEN" \
  -d '{
    "proofs": [
      {
        "type": "DESCRIPTION",
        "value": "Small scratch near the zipper"
      },
      {
        "type": "SERIAL_NUMBER",
        "value": "ABC123456"
      }
    ]
  }')
echo "$CLAIM_RESPONSE" | jq '.'
CLAIM_ID=$(echo "$CLAIM_RESPONSE" | jq -r '.data.id')
echo ""
echo "✅ Claim ID: $CLAIM_ID"
echo ""
echo ""

# Test 8: Create Admin User
echo "👮 Test 8: Create Admin User (manual DB update required)"
echo "Run this SQL to make test@kiet.edu an admin:"
echo "UPDATE \"User\" SET role = 'ADMIN' WHERE email = 'test@kiet.edu';"
echo ""
echo ""

# Test 9: Token Refresh
echo "🔄 Test 9: Token Refresh"
REFRESH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{
    \"refreshToken\": \"$REFRESH_TOKEN\"
  }")
echo "$REFRESH_RESPONSE" | jq '.'
echo ""
echo ""

# Test 10: Health Check Again
echo "✅ Test 10: Final Health Check"
curl -s "$BASE_URL/../health" | jq '.'
echo ""
echo ""

echo "=================================="
echo "✨ All Tests Complete!"
echo "=================================="
echo ""
echo "🔑 Key Information:"
echo "  User Email: test@kiet.edu"
echo "  Password: password123"
echo "  Access Token: ${ACCESS_TOKEN:0:50}..."
echo "  Item ID: $ITEM_ID"
echo "  Claim ID: $CLAIM_ID"
echo ""
echo "💡 Next Steps:"
echo "  1. Run the iOS app in Xcode"
echo "  2. Login with test@kiet.edu / password123"
echo "  3. Browse items and submit claims"
echo "  4. Make user admin to test admin features"
echo ""
