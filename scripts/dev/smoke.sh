#!/usr/bin/env bash
set -euo pipefail

echo "🧪 Daegis Router Smoke Test"
echo "=========================="

# Kill existing uvicorn on :8080 (best-effort)
echo "🔄 Cleaning up existing server..."
sudo pkill -f "uvicorn.*8080" 2>/dev/null || pkill -f "python.*8080" 2>/dev/null || echo "  No existing server found"

# Start background server
echo "🚀 Starting server in background..."
nohup python -m uvicorn router.app:app --host 0.0.0.0 --port 8080 > smoke_server.log 2>&1 &
SERVER_PID=$!
echo "  Server PID: $SERVER_PID"

# Wait for server startup
echo "⏳ Waiting for server startup..."
sleep 3

# Function to run header check and report result
check_headers() {
    local test_name="$1"
    local payload="$2"
    local expected_cache="$3"
    
    echo -n "📋 $test_name: "
    
    response=$(curl -s -D - -o /dev/null -X POST http://127.0.0.1:8080/chat \
        -H 'Content-Type: application/json' -d "$payload" \
        | tr -d '\r' | grep -iE '^(HTTP/|x-cache|x-corr-id|x-episode-id)' || true)
    
    if [[ "$response" == *"HTTP/1.1"* && "$response" == *"x-episode-id:"* && "$response" == *"$expected_cache"* ]]; then
        echo "✅ PASS"
    else
        echo "❌ FAIL"
        echo "  Response: $response"
    fi
}

# Run header checks
echo ""
echo "🔍 Testing Headers:"
check_headers "MISS (first call)" '{"q":"smoke_test1"}' "x-cache: MISS"
check_headers "HIT (same payload)" '{"q":"smoke_test1"}' "x-cache: HIT"  
check_headers "504 (timeout)" '{"q":"slow","delay":4}' "HTTP/1.1 504"

# Check decision logs
echo ""
echo "📝 Recent Decision Logs:"
if [[ -f smoke_server.log ]]; then
    tail -10 smoke_server.log | grep '"event":"decision"' | tail -5 || echo "  No decision logs found yet"
else
    echo "  Server log not found"
fi

echo ""
echo "✨ Smoke test complete! Server running on PID $SERVER_PID"
echo "   To stop: kill $SERVER_PID"
echo "   Logs: tail -f smoke_server.log"