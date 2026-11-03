# Registry Verify agent skill

Registry Verify lets an AI agent check a business against Florida's official
corporate records before it pays, onboards, or signs with that business. The
agent sends a business name and pays 0.10 USDC for the lookup over x402 on Base.
There is no account to create and no API key.

This repository holds the agent skill that tells an agent when to use Registry
Verify, how to pay for a lookup, and how to read the answer. It also has two
short examples you can run from a terminal.

Website: https://registryverify.com

## What one lookup returns

You send a business name. You get back up to five candidate filings from the
Florida Division of Corporations data, the data behind Sunbiz. Each filing has:

* the Florida document number, which anyone can check on Sunbiz
* the status Florida reports (active or inactive), the filing type and the
  filing date
* the principal city and ZIP, the registered agent, and the officers
* the home state from Florida's record, with a link to that state's own
  business search when the company was formed elsewhere
* the Florida source file the record came from

A result is a candidate name match, not proof of who you are dealing with. The
skill explains how to tell one strong match from several candidates, and what a
no match does and does not mean.

## Try it

### See the price for free

The first request to the charge URL answers `402 Payment Required` and costs
nothing. Run [examples/see_the_price.sh](examples/see_the_price.sh) to decode
that answer. It needs `curl`, `base64` and `python3`.

```
sh examples/see_the_price.sh
```

It prints the network (`eip155:8453`, which is Base mainnet), the asset (USDC),
the amount (`100000`, which is 0.10 USDC at six decimals), and the address that
receives the payment.

### Make a paid lookup

[AgentCash](https://agentcash.dev) is a wallet tool for agents that pays x402
requests from a USDC balance on Base. With a funded AgentCash wallet, this one
command pays 0.10 USDC and prints the answer:

```
npx agentcash@latest fetch "https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business?name=Publix%20Super%20Markets"
```

The same command is in [examples/agentcash.sh](examples/agentcash.sh), which
takes the business name as an argument. This spends real money, so tell the
person you work for before you run it.

Any other x402 version 2 client works too. Proceeds, the payment service that
sells these lookups, lists compatible agent wallets at
https://docs.myproceeds.xyz/agents/overview.md

## The call

```
GET https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-florida-business?name=<business name>
```

* `name` is required: the business name, URL encoded, 2 to 200 characters.
* `limit` is optional: how many candidate filings to return, 1 to 5. The
  default is 5.
* `home_state` is optional: a two letter United States state code, such as
  `DE`, when you already believe the company was formed in that state.

Call only this charge URL. No other Registry Verify address accepts payment.

The OpenAPI description of the call, with the answer schema, is at
https://registryverify.com/openapi.json

## Install the skill

The skill file is
[skills/registry-verify/SKILL.md](skills/registry-verify/SKILL.md). It is the
same file the website serves at https://registryverify.com/skill.md.

* With the skills command line tool:

  ```
  npx skills add ai-interact/registry-verify-agent-skill
  ```

* In Claude Code, as a plugin from this repository:

  ```
  /plugin marketplace add ai-interact/registry-verify-agent-skill
  /plugin install registry-verify@registry-verify
  ```

* By hand: copy the `skills/registry-verify` folder into your agent's skills
  folder, for example `~/.claude/skills/` for Claude Code.

## Limits

* Florida only. A search says nothing about other states.
* Search is by business name. EIN, address, and officer search are not
  available yet.
* The data comes from Florida's public daily and quarterly files, so a filing
  made today may not be in it yet. The answer says how new the data is.

## More

* How an AI agent checks a Florida LLC:
  https://registryverify.com/guides/verify-a-florida-llc-with-an-ai-agent
* Every field in an answer and where it comes from:
  https://registryverify.com/florida-company-data
* Pricing and a settled test payment on Basescan:
  https://registryverify.com/pricing
* Contact: hello@registryverify.com

## License

The README and the examples are under the MIT license in [LICENSE](LICENSE).
The skill file carries its own license line, which applies to it.
