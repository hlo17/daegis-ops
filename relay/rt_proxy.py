from fastapi import APIRouter, Request
from fastapi.responses import Response, JSONResponse
import httpx

router = APIRouter()

@router.get("/rt/health")
async def rt_health_proxy():
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            r = await client.get("http://127.0.0.1:8010/health")
        # 8010側のJSONをそのまま返す
        return JSONResponse(status_code=r.status_code, content=r.json())
    except Exception as e:
        return JSONResponse(status_code=502, content={"ok": False, "error": str(e)})

@router.api_route("/rt/{path:path}", methods=["GET","POST","PUT","PATCH","DELETE","OPTIONS"])
async def roundtable_proxy(path: str, request: Request):
    target_url = f"http://127.0.0.1:8010/{path}"
    hop_by_hop = {"connection","keep-alive","proxy-authenticate","proxy-authorization",
                  "te","trailer","transfer-encoding","upgrade"}
    fwd_headers = {k: v for k, v in request.headers.items() if k.lower() not in hop_by_hop}
    body = await request.body()
    async with httpx.AsyncClient(timeout=15.0) as client:
        resp = await client.request(request.method, target_url, content=body, headers=fwd_headers)
    out_headers = {k: v for k, v in resp.headers.items() if k.lower() not in hop_by_hop}
    return Response(content=resp.content, status_code=resp.status_code, headers=out_headers)

def register(app):
    app.include_router(router)
