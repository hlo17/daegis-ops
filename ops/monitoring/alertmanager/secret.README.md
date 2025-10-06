# Alertmanager secret (policy)
- 実値は Git 外: `~/.config/daegis/.env.local`
- `docker-compose` では `env_file` で注入
- Alertmanager は `--config.expand-env` で環境変数展開を有効化
