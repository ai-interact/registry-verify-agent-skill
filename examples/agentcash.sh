#!/bin/sh
# Make one paid Registry Verify lookup with AgentCash.
#
# This pays 0.10 USDC on Base from your AgentCash wallet. Set one up first with
# `npx agentcash@latest onboard` and fund it with `npx agentcash@latest fund`.
#
# Usage: sh examples/agentcash.sh "Publix Super Markets"
set -eu

if [ "$#" -ne 1 ]; then
  echo 'Usage: sh examples/agentcash.sh "<business name>"' >&2
  exit 2
fi

CHARGE_URL="https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business"
NAME=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1")

npx agentcash@latest fetch "$CHARGE_URL?name=$NAME"
