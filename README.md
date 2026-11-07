# Registry Verify agent skill

[![M8ven Score](https://m8ven.ai/badge/mcp/ai-interact-registry-verify-agent-skill-wt9ghm?v=e15181578bcf7bc7ecf353eab93ea0be)](https://m8ven.ai/mcp/ai-interact-registry-verify-agent-skill-wt9ghm?s=readme)

Registry Verify lets an AI agent check a business against Florida's official
corporate records before it pays, onboards, or signs with that business. The
agent sends a business name and pays 0.10 USDC for the lookup over x402 on Base.
There is no account to create and no API key.

This repository holds the agent skill that tells an agent when to use Registry
Verify, how to pay for a lookup, and how to read the answer. It also has two
short examples you can run from a terminal, and the settings for our MCP
server.

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
* whether this year's Florida annual report is filed, due or late, with the
  due date and the September date when Florida dissolves or revokes a filing
  still missing it
* its status history: when we first saw it in Florida's daily files and the
  last status change we recorded
* the Florida source file the record came from

The answer as a whole also says how current the data is, notes when a Florida
filing and a filing formed in another state carry the same name, and, when you
send `home_state`, says how many candidates were formed in that state.

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

* In Claude Code, as a plugin from this repository. The plugin also connects
  the MCP server described below.

  ```
  /plugin marketplace add ai-interact/registry-verify-agent-skill
  /plugin install registry-verify@registry-verify
  ```

* By hand: copy the `skills/registry-verify` folder into your agent's skills
  folder, for example `~/.claude/skills/` for Claude Code.

## Use it as an MCP server

https://registryverify.com/mcp is a free MCP server (Streamable HTTP, no sign
in) with one tool, `verify_florida_business`. It checks the name, gives the
date of the newest Florida file we hold, lists the legal names of up to three
candidate filings while the hourly free preview lasts, and returns the charge
URL for the full record. The full record costs 0.10 USDC, paid at that URL by
your own x402 wallet, such as the AgentCash MCP server. Claude, Claude Code and
Cursor have no wallet of their own, so without one the agent stops at the
charge URL. The MCP server never takes a payment and never sees a wallet or a key.

* Claude Code:

  ```
  claude mcp add --transport http registry-verify https://registryverify.com/mcp
  ```

* Cursor: add this entry to `.cursor/mcp.json` in your project, or to
  `~/.cursor/mcp.json` for all your projects:

  ```json
  {
    "mcpServers": {
      "registry-verify": {
        "url": "https://registryverify.com/mcp"
      }
    }
  }
  ```

* Claude: open Customize, then Connectors, choose Add custom connector, and
  paste `https://registryverify.com/mcp`. Opening that address in a browser
  shows the same steps.

## Limits

* Florida only. A search says nothing about other states.
* Search is by business name. EIN, address, and officer search are not
  available yet.
* The data comes from Florida's public daily and quarterly files, so a filing
  made today may not be in it yet. The answer says how new the data is.
* Not affiliated with the Florida Department of State.

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
