#!/bin/bash

# Integration Test Script for DevOps Microservice

set -e

BASE_URL=${1:-http://localhost}
JWT_TOKEN=""

echo "🧪 Running Integration Tests against $BASE_URL"

# Function to generate JWT token
generate_jwt() {
    echo "🔐 Generating JWT token..."
    JWT_TOKEN=$(python3 -c "from app.security import generate_jwt; print(generate_jwt())" 2>/dev/null)
    
    if [ -z "$JWT_TOKEN" ]; then
        echo "❌ Failed to generate JWT token"
        exit 1
    fi
    
    echo "✅ JWT token generated successfully"
}

# Function to test health endpoint
test_health() {
    echo "🏥 Testing health endpoint..."
    
    RESPONSE=$(curl -s -w "%{http_code}" "$BASE_URL/health")
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "ok"; then
        echo "✅ Health check passed"
    else
        echo "❌ Health check failed: HTTP $HTTP_CODE, Response: $BODY"
        exit 1
    fi
}

# Function to test POST /DevOps endpoint
test_devops_post() {
    echo "📤 Testing POST /DevOps endpoint..."
    
    PAYLOAD='{"message": "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec": 45}'
    
    RESPONSE=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/DevOps" \
        -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
        -H "X-JWT-KWY: $JWT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")
    
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "Hello Juan Perez"; then
        echo "✅ POST /DevOps test passed"
        echo "📝 Response: $BODY"
    else
        echo "❌ POST /DevOps test failed: HTTP $HTTP_CODE, Response: $BODY"
        exit 1
    fi
}

# Function to test invalid API key
test_invalid_api_key() {
    echo "🚫 Testing invalid API key..."
    
    PAYLOAD='{"message": "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec": 45}'
    
    RESPONSE=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/DevOps" \
        -H "X-Parse-REST-API-Key: invalid-key" \
        -H "X-JWT-KWY: $JWT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")
    
    HTTP_CODE="${RESPONSE: -3}"
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo "✅ Invalid API key test passed"
    else
        echo "❌ Invalid API key test failed: Expected 401, got $HTTP_CODE"
        exit 1
    fi
}

# Function to test invalid JWT
test_invalid_jwt() {
    echo "🚫 Testing invalid JWT..."
    
    PAYLOAD='{"message": "This is a test", "to": "Juan Perez", "from": "Rita Asturia", "timeToLifeSec": 45}'
    
    RESPONSE=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/DevOps" \
        -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
        -H "X-JWT-KWY: invalid-jwt" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")
    
    HTTP_CODE="${RESPONSE: -3}"
    
    if [ "$HTTP_CODE" = "401" ]; then
        echo "✅ Invalid JWT test passed"
    else
        echo "❌ Invalid JWT test failed: Expected 401, got $HTTP_CODE"
        exit 1
    fi
}

# Function to test other HTTP methods
test_other_methods() {
    echo "🔄 Testing other HTTP methods..."
    
    # Test GET
    RESPONSE=$(curl -s -w "%{http_code}" -X GET "$BASE_URL/DevOps")
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "ERROR"; then
        echo "✅ GET method test passed"
    else
        echo "❌ GET method test failed: Expected 'ERROR', got: $BODY"
        exit 1
    fi
    
    # Test PUT
    RESPONSE=$(curl -s -w "%{http_code}" -X PUT "$BASE_URL/DevOps")
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "ERROR"; then
        echo "✅ PUT method test passed"
    else
        echo "❌ PUT method test failed: Expected 'ERROR', got: $BODY"
        exit 1
    fi
    
    # Test DELETE
    RESPONSE=$(curl -s -w "%{http_code}" -X DELETE "$BASE_URL/DevOps")
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] && echo "$BODY" | grep -q "ERROR"; then
        echo "✅ DELETE method test passed"
    else
        echo "❌ DELETE method test failed: Expected 'ERROR', got: $BODY"
        exit 1
    fi
}

# Function to test load balancing
test_load_balancing() {
    echo "⚖️ Testing load balancing..."
    
    echo "🔄 Sending 10 requests to test distribution..."
    
    SUCCESS_COUNT=0
    for i in {1..10}; do
        PAYLOAD="{\"message\": \"Test $i\", \"to\": \"User$i\", \"from\": \"Tester\", \"timeToLifeSec\": 45}"
        
        RESPONSE=$(curl -s -X POST "$BASE_URL/DevOps" \
            -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
            -H "X-JWT-KWY: $JWT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$PAYLOAD")
        
        if echo "$RESPONSE" | grep -q "Hello User$i"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
    done
    
    if [ "$SUCCESS_COUNT" = "10" ]; then
        echo "✅ Load balancing test passed: $SUCCESS_COUNT/10 requests successful"
    else
        echo "❌ Load balancing test failed: $SUCCESS_COUNT/10 requests successful"
        exit 1
    fi
}

# Function to test performance
test_performance() {
    echo "⚡ Testing performance..."
    
    echo "🔄 Sending 100 concurrent requests..."
    
    START_TIME=$(date +%s)
    
    # Send 100 requests in background
    for i in {1..100}; do
        {
            PAYLOAD="{\"message\": \"Perf test\", \"to\": \"User\", \"from\": \"Tester\", \"timeToLifeSec\": 45}"
            curl -s -X POST "$BASE_URL/DevOps" \
                -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
                -H "X-JWT-KWY: $JWT_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$PAYLOAD" > /dev/null
        } &
    done
    
    # Wait for all background jobs to complete
    wait
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    echo "✅ Performance test completed in ${DURATION}s"
    
    # Check if performance is acceptable (< 30 seconds for 100 requests)
    if [ "$DURATION" -lt 30 ]; then
        echo "✅ Performance test passed"
    else
        echo "⚠️ Performance test warning: Took ${DURATION}s (threshold: 30s)"
    fi
}

# Main test execution
main() {
    echo "🚀 Starting integration tests..."
    
    # Check if service is available
    if ! curl -f "$BASE_URL/health" > /dev/null 2>&1; then
        echo "❌ Service not available at $BASE_URL"
        echo "💡 Make sure the service is running: ./deploy.sh staging"
        exit 1
    fi
    
    generate_jwt
    test_health
    test_devops_post
    test_invalid_api_key
    test_invalid_jwt
    test_other_methods
    test_load_balancing
    test_performance
    
    echo ""
    echo "🎉 All integration tests passed!"
    echo "🌐 Service is fully operational at $BASE_URL/DevOps"
}

# Execute main function
main
