def ensure_chat_locals():
    import os as _os, json as _json, time as _time
    return _os, _json, _time

def init_metrics_once(_state={"done": False}):
    if _state["done"]:
        return
    _state["done"] = True
