import os
import re
import urllib.request

URL = os.getenv("ROUTER_METRICS", "http://127.0.0.1:8080/metrics")


def test_router_up():
    body = urllib.request.urlopen(URL, timeout=3).read().decode()
    assert re.search(r"^router_up\s+1(\.0+)?$", body, flags=re.M)


def test_basic_metrics_exposed():
    body = urllib.request.urlopen(URL, timeout=3).read().decode()
    for key in ("rt_requests_total", "rt_latency_ms"):
        assert key in body
