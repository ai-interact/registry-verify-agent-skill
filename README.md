# Registry Verify agent skill

[![M8ven Score](https://m8ven.ai/badge/mcp/ai-interact-registry-verify-agent-skill-wt9ghm?v=e15181578bcf7bc7ecf353eab93ea0be)](https://m8ven.ai/mcp/ai-interact-registry-verify-agent-skill-wt9ghm?s=readme)

Registry Verify lets an AI agent check a business against Florida's, New
York's, California's or Colorado's official company records before it pays,
onboards, or signs with that business. The agent sends a business name, and the
state if it knows it, and pays 0.10 USDC for the lookup over x402 on Base.
There is no account to create and no API key.

This repository holds the agent skill that tells an agent when to use Registry
Verify, how to pay for a lookup, and how to read the answer. It also has two
short examples you can run from a terminal, and the settings for our MCP
server.

Website: https://registryverify.com

## What one lookup returns

There is one charge URL for every state. You send a business name and, if you
know it, the state: Florida, New York, California or Colorado. Each lookup costs
0.10 USDC. A lookup without a state searches every state, one after another,
and returns each state's own answer for the same 0.10 USDC.

A Florida answer has up to five candidate filings from the Florida Division of
Corporations data, the data behind Sunbiz. Each filing has:

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

The Florida answer as a whole also says how current the data is, notes when a Florida
filing and a filing formed in another state carry the same name, and, when you
send `home_state`, says how many candidates were formed in that state.

A New York answer comes from the New York Department of State's register, about
7.2 million companies updated every day. Each company has its DOS ID, New
York's status and the filing that set it, its home state, the service of
process, registered agent, chief executive and principal office addresses,
whether its biennial statement is on file, its newest filings, and its former
and fictitious names. New York lists no officers beyond the chief executive.

A California answer comes from the California Secretary of State's register,
about 9.4 million companies. Each company has its entity number, California's
status and what it means, its standing with the Secretary of State and the
Franchise Tax Board, its home state, its addresses, its agent for service of
process, its officers, managers and members, and its latest Statement of
Information. Every California answer states two dates: statuses as of the
newest monthly file, and new companies through the newest weekly file.
California's file has no status history and no former names.

A Colorado answer comes from the Colorado Department of State's register, about
3.1 million companies updated every day. Each company has its entity ID,
Colorado's status (with what Colorado says it means for its main statuses), its entity type, its
formation date, its home state, its principal and mailing addresses, and its
registered agent with the agent's addresses. Colorado's file has no officers, no
filing history and no former names.

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
npx agentcash@latest fetch "https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-us-business?state=FL&name=Publix%20Super%20Markets"
```

The same command is in [examples/agentcash.sh](examples/agentcash.sh), which
takes the business name and, optionally, the state as arguments. This spends
real money, so tell the person you work for before you run it.

Any other x402 version 2 client works too. Proceeds, the payment service that
sells these lookups, lists compatible agent wallets at
https://docs.myproceeds.xyz/agents/overview.md

## The call

One charge URL serves every state:

```
GET https://myproceeds.xyz/api/pay/cmupojkok000bjz043ecdfmec/verify-us-business?name=<business name>&state=<FL, NY, CA or CO>
```

* `name` is required: the business name, URL encoded, 2 to 200 characters.
* `state` is optional: `FL`, `NY`, `CA` or `CO`, or the state's name. Without
  it, or with a state we do not cover, every state is searched one after
  another, and the answer lists each state's own result in `states`.
* `limit` is optional: how many candidates to return for each state, 1 to 5.
  The default is 5.
* `home_state` is optional and read for Florida only: a two letter United
  States state code, such as `DE`, when you already believe the company was
  formed in that state.

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
in) with one tool, `verify_us_business`. It takes the business name and, if you
know it, the state. For each state it checks (every state when you name none),
it gives the date of the newest data we hold, lists the legal names of up to
three candidates while the hourly free preview lasts, and returns the charge
URL for the full record with that state filled in. The full record costs 0.10
USDC, paid at that URL by your own x402 wallet, such as the AgentCash MCP
server. Claude, Claude Code and Cursor have no wallet of their own, so without
one the agent stops at the charge URL. The MCP server never takes a payment and
never sees a wallet or a key.

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

* Florida, New York, California and Colorado only, all through one charge URL.
  A search says nothing about other states.
* Search is by business name. EIN, address, and officer search are not
  available yet.
* The data comes from each state's public files. Florida, New York and Colorado
  are updated every day. California's new companies are updated every week and
  its statuses every month. A filing made today may not be in the data yet.
  Every answer says how new its data is.
* Not affiliated with the Florida, New York or Colorado Department of State, or
  the California Secretary of State.

## More

* How an AI agent checks a company in state records:
  https://registryverify.com/guides/verify-a-company-with-an-ai-agent
* Every field in an answer and where it comes from:
  https://registryverify.com/company-data
* The paid API for every state:
  https://registryverify.com/business-lookup-api
* Pricing and a settled test payment on Basescan:
  https://registryverify.com/pricing
* Contact: hello@registryverify.com

## License

The README and the examples are under the MIT license in [LICENSE](LICENSE).
The skill file carries its own license line, which applies to it.
