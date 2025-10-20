import os, pathlib, asyncio

def ensure_external_allowed(client_name: str):
    if os.getenv("ALLOW_EXTERNAL_API", "0") not in ("1", "true", "TRUE"):
        raise RuntimeError(f"external API disabled (set ALLOW_EXTERNAL_API=1) for {client_name}")
    if not pathlib.Path("ops/guard/EXTERNAL.ALLOW").exists():
        raise RuntimeError("EXTERNAL.ALLOW file missing (touch ops/guard/EXTERNAL.ALLOW)")

def guard_external(client_name: str):
    def decorate(fn):
        if asyncio.iscoroutinefunction(fn):
            async def _wrapped(*a, **k):
                ensure_external_allowed(client_name)
                return await fn(*a, **k)
            return _wrapped
        else:
            def _wrapped(*a, **k):
                ensure_external_allowed(client_name)
                return fn(*a, **k)
            return _wrapped
    return decorate
