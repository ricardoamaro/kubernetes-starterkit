#!/usr/bin/env bash
# Calculator API Test Script
# Tests all calculator operations via the Ambassador gateway

BASE_URL="${BASE_URL:-http://localhost:8080}"
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "  Calculator Microservices Test Suite"
echo "=============================================="
echo "Base URL: $BASE_URL"
echo ""

# Check if the service is reachable
echo "Checking connectivity..."
if ! curl -s --max-time 5 -o /dev/null "$BASE_URL" 2>/dev/null; then
    echo -e "${RED}ERROR: Cannot connect to $BASE_URL${NC}"
    echo ""
    echo "The Ambassador gateway is not accessible. Please run:"
    echo ""
    echo -e "  ${YELLOW}kubectl port-forward svc/ambassador 8080:80${NC}"
    echo ""
    echo "Then run this script again in another terminal."
    exit 1
fi
echo -e "${GREEN}Connection successful!${NC}"
echo ""

# Function to test an endpoint
test_endpoint() {
    local name="$1"
    local endpoint="$2"
    local expected="$3"
    
    printf "Testing %-20s ... " "$name"
    
    response=$(curl -s --max-time 10 "$endpoint" 2>/dev/null) || response="CONNECTION_ERROR"
    
    if [[ "$response" == *"$expected"* ]]; then
        echo -e "${GREEN}PASS${NC} (got: $response)"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (expected: $expected, got: $response)"
        ((FAILED++))
    fi
}

# Function to test health endpoint
test_health() {
    local name="$1"
    local endpoint="$2"
    
    printf "Testing %-20s ... " "$name health"
    
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$endpoint" 2>/dev/null) || status="000"
    
    if [[ "$status" == "200" ]]; then
        echo -e "${GREEN}PASS${NC} (HTTP $status)"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (HTTP $status)"
        ((FAILED++))
    fi
}

echo "----------------------------------------------"
echo "Health Checks"
echo "----------------------------------------------"
test_health "Expressed" "$BASE_URL/api/express/healthz"
test_health "Happy" "$BASE_URL/api/happy/healthz"
test_health "Bootstorage" "$BASE_URL/api/bootstorage/healthz"
echo ""

echo "----------------------------------------------"
echo "Addition Tests (Expressed Service)"
echo "----------------------------------------------"
test_endpoint "10 + 5 = 15" "$BASE_URL/api/express/add?num1=10&num2=5" '"result":15'
test_endpoint "0 + 0 = 0" "$BASE_URL/api/express/add?num1=0&num2=0" '"result":0'
test_endpoint "-5 + 10 = 5" "$BASE_URL/api/express/add?num1=-5&num2=10" '"result":5'
test_endpoint "100 + 200 = 300" "$BASE_URL/api/express/add?num1=100&num2=200" '"result":300'
echo ""

echo "----------------------------------------------"
echo "Subtraction Tests (Expressed Service)"
echo "----------------------------------------------"
test_endpoint "10 - 3 = 7" "$BASE_URL/api/express/subtract?num1=10&num2=3" '"result":7'
test_endpoint "5 - 10 = -5" "$BASE_URL/api/express/subtract?num1=5&num2=10" '"result":-5'
test_endpoint "0 - 0 = 0" "$BASE_URL/api/express/subtract?num1=0&num2=0" '"result":0'
test_endpoint "100 - 50 = 50" "$BASE_URL/api/express/subtract?num1=100&num2=50" '"result":50'
echo ""

echo "----------------------------------------------"
echo "Multiplication Tests (Happy Service)"
echo "----------------------------------------------"
test_endpoint "7 × 6 = 42" "$BASE_URL/api/happy/multiply?num1=7&num2=6" '42'
test_endpoint "0 × 100 = 0" "$BASE_URL/api/happy/multiply?num1=0&num2=100" '0'
test_endpoint "-3 × 4 = -12" "$BASE_URL/api/happy/multiply?num1=-3&num2=4" '-12'
test_endpoint "10 × 10 = 100" "$BASE_URL/api/happy/multiply?num1=10&num2=10" '100'
echo ""

echo "----------------------------------------------"
echo "Division Tests (Happy Service)"
echo "----------------------------------------------"
test_endpoint "20 ÷ 4 = 5" "$BASE_URL/api/happy/divide?num1=20&num2=4" '5'
test_endpoint "10 ÷ 3 = 3.33" "$BASE_URL/api/happy/divide?num1=10&num2=3" '3.33'
test_endpoint "100 ÷ 10 = 10" "$BASE_URL/api/happy/divide?num1=100&num2=10" '10'
test_endpoint "0 ÷ 5 = 0" "$BASE_URL/api/happy/divide?num1=0&num2=5" '0'
echo ""

echo "----------------------------------------------"
echo "History Test (Bootstorage Service)"
echo "----------------------------------------------"
printf "Testing %-20s ... " "Get operations"
response=$(curl -s --max-time 10 "$BASE_URL/api/bootstorage/operations" 2>/dev/null) || response="CONNECTION_ERROR"
if [[ "$response" != "CONNECTION_ERROR" && "$response" != *"503"* ]]; then
    echo -e "${GREEN}PASS${NC} (endpoint accessible)"
    ((PASSED++))
else
    echo -e "${RED}FAIL${NC} (got: $response)"
    ((FAILED++))
fi
echo ""

echo "=============================================="
echo "  Test Results"
echo "=============================================="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
TOTAL=$((PASSED + FAILED))
echo "Total:  $TOTAL"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
