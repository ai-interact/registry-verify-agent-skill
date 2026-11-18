#!/bin/sh
# Make one paid Registry Verify lookup with AgentCash.
#
# This pays 0.10 USDC on Base from your AgentCash wallet. Set one up first with
# `npx agentcash@latest onboard` and fund it with `npx agentcash@latest fund`.
#
# Usage: sh examples/agentcash.sh "<business name>" [state]
#   sh examples/agentcash.sh "Publix Super Markets" FL   searches Florida only
#   sh examples/agentcash.sh "Brooklyn Brewery"           searches every state
# The state is FL, NY, CA or CO. Without it, every state is searched for the
# same 0.10 USDC, and the answer has each state's own result.
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo 'Usage: sh examples/agentcash.sh "<business name>" [FL|NY|CA|CO]' >&2
  exit 2
fi

CHARGE_URL="https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-us-business"
NAME=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1")

if [ "$#" -eq 2 ]; then
  npx agentcash@latest fetch "$CHARGE_URL?state=$2&name=$NAME"
else
  npx agentcash@latest fetch "$CHARGE_URL?name=$NAME"
fi
