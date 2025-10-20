from http.server import BaseHTTPRequestHandler, HTTPServer
import os, glob

PROM_DIR = os.path.expanduser('~/daegis/logs/prom')

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/metrics":
            self.send_response(404); self.end_headers(); return
        lines=[]
        try:
            for p in sorted(glob.glob(os.path.join(PROM_DIR, "*.prom"))):
                with open(p,"r") as f:
                    lines.append(f.read())
        except Exception:
            lines.append("# no metrics yet\n")
        data = "\n".join(lines)
        self.send_response(200)
        self.send_header("Content-Type","text/plain; version=0.0.4")
        self.end_headers()
        self.wfile.write(data.encode())

if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 9091), H).serve_forever()
