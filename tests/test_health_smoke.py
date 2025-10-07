import os
import urllib.request

CHAT = os.getenv("ROUTER_CHAT", "http://127.0.0.1:8080/chat")


def test_chat_endpoint_pongs():
    body = urllib.request.urlopen(CHAT, timeout=5).read().decode()
    assert "pong" in body.lower() or "pong!" in body
