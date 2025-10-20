import importlib
mod = importlib.import_module("slack_inbox")
app = getattr(mod, "app", None)
if app is None:
    from flask import Flask
    app = Flask(__name__)
@app.get("/health")
def _h(): return "ok", 200
