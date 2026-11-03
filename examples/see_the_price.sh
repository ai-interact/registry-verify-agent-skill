#!/bin/sh
# Show what one Registry Verify lookup costs, without paying.
#
# The first request to the charge URL answers 402 Payment Required. Its
# PAYMENT-REQUIRED header is base64 encoded JSON that lists the accepted
# payments. This script decodes it and prints each one. Nothing is paid.
#
# Usage: sh examples/see_the_price.sh
set -eu

CHARGE_URL="https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business"

curl -s -D - -o /dev/null "$CHARGE_URL?name=Publix%20Super%20Markets" \
  | awk 'tolower($1) == "payment-required:" { print $2 }' \
  | tr -d '\r' \
  | base64 -d \
  | python3 -c '
import json, sys

challenge = json.load(sys.stdin)
for option in challenge["accepts"]:
    print("network:", option["network"])
    print("asset:  ", option["asset"])
    print("amount: ", option["amount"], "(USDC has six decimals, so 100000 is 0.10 USDC)")
    print("pay to: ", option["payTo"])
    print("method: ", option.get("extra", {}).get("name", ""))
    print()
'
