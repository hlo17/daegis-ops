#!/usr/bin/env bash
set -Eeuo pipefail

FACTORY_DIR="${FACTORY_DIR:-ops/factory}"
QUEUE_DIR="${QUEUE_DIR:-$FACTORY_DIR/queue}"
POLICY_DIR="${POLICY_DIR:-$FACTORY_DIR/policies.d}"
JOURNAL="${JOURNAL:-logs/factory_jobs.jsonl}"
GENOME="${GENOME:-ops/factory/genome_index.jsonl}"
LOCK_DIR="${LOCK_DIR:-$FACTORY_DIR/locks}"
mkdir -p "$QUEUE_DIR" "$POLICY_DIR" "$LOCK_DIR" logs || true

now_ts() {
python3 - <<'PY'
import time
print(time.time())
PY
}

# ---- JSON journal helpers ----
json_line() { # key=value ... -> one JSON line (string-escaped)
  python3 - "$@" <<'PY'
import json,sys
d={}
for kv in sys.argv[1:]:
    k,v = kv.split("=",1)
    d[k]=v
print(json.dumps(d, ensure_ascii=False))
PY
}
journal_append(){ printf '%s\n' "$1" >> "$JOURNAL"; }

# ---- RBAC lookup ----
role_for_intent(){  # intent -> role
  python3 - "$POLICY_DIR/rbac.json" "$1" <<'PY'
import json,sys
rb=json.load(open(sys.argv[1]))
print(rb.get("bindings",{}).get(sys.argv[2],""))
PY
}
allowed_token_rules_for_role(){ # role -> lines of JSON arrays (token patterns)
  python3 - "$POLICY_DIR/rbac.json" "$1" <<'PY'
import json,sys
rb=json.load(open(sys.argv[1]))
role=sys.argv[2]
for rule in rb.get("roles",{}).get(role,[]):
    print(json.dumps(rule, ensure_ascii=False))
PY
}

# ---- Token matcher (exact tokens; "*" matches one arbitrary token) ----
is_cmd_allowed_tokens(){ # is_cmd_allowed_tokens ROLE -- tok1 tok2 ...
  local role="$1"; shift
  [[ "${1:-}" == "--" ]] && shift
  local -a cmd=( "$@" )

  # read rules (each line is JSON array)
  while IFS= read -r rule; do
    [[ -z "$rule" ]] && continue
    # to bash array "pat"
    mapfile -t pat < <(python3 - <<'PY' "$rule"
import json,sys
for t in json.loads(sys.argv[1]): print(t)
PY
)
    # length must match
    [[ ${#pat[@]} -eq ${#cmd[@]} ]] || continue
    local ok=1
    for i in "${!pat[@]}"; do
      if [[ "${pat[$i]}" == "*" ]]; then
        continue
      elif [[ "${pat[$i]}" == "${cmd[$i]}" ]]; then
        continue
      else
        ok=0; break
      fi
    done
    [[ $ok -eq 1 ]] && return 0
  done < <(allowed_token_rules_for_role "$role")
  return 1
}

# ---- HMAC verification: canonical JSON (no "hmac"), sort_keys+compact ----
verify_hmac(){ # echo OK | NO_KEY | NO_SIG | MISMATCH
  local jobfile="$1"
  local key="${FACTORY_HMAC_KEY:-}"
  if [[ -z "$key" ]]; then echo "NO_KEY"; return 1; fi
  python3 - "$jobfile" "$key" <<'PY'
import json,sys,hashlib,hmac
job=json.load(open(sys.argv[1]))
sig=job.pop("hmac", "")
if not sig:
    print("NO_SIG"); sys.exit(1)
def canonical(o): return json.dumps(o, separators=(',',':'), sort_keys=True, ensure_ascii=False)
mac=hmac.new(sys.argv[2].encode(), canonical(job).encode(), hashlib.sha256).hexdigest()
print("OK" if mac==sig else "MISMATCH")
PY
}

# ---- Exec & sandbox utils ----
safe_exec_tokens(){ # timeout_sec -- tok1 tok2 ...
  local to="${1:-60}"; shift
  [[ "${1:-}" == "--" ]] && shift
  # deny sudo
  if [[ "${1:-}" == "sudo" ]]; then echo "DENY_SUDO"; return 126; fi
  ulimit -n 1024 || true
  timeout "${to}s" -- "${@}"
}

hash_file(){ sha256sum "$1" 2>/dev/null | awk '{print $1}'; }

lock_acquire(){ mkdir "$LOCK_DIR/$1.lock" 2>/dev/null; }
lock_release(){ rmdir "$LOCK_DIR/$1.lock" 2>/dev/null || true; }
