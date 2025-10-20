#!/bin/bash
# scripts/guard/ethic_check.sh - YAML Policy → ENV Bridge (V1)
# Usage: ethic_check.sh [--print-only|--dry-run]

set -u

MODE="print"
case "${1:-}" in
    --print-only) MODE="print" ;;
    --dry-run) MODE="dry" ;;
    "") MODE="print" ;;
    *) echo "Usage: $0 [--print-only|--dry-run]" >&2; exit 1 ;;
esac

INTENTS_FILE="ops/policy/intents.yml"
ETHICS_FILE="ops/policy/ethics.yml"

# Parse intents (fallback to defaults if file missing)
if [ -f "$INTENTS_FILE" ]; then
    INTENTS_RAW=$(grep -A 100 '^intents:' "$INTENTS_FILE" 2>/dev/null | \
                  sed -n '/^[[:space:]]*-[[:space:]]*/p' | \
                  sed 's/^[[:space:]]*-[[:space:]]*//' | \
                  sed 's/[[:space:]]*$//' | \
                  grep -E '^[a-z_]+$' | \
                  tr '\n' ',' | \
                  sed 's/,$//')
    INTENTS="${INTENTS_RAW:-chat_answer}"
else
    INTENTS="chat_answer"
fi

# Ensure "other" is included
case ",$INTENTS," in
    *,other,*) ;;
    *) INTENTS="$INTENTS,other" ;;
esac

# Parse ethics (fallback to defaults if file missing)
SLA_DEFAULT=3000
declare -A SLA_OVERRIDES
COST_GUARD=""

if [ -f "$ETHICS_FILE" ]; then
    # Parse sla_default_ms
    if SLA_LINE=$(grep '^sla_default_ms:' "$ETHICS_FILE" 2>/dev/null); then
        SLA_DEFAULT=$(echo "$SLA_LINE" | sed 's/^sla_default_ms:[[:space:]]*//' | grep -E '^[0-9]+$' || echo "3000")
    fi
    
    # Parse per-intent SLA overrides
    if grep -A 100 '^sla:' "$ETHICS_FILE" 2>/dev/null | grep -E '^[[:space:]]+[a-z_]+:[[:space:]]*[0-9]+' | while IFS= read -r line; do
        intent=$(echo "$line" | sed 's/^[[:space:]]*\([a-z_]*\):.*/\1/')
        value=$(echo "$line" | sed 's/^[[:space:]]*[a-z_]*:[[:space:]]*\([0-9]*\).*/\1/')
        if [ -n "$intent" ] && [ -n "$value" ]; then
            SLA_OVERRIDES["$intent"]="$value"
        fi
    done; then
        :
    fi
    
    # Parse cost guard
    if COST_LINE=$(grep '^daily_spend_usd_gt:' "$ETHICS_FILE" 2>/dev/null); then
        COST_VAL=$(echo "$COST_LINE" | sed 's/^daily_spend_usd_gt:[[:space:]]*//' | grep -E '^[0-9]+(\.[0-9]+)?$' || echo "0")
        if [ "$COST_VAL" != "0" ] && [ "$COST_VAL" != "0.0" ]; then
            COST_GUARD="$COST_VAL"
        fi
    fi
fi

# Generate exports
PREFIX=""
[ "$MODE" = "dry" ] && PREFIX="# "

echo "${PREFIX}export DAEGIS_INTENTS=\"$INTENTS\""
echo "${PREFIX}export DAEGIS_SLA_DEFAULT_MS=\"$SLA_DEFAULT\""

# Per-intent SLA overrides (parse from ethics file)
if [ -f "$ETHICS_FILE" ]; then
    grep -A 100 '^sla:' "$ETHICS_FILE" 2>/dev/null | \
    grep -E '^[[:space:]]+[a-z_]+:[[:space:]]*[0-9]+' | \
    while IFS= read -r line; do
        intent=$(echo "$line" | sed 's/^[[:space:]]*\([a-z_]*\):.*/\1/')
        value=$(echo "$line" | sed 's/^[[:space:]]*[a-z_]*:[[:space:]]*\([0-9]*\).*/\1/')
        if [ -n "$intent" ] && [ -n "$value" ]; then
            intent_upper=$(echo "$intent" | tr 'a-z' 'A-Z')
            echo "${PREFIX}export DAEGIS_SLA_${intent_upper}_MS=\"$value\""
        fi
    done
fi

if [ -n "$COST_GUARD" ]; then
    echo "${PREFIX}export ETHIC_DAILY_SPEND_GT=\"$COST_GUARD\""
fi

# Summary
INTENT_COUNT=$(echo "$INTENTS" | tr ',' '\n' | wc -l)
OVERRIDE_COUNT=0
if [ -f "$ETHICS_FILE" ]; then
    OVERRIDE_COUNT=$(grep -A 100 '^sla:' "$ETHICS_FILE" 2>/dev/null | \
                     grep -E '^[[:space:]]+[a-z_]+:[[:space:]]*[0-9]+' | \
                     wc -l)
fi
COST_STATUS="${COST_GUARD:-unset}"

echo "[Ethics] intents=$INTENT_COUNT, default=$SLA_DEFAULT, overrides=$OVERRIDE_COUNT, cost_guard=$COST_STATUS" >&2