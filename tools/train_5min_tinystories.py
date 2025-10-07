import json
import math
import os
import random
import signal
import sys
import time
from pathlib import Path

import torch
import torch.nn as nn

# ---- ハイパラ（環境変数で上書き可）
N_EMBD = int(os.environ.get("HALU_N_EMBD", "192"))
N_HEAD = int(os.environ.get("HALU_N_HEAD", "4"))
N_LAYER = int(os.environ.get("HALU_N_LAYER", "2"))
CTX = int(os.environ.get("HALU_CTX_LEN", "192"))
LR = float(os.environ.get("HALU_LR", "1.5e-3"))
BUDGET = int(os.environ.get("HALU_TRAIN_BUDGET_SEC", "120"))
ROWS = int(os.environ.get("HALU_TINY_ROWS", "4000"))
OUT = Path(os.environ.get("HALU_OUT_DIR", "~/daegis/tools/halu_5min_model")).expanduser()
OUT.mkdir(parents=True, exist_ok=True)

# ---- デバイス/CPU負荷
if torch.cuda.is_available():
    dev = torch.device("cuda")
elif torch.backends.mps.is_available():
    dev = torch.device("mps")
else:
    dev = torch.device("cpu")
    torch.set_num_threads(max(1, (os.cpu_count() or 2) // 2))


def save_metrics(model, start_time, total_loss=None, total_count=None, stop_reason="BUDGET"):
    elapsed = int(time.time() - start_time)
    m = {
        "params_m": round(sum(p.numel() for p in model.parameters()) / 1e6, 2),
        "elapsed_sec": elapsed,
        "device": str(dev),
        "stop_reason": stop_reason,
    }
    if total_loss is not None and total_count and total_count > 0:
        avg = total_loss / total_count
        m["avg_loss"] = round(avg, 6)
        m["ppl"] = float(math.exp(avg))
        print(f"[eval] PPL={m['ppl']:.3f} ({stop_reason})", flush=True)
    (OUT / "metrics.json").write_text(json.dumps(m, ensure_ascii=False, indent=2))
    print(f"[save] → {OUT}/metrics.json ({stop_reason})", flush=True)


# ---- シグナル（優雅停止）
def _sig(_s, _f):
    print("\n[WARN] Interrupted. Saving metrics...", flush=True)
    save_metrics(model, start_time, stop_reason="INTERRUPT")
    sys.exit(0)


signal.signal(signal.SIGINT, _sig)
signal.signal(signal.SIGTERM, _sig)

# ---- データ（短文耐性: MIN_LENまでリピート）
records = Path("~/daegis/records/hand-off.md").expanduser()
if records.exists() and records.read_text(encoding="utf-8", errors="ignore").strip():
    text = records.read_text(encoding="utf-8", errors="ignore")
else:
    S = ["Slackへ要約を投稿", "外部AIコールを抑制", "RAG閾値を0.7に設定", "フォールバック実行"]
    P = ["費用を週$50で制限", "3スロット型で出力", "危険表現をフィルタ", "人間承認を必須"]
    N = ["digestを回す", "LoRAは型矯正のみ", "KPIを更新", "デプロイは保留"]
    text = "\n".join(
        [
            f"状況:{random.choice(S)}。方針:{random.choice(P)}。次:{random.choice(N)}。"
            for _ in range(ROWS)
        ]
    )


class ByteTok:
    vocab_size = 256

    def encode(self, s):
        return torch.tensor(list(s.encode("utf-8", "ignore")), dtype=torch.long)

    def decode(self, ids):
        return bytes([int(x) for x in ids]).decode("utf-8", "ignore")


tok = ByteTok()
data = tok.encode(text)

MIN_LEN = max(CTX + 2, 512)
if len(data) < MIN_LEN:
    reps = (MIN_LEN + len(data) - 1) // len(data)
    data = data.repeat(reps)

split_i = int(len(data) * 0.9)
train_data = data[:split_i]
val_data = data[split_i:]


def get_batch(which, bsz=32, ctx=CTX):
    src = train_data if which == "train" else val_data
    eff_ctx = min(ctx, max(2, len(src) - 2))
    max_start = max(1, len(src) - eff_ctx - 1)
    ix = torch.randint(0, max_start, (bsz,))
    x = torch.stack([src[i : i + eff_ctx] for i in ix])
    y = torch.stack([src[i + 1 : i + 1 + eff_ctx] for i in ix])
    return x.to(dev), y.to(dev)


class Block(nn.Module):
    def __init__(self, n_embd, n_head):
        super().__init__()
        self.attn = nn.MultiheadAttention(embed_dim=n_embd, num_heads=n_head, batch_first=True)
        self.ff = nn.Sequential(
            nn.Linear(n_embd, 4 * n_embd), nn.GELU(), nn.Linear(4 * n_embd, n_embd)
        )
        self.ln1 = nn.LayerNorm(n_embd)
        self.ln2 = nn.LayerNorm(n_embd)

    def forward(self, x):
        h, _ = self.attn(x, x, x, need_weights=False)
        x = self.ln1(x + h)
        x = self.ln2(x + self.ff(x))
        return x


class TinyLM(nn.Module):
    def __init__(self, vocab, n_embd, n_head, n_layer):
        super().__init__()
        self.embed = nn.Embedding(vocab, n_embd)
        self.blocks = nn.ModuleList([Block(n_embd, n_head) for _ in range(n_layer)])
        self.head = nn.Linear(n_embd, vocab)

    def forward(self, x, targets=None):
        h = self.embed(x)
        for b in self.blocks:
            h = b(h)
        logits = self.head(h)
        loss = None
        if targets is not None:
            loss = nn.functional.cross_entropy(logits.view(-1, logits.size(-1)), targets.view(-1))
        return logits, loss


model = TinyLM(tok.vocab_size, N_EMBD, N_HEAD, N_LAYER).to(dev)
opt = torch.optim.AdamW(model.parameters(), lr=LR)

start = time.time()
next_log = 0
step = 0
print(
    f"[train] device={dev} bytes={len(data)} ctx={CTX} h={N_HEAD} L={N_LAYER} emb={N_EMBD}",
    flush=True,
)
while time.time() - start < BUDGET:
    model.train()
    x, y = get_batch("train")
    _, loss = model(x, y)
    opt.zero_grad()
    loss.backward()
    opt.step()
    step += 1
    if step % 10 == 0 or time.time() - start >= next_log:
        print(
            f"[train] step={step} loss={loss.item():.3f} elapsed={int(time.time() - start)}s",
            flush=True,
        )
        next_log += 30

# eval ppl
model.eval()
tot = 0
cnt = 0
with torch.no_grad():
    for _ in range(20):
        x, y = get_batch("val")
        _, l = model(x, y)
        tot += l.item()
        cnt += 1
save_metrics(model, start, tot, cnt, stop_reason="BUDGET")
