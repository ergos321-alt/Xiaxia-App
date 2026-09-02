#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_dir"

for forbidden in \
  "chat/completions" \
  "system_prompt" \
  "systemPrompt" \
  "temperature" \
  "frequency_penalty" \
  "presence_penalty" \
  "api.openai.com" \
  "api.deepseek.com" \
  "dashscope"; do
  if rg -n --glob '*.dart' --glob '*.kt' "$forbidden" lib android/app/src/main/kotlin; then
    echo "FAIL: forbidden mobile-brain token found: $forbidden" >&2
    exit 1
  fi
done

if test -d server; then
  echo "FAIL: ZeroChat server must not ship with the mobile app" >&2
  exit 1
fi

if rg -n "ZeroChat|zerochat" lib android pubspec.yaml; then
  echo "FAIL: upstream product identity remains in runtime files" >&2
  exit 1
fi

if rg -n "ContractPendingCoreClient|contractUnavailable" lib test; then
  echo "FAIL: pending Core contract path remains after production wiring" >&2
  exit 1
fi

if rg -n "package:http|http\." lib/features; then
  echo "FAIL: HTTP leaked into a Widget/Page/controller feature layer" >&2
  exit 1
fi

rg -q "ProductionCoreClientFactory" lib/main.dart
rg -q "'/v1/chat'" lib/core/api/production_core_contract_adapter.dart
rg -q "'/health'" lib/core/api/production_core_contract_adapter.dart
rg -q "'/v1/status'" lib/core/api/production_core_contract_adapter.dart

test -f lib/core/api/core_client.dart
test -f lib/core/api/http_core_client.dart
test -f lib/core/api/production_core_contract_adapter.dart
test -f lib/core/api/production_core_client_factory.dart
test -f lib/domain/presence/presence_state.dart
test -f lib/domain/ownership.dart
test -f lib/domain/reality/reality_models.dart
test -f lib/domain/proactive/proactive_presentation.dart

echo "PASS: mobile AI-brain boundary and Xiaxia product identity checks"
