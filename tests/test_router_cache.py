import time
import requests


def test_cache_hit_is_faster():
    url = "http://localhost:8080/chat"
    payload = {"user": "t", "content": "hello", "source": "test"}
    t1 = time.time()
    r1 = requests.post(url, json=payload, timeout=5)
    d1 = time.time() - t1
    t2 = time.time()
    r2 = requests.post(url, json=payload, timeout=5)
    d2 = time.time() - t2
    assert r1.status_code == 200 and r2.status_code == 200
    assert d2 <= d1  # キャッシュで速くなる（最低限の期待）
