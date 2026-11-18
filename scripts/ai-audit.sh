#!/bin/bash

FILE=$1

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: ./scripts/ai-audit.sh <path-to-manifest.yaml>"
  exit 1
fi

echo "🔍 Auditing $FILE with local qwen2.5-coder:7b..."

CONTENT=$(cat "$FILE")

# Construct JSON payload using jq
PAYLOAD=$(jq -n \
  --arg model "qwen2.5-coder:7b" \
  --arg prompt "You are a Senior Site Reliability Engineer. Audit this Kubernetes YAML manifest for security risks (like running as root or privileged mode), missing CPU/memory resource limits, and reliability flaws. Provide a concise bulleted list of issues and fixes:\n\n$CONTENT" \
  '{model: $model, prompt: $prompt, stream: false}')

RESPONSE=$(curl -s http://localhost:11434/api/generate -d "$PAYLOAD" | jq -r '.response')

echo "----------------------------------------"
echo "$RESPONSE"
echo "----------------------------------------"
