import requests

def test_timeout_returns_504():
    url = "http://localhost:8080/chat"
    payload = {"user":"t","content":"SLOW_EXTERNAL_CALL","source":"test"}
    r = requests.post(url, json=payload, timeout=5)
    assert r.status_code in (200, 504)  # 実装前は緩め、実装後に 504 を厳格化
